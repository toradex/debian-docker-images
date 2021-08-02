#!/bin/bash -l

WAYLAND_USER=${WAYLAND_USER:-torizon}
WESTON_ARGS=${WESTON_ARGS:---current-mode}

#
# Detect SoC and suported features.
#

SOC_ID=''
SOC_ID_FILE='/sys/devices/soc0/soc_id'
test -e $SOC_ID_FILE && SOC_ID=$(<$SOC_ID_FILE)
if test -n "$SOC_ID" ; then
    echo "SoC is: '$SOC_ID'"
else
    echo "Cannot detect SoC! Assuming it's GPU-capable."
fi
HAS_GPU=true
HAS_DPU=false

function has_feature()
{
    FEATURE=$1
    PATTERNS_FILE=/etc/imx_features/${FEATURE}.socs
    ANSWER=false
    test -r $PATTERNS_FILE && grep -qf $PATTERNS_FILE <<<"$SOC_ID" && ANSWER=true
    echo $ANSWER
}

test -n "$SOC_ID" && {
    HAS_GPU=$(has_feature 'imxgpu')
    HAS_DPU=$(has_feature 'imxdpu')
}
echo "SoC has GPU: $HAS_GPU"
echo "SoC has DPU: $HAS_DPU"

#
# Decide on what g2d implementation must be enabled for weston.
#

G2D_IMPLEMENTATION='viv'
$HAS_DPU && G2D_IMPLEMENTATION='dpu'
echo "g2d implementation: $G2D_IMPLEMENTATION"
test -e /etc/alternatives/libg2d.so.1.5 && update-alternatives --set libg2d.so.1.5 /usr/lib/aarch64-linux-gnu/libg2d-${G2D_IMPLEMENTATION}.so
test -e /etc/alternatives/g2d_samples && update-alternatives --set g2d_samples /opt/g2d_${G2D_IMPLEMENTATION}_samples

#
# Set desktop defaults.
#

function init_xdg()
{
    if test -z "${XDG_RUNTIME_DIR}"; then
        export XDG_RUNTIME_DIR=/tmp/$(id -u ${WAYLAND_USER})-runtime-dir
    fi

    echo "XDG_RUNTIME_DIR=${XDG_RUNTIME_DIR}" >> /etc/environment

    if ! test -d "${XDG_RUNTIME_DIR}"; then
        mkdir -p "${XDG_RUNTIME_DIR}"
    fi

    chown "${WAYLAND_USER}" "${XDG_RUNTIME_DIR}"
    chmod 0700 "${XDG_RUNTIME_DIR}"

    # Create folder for XWayland Unix socket
    export X11_UNIX_SOCKET="/tmp/.X11-unix"
    if ! test -d "${X11_UNIX_SOCKET}"; then
        mkdir -p ${X11_UNIX_SOCKET}
    fi

    chown ${WAYLAND_USER}:video ${X11_UNIX_SOCKET}
}

init_xdg

#
# Execute the weston compositor.
#

function init()
{
    SWITCH_VT_CMD=""
    # Weston misses to properly change VT when using weston-launch. Work around
    # by manually switch VT before Weston starts. This avoid keystrokes ending
    # up on the old VT (e.g. tty1).
    # Use bash built-in regular exprssion to find tty device
    VT=""
    if [[ "$1" == "weston-launch" && "$@" =~ --tty=/dev/tty([^ ][0-9]*) ]]; then
        VT=${BASH_REMATCH[1]}
        # Make process a session leader and switch to a new VT. Always wait
        # on the child processes until they terminate (-w).
        SWITCH_VT_CMD="setsid -w -f openvt -w -f -s -c ${VT} -e"
    fi

    # echo error message, when executable file doesn't exist.
    if CMD=$(command -v "$1" 2>/dev/null); then
        shift
        CMD="${CMD} $@"
        if [ "${SWITCH_VT_CMD}" != "" ]; then
            STDOUT="/proc/$$/fd/1"
            STDERR="/proc/$$/fd/2"
            # Run the command after becoming session leader and switching VT.
            # Redirect the output of the console to /dev/console so that
            # we can see the output of the command.
            # We can't use exec in the first call because we don't want to use
            # absolute paths and we want to spawn another process anyways.
            # For the second command we need to use bash because otherwise
            # we would never call /etc/profile and then we wouldn't accept
            # the FSL EULA even if it is set.
            # This whole command is messy, be very careful when changing it!
            # We need to emulate a similar behaviour as systemd does, we need
            # to switch VT and we need to accept the FSL EULA. This is all
            # necessary because else we would see a freeze on iMX8 devices
            # when no display is enabled.
            # Show output of the command in the VT as well as in the current console
            exec ${SWITCH_VT_CMD} -- bash -c "${CMD} > >(tee ${STDOUT}) 2> >(tee ${STDERR})" &
            child=$!
            # Remap signals so that weston-launch also gets them
            for signal in SIGINT SIGTERM SIGHUP SIGABRT SIGKILL; do trap "kill -$signal $child" $signal; done
            wait "$child"
        else
            sh -c "${CMD}"
        fi
    else
        echo "Command not found: $1"
        exit 1
    fi
}

if [ $# -gt 0 ]; then
    options=$(getopt -l "developer,touch2pointer:" -- "$@" 2>/dev/null)

    while true
    do
        case $1 in
        --developer)
            export XDG_CONFIG_HOME=/etc/xdg/weston-dev/
            echo "XDG_CONFIG_HOME=/etc/xdg/weston-dev/" >> /etc/environment
            ;;
        --touch2pointer)
            shift
            # Start the touch2pointer application
            /usr/bin/touch2pointer $1 &
            ;;
        *)
            break;;
        esac
        shift
    done
fi

$HAS_GPU || $HAS_DPU || {
    echo "Fallbacking to software renderer."
    WESTON_ARGS="${WESTON_ARGS} --use-pixman"
}

REMOTE_UI="[screen-share]"
VNC_BACKEND="command=/usr/bin/weston --backend=vnc-backend.so --shell=fullscreen-shell.so"
RDP_BACKEND="command=/usr/bin/weston --backend=rdp-backend.so --shell=fullscreen-shell.so --no-clients-resize  --rdp-tls-key=/var/volatile/tls.key --rdp-tls-cert=/var/volatile/tls.crt --force-no-compression"
CONFIGURATION_FILE=/etc/xdg/weston/weston.ini
CONFIGURATION_FILE_DEV=/etc/xdg/weston-dev/weston.ini

if [ "$ENABLE_VNC" = "1" ]; then
    MSG=$REMOTE_UI"\n"$VNC_BACKEND
    echo -e $MSG | tee -a $CONFIGURATION_FILE $CONFIGURATION_FILE_DEV 1>/dev/null
fi

if [ "$ENABLE_RDP" = "1" ]; then
    {
    MSG=$REMOTE_UI"\n"$RDP_BACKEND
    echo -e $MSG | tee -a $CONFIGURATION_FILE $CONFIGURATION_FILE_DEV 1>/dev/null

    if [ ! -f /var/volatile/tls.crt ] || [ ! -f /var/volatile/tls.key ]
    then
        echo "Certificates for RDP not found in /var/volatile"
        mkdir -p /var/volatile
        cd /var/volatile
        openssl genrsa -out tls.key 2048 && \
        openssl req -new -key tls.key -out tls.csr \
            -subj "/C=CH/ST=Luzern/L=Luzern/O=Toradex/CN=www.toradex.com" && \
        openssl x509 -req -days 365 -signkey tls.key \
            -in tls.csr -out tls.crt
        chmod 0644 tls.key tls.crt
        if [ -f "tls.crt" ]; then
            echo "Certificate for RDP successfully generated"
        else
            echo "Error generating certificate for RDP"
        fi
        cd
    else
        echo "Certificates for RDP found in /var/volatile. Skipping generation."
    fi
    } 2>&1 | tee -a /var/volatile/weston.log
fi

if [ "$IGNORE_X_LOCKS" != "1" ]; then
    echo "Removing previously created '.X*-lock' entries under /tmp before starting Weston. Pass 'IGNORE_X_LOCKS=1' environment variable to Weston container to disable this behavior."
    rm -rf /tmp/.X*-lock
fi

function cleanup()
{
    # switch back to tty1, otherwise the console screen is not displayed.
    chvt 1
}

trap cleanup EXIT

dos2unix $CONFIGURATION_FILE
dos2unix $CONFIGURATION_FILE_DEV

if test -z "$1"; then
    init weston-launch --tty=/dev/tty7 --user="${WAYLAND_USER}" -- ${WESTON_ARGS}
else
    init "$@"
fi
