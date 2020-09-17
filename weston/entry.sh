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
    # Weston misses to properly change VT when using weston-launch. Work around
    # by manually switch VT before Weston starts. This avoid keystrokes ending
    # up on the old VT (e.g. tty1).
    # Use bash built-in regular exprssion to find tty device
    if [[ "$1" == "weston-launch" && "$@" =~ --tty=/dev/tty([^ ][0-9]*) ]]; then
        VT=${BASH_REMATCH[1]}
        echo "Switching to VT ${VT}"
        chvt ${VT}
    fi

    # echo error message, when executable file doesn't exist.
    if CMD=$(command -v "$1" 2>/dev/null); then
        shift
        exec "$CMD" "$@"
    else
        echo "Command not found: $1"
        exit 1
    fi
}

if [ "$1" = "--developer" ]; then
    export XDG_CONFIG_HOME=/etc/xdg/weston-dev/
    echo "XDG_CONFIG_HOME=/etc/xdg/weston-dev/" >> /etc/environment
    shift
fi

$HAS_GPU || $HAS_DPU || {
    echo "Fallbacking to software renderer."
    WESTON_ARGS="${WESTON_ARGS} --use-pixman"
}

if test -z "$1"; then
    init weston-launch --tty=/dev/tty7 --user="${WAYLAND_USER}" -- ${WESTON_ARGS}
else
    init "$@"
fi
