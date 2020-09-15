#!/bin/bash -l

WAYLAND_USER=${WAYLAND_USER:-torizon}
WESTON_ARGS=${WESTON_ARGS:---current-mode}

SOC_ID=''
SOC_ID_FILE='/sys/devices/soc0/soc_id'
test -e $SOC_ID_FILE && SOC_ID=$(<$SOC_ID_FILE)

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

function check_gpu()
{
    case "$SOC_ID" in
        '')
            echo "Could not detect SoC, assuming GPU is available."
            ;;
        i.MX6ULL|i.MX7S|i.MX7D)
            echo "SoC without GPU detected, using Pixman renderer."
            WESTON_ARGS="${WESTON_ARGS} --use-pixman"
            ;;
    esac
}

function choose_alternatives()
{
    G2D_IMPLEMENTATION='viv'
    case "$SOC_ID" in
        # FIXME: TOR-1322: refine the detection of devices with DPU
        i.MX8*) G2D_IMPLEMENTATION='dpu'
    esac
    test -e /etc/alternatives/libg2d.so.1.5 && update-alternatives --set libg2d.so.1.5 /usr/lib/aarch64-linux-gnu/libg2d-${G2D_IMPLEMENTATION}.so
    test -e /etc/alternatives/g2d_samples && update-alternatives --set g2d_samples /opt/g2d_${G2D_IMPLEMENTATION}_samples
}

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

init_xdg
check_gpu
choose_alternatives

if [ "$1" = "--developer" ]; then
    export XDG_CONFIG_HOME=/etc/xdg/weston-dev/
    echo "XDG_CONFIG_HOME=/etc/xdg/weston-dev/" >> /etc/environment
    shift
fi

if test -z "$1"; then
    init weston-launch --tty=/dev/tty7 --user="${WAYLAND_USER}" -- ${WESTON_ARGS}
else
    init "$@"
fi
