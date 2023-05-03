#!/bin/sh

# This is a wrapper script for running Qt5 KMS applications on Toradex devices.
# It writes kms configuration in /etc/kms.conf and then runs the specified
# application. The QT_FORCE_DRI_DEVICE environment variable can be used to
# force a particular dri device.
#
# Examples uses:
#   kms-setup.sh /usr/lib/aarch64-linux-gnu/qt5/examples/opengl/hellowindow/hellowindow --timeout
#   kms-setup.sh /usr/lib/aarch64-linux-gnu/qt5/examples/opengl/hellowindow/hellowindow --help
#   kms-setup.sh /usr/lib/aarch64-linux-gnu/qt5/examples/opengl/cube/cube
#   QT_FORCE_DRI_DEVICE=card0 kms-setup.sh /usr/lib/aarch64-linux-gnu/qt5/examples/opengl/cube/cube
#
# Note: This script uses the hostname to determine what device it is running on,
# and then sets the usable dri device. When running from inside a container,
# make sure to use --net=host so that the hostname inside the container is same
# as that on the device.

HOSTNAME=$(hostname)

check_module () {
	MODULE=${HOSTNAME%-*}
	echo ${MODULE}
}

set_dri_device () {
	DRI_DEVICE=$(ls /run/udev/tags/seat/+drm* | tail -n1 | grep -o card.)
	echo "${DRI_DEVICE}"
}

create_kms_conf () {
        MODULE=$(check_module)

	if [ -z ${QT_FORCE_DRI_DEVICE+x} ]; then
		DRI_DEVICE=$(set_dri_device)
	else
		DRI_DEVICE=${QT_FORCE_DRI_DEVICE}
	fi

        echo "Creating /etc/kms.conf with following contents:"
        printf "{\n  \"device\": \"/dev/dri/${DRI_DEVICE}\",\n  \"hwcursor\": false\n}\n" | tee /etc/kms.conf
	echo "Qt will use DRI device \"${DRI_DEVICE}\" for module \"${MODULE}\"."
}

create_kms_conf
echo "Now running \"$@\"" && $@
