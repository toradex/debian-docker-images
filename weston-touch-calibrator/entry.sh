#!/bin/bash -l

WESTON_ARGS="-Bdrm-backend.so -S${WAYLAND_DISPLAY}"

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
            HEAD=${HEAD:-Unknown-1}
            echo "HEAD: $HEAD"
            ;;
        *)
            # Use Display from argument list or DPI-1 if not specified
            HEAD=${HEAD:-DPI-1}
            echo "HEAD: $HEAD"
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
chvt 7
weston ${WESTON_ARGS} &
WESTON_SERVER=$!

# Wait up to 5 seconds until weston starts
FIND_WAYLAND_DISPLAY_CMD="find ${XDG_RUNTIME_DIR} -name wayland-* | grep -Eo \"wayland-.$\""
for i in seq 1 5; do eval $FIND_WAYLAND_DISPLAY_CMD && break; sleep 1; done
export WAYLAND_DISPLAY=$(eval ${FIND_WAYLAND_DISPLAY_CMD})
test -e $XDG_RUNTIME_DIR/${WAYLAND_DISPLAY} || { echo "Weston did not start"; exit 1; }

# Start weston touch calibrator
weston-touch-calibrator ${HEAD}
# Bring weston to foreground again to allow verifying the settings
wait $WESTON_SERVER
