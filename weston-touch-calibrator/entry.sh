#!/bin/bash -l

# Use Display from argument list or DPI-1 if not specified
DISPLAY=""
WESTON_ARGS=""

function check_gpu()
{
    if [ ! -f /sys/devices/soc0/soc_id ]; then
        echo "Could not detect SoC, assuming GPU is available."
        return
    fi

    case $(cat /sys/devices/soc0/soc_id) in
        i.MX6ULL|i.MX7S|i.MX7D)
            echo "SoC without GPU detected, using Pixman renderer."
            WESTON_ARGS="${WESTON_ARGS} --use-pixman"
            DISPLAY=${DISPLAY:-Unknown-1}
            echo "DISPLAY: $DISPLAY"
            ;;
        *)
            DISPLAY=${DISPLAY:-DPI-1}
            ;;
    esac
}

export XDG_RUNTIME_DIR=/tmp/weston-xdg
mkdir -p $XDG_RUNTIME_DIR
mkdir -p /tmp/.X11-unix/
# Make sure no leftovers from the last time are there
rm -f $XDG_RUNTIME_DIR/*

echo XDG_RUNTIME_DIR=$XDG_RUNTIME_DIR >> /etc/environment

# Start weston and fork to background
check_gpu
weston-launch --tty=/dev/tty7 --user=root -- ${WESTON_ARGS} &
WESTON_SERVER=$!

# Wait up to 5 seconds until weston starts
for i in seq 1 5; do test -e $XDG_RUNTIME_DIR/wayland-0 && break; sleep 1; done
test -e $XDG_RUNTIME_DIR/wayland-0 || { echo "Weston did not start"; exit 1; }

# Start weston touch calibrator
weston-touch-calibrator ${DISPLAY}
# Bring weston to foreground again to allow verifying the settings
wait $WESTON_SERVER
