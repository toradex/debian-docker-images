#!/bin/bash -l

function init_xdg()
{
    if test -z "${XDG_RUNTIME_DIR}"; then
        export XDG_RUNTIME_DIR=/tmp/${UID}-runtime-dir
    fi

    echo "XDG_RUNTIME_DIR=/tmp/${UID}-runtime-dir" >> /etc/environment
    if ! test -d "${XDG_RUNTIME_DIR}"; then
        mkdir -p "${XDG_RUNTIME_DIR}"
        chmod 0700 "${XDG_RUNTIME_DIR}"
    fi

    # create folder for XWayland socket
    mkdir -p /tmp/.X11-unix
}

function init()
{
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

if [ "$1" = "--developer" ]; then
    export XDG_CONFIG_HOME=/etc/xdg/weston-dev/
    echo "XDG_CONFIG_HOME=/etc/xdg/weston-dev/" >> /etc/environment
    shift
fi

if test -z "$1"; then
    init weston-launch --tty=/dev/tty7 --user=root
else
    init "$@"
fi
