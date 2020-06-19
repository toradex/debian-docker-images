#!/bin/bash -l

# Use Display from argument list or DPI-1 if not specified
DISPLAY=${1:-DPI-1}

export XDG_RUNTIME_DIR=/tmp/weston-xdg
mkdir -p $XDG_RUNTIME_DIR
mkdir -p /tmp/.X11-unix/
# Make sure no leftovers from the last time are there
rm -f $XDG_RUNTIME_DIR/*

echo XDG_RUNTIME_DIR=$XDG_RUNTIME_DIR >> /etc/environment

# Start weston and fork to background
weston-launch --tty=/dev/tty7 --user=root &
WESTON_SERVER=$!

# Wait up to 5 seconds until weston starts
for i in seq 1 5; do test -e $XDG_RUNTIME_DIR/wayland-0 && break; sleep 1; done
test -e $XDG_RUNTIME_DIR/wayland-0 || { echo "Weston did not start"; exit 1; }

# Start weston touch calibrator
weston-touch-calibrator DPI-1
# Bring weston to foreground again to allow verifying the settings
wait $WESTON_SERVER
