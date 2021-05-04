#!/bin/bash

TORIZON_NAME="torizon"
TORIZON_UID="1000"
TORIZON_GID="1000"

# list of extra groups to create (group IDs must match TorizonCore)
EXTRA_GROUPS="
dialout:20
audio:29
video:44
gpio:49
i2cdev:51
spidev:52
pwm:54
input:101
kvm:102
render:103
"

# create torizon user/group
groupadd --gid $TORIZON_GID $TORIZON_NAME
useradd --gid $TORIZON_GID --uid $TORIZON_UID --create-home $TORIZON_NAME

# create extra groups and add torizon user to them
for extra_group in $EXTRA_GROUPS; do
    gname=$(echo "$extra_group" | cut -d ':' -f 1)
    gid=$(echo "$extra_group" | cut -d ':' -f 2)

    # add group
    groupadd --gid "$gid" "$gname"

    case $? in

    # sucess
    0)
    ;;

    # GID already in use
    4)
        echo "Cannot create group $gname because GID $gid is already in use."
	exit 1
    ;;

    # group already exists
    9)
        # change group ID
        if ! groupmod -g "$gid" "$gname"; then
            echo "Could not set group $gname to ID $gid."
            exit 1
        fi
    ;;

    # other errors
    *)
        echo "Error adding group $gname with ID $gid."
	exit 1
    ;;

    esac

    # add torizon user to group
    usermod -a -G "$gname" "$TORIZON_NAME"
done
