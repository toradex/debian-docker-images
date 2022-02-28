ARG IMAGE_ARCH=linux/arm
# For arm64 use:
# ARG IMAGE_ARCH=linux/arm64
ARG BASE_NAME=wayland-base
# For arm64v8 use: 
# ARG BASE_NAME=wayland-base-vivante
ARG IMAGE_TAG=2
ARG DOCKER_REGISTRY=torizon
FROM --platform=$IMAGE_ARCH $DOCKER_REGISTRY/$BASE_NAME:$IMAGE_TAG AS base

# Install the weston compositor.
RUN apt-get -y update && apt-get install -y --no-install-recommends \
    weston \
    xwayland \
    kbd \
    dos2unix \
    && apt-get clean && apt-get autoremove && rm -rf /var/lib/apt/lists/*

# Install touch2pointer application
RUN apt-get -y update && apt-get install -y --no-install-recommends \
    touch2pointer \
    && apt-get clean && apt-get autoremove && rm -rf /var/lib/apt/lists/*

# Refrain dash from taking over the /bin/sh symlink.
# This makes sure that signals get delivered to Weston when using the weston-launch shell script.
RUN echo 'dash dash/sh boolean false' | debconf-set-selections \
    && DEBIAN_FRONTEND=noninteractive DEBCONF_NONINTERACTIVE_SEEN=true dpkg-reconfigure dash \
    && test $(realpath /bin/sh) = '/bin/bash'

# Container entry point and support files.
COPY entry.sh /usr/bin/entry.sh
COPY switchvtmode.pl /usr/bin/switchvtmode.pl
COPY weston.ini /etc/xdg/weston/weston.ini
COPY weston-dev.ini /etc/xdg/weston-dev/weston.ini
RUN mkdir -p /etc/imx_features
COPY imx_features /etc/imx_features/

# The compositor needs access to input devices
RUN usermod -a -G input torizon

WORKDIR /home/torizon

ENTRYPOINT ["/usr/bin/entry.sh"]
