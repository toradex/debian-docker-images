ARG IMAGE_ARCH=linux/arm
# For arm64 use:
# ARG IMAGE_ARCH=linux/arm64
ARG BASE_NAME=wayland-base
# For arm64v8 use: 
# ARG BASE_NAME=wayland-base-vivante
ARG IMAGE_TAG=2-bullseye
ARG DOCKER_REGISTRY=torizon
FROM --platform=$IMAGE_ARCH $DOCKER_REGISTRY/$BASE_NAME:$IMAGE_TAG AS base

# On Vivante containers, libavutil56 pulls ocl-icd-libopencl1 that conflicts with libopencl-vivante1 from Toradex.
# Workaround by relaxing the dependencies of libavutil56 so libopencl1-vivante1 can be installed as a provider of libOpenCL.so.1.
RUN apt-get -y update && apt-cache madison weston | head -n1 | if grep -q toradex ; \
    then \
        echo "Adapting libavutil56 to accept libopencl1-vivante1 as a provider of libOpenCL.so.1 ..." 1>&2 \
        && apt-get -y install --no-install-recommends binutils xz-utils \
        && WORK_DIR=$(mktemp -d) \
        && cd $WORK_DIR \
        && apt-get download libavutil56 \
        && ar x libavutil56_*_arm64.deb \
        && tar -xJf control.tar.xz \
        && sed -i '/^Depends:/s/, *ocl-icd-libopencl1\>.*//' control \
        && tar -cJf control.tar.xz control md5sums shlibs symbols triggers \
        && ar rcs libavutil56.deb debian-binary control.tar.xz data.tar.xz \
        && apt-get -y install --no-install-recommends ./libavutil56.deb libopencl-vivante1 \
        && cd ~ \
        && rm -rf $WORK_DIR \
        && apt-get -y remove binutils xz-utils \
        && apt-mark hold libavutil56 ; \
    else \
        : ; \
    fi \
    && apt-get clean && apt-get autoremove && rm -rf /var/lib/apt/lists/*

# Install the weston compositor.
RUN apt-get -y update && apt-get install -y --no-install-recommends \
    weston \
    xwayland \
    kbd \
    && apt-get clean && apt-get autoremove && rm -rf /var/lib/apt/lists/*

# If the installed weston is the Toradex version, also install the g2d alternatives.
RUN dpkg-query --show weston | if grep -q toradex ; then \
    apt-get -y update && apt-get install -y --no-install-recommends \
        libg2d-dpu \
        libg2d-dpu-samples \
        libg2d-viv \
        libg2d-viv-samples \
    && apt-get clean && apt-get autoremove && rm -rf /var/lib/apt/lists/* ; else : ; fi

# Refrain dash from taking over the /bin/sh symlink.
# This makes sure that signals get delivered to Weston when using the weston-launch shell script.
RUN echo 'dash dash/sh boolean false' | debconf-set-selections \
    && DEBIAN_FRONTEND=noninteractive DEBCONF_NONINTERACTIVE_SEEN=true dpkg-reconfigure dash \
    && test $(realpath /bin/sh) = '/bin/bash'

# Container entry point and support files.
COPY entry.sh /usr/bin/entry.sh
COPY weston.ini /etc/xdg/weston/weston.ini
COPY weston-dev.ini /etc/xdg/weston-dev/weston.ini
RUN mkdir -p /etc/imx_features
COPY imx_features /etc/imx_features/

# The compositor needs access to input devices
RUN usermod -a -G input torizon

WORKDIR /home/torizon

ENTRYPOINT ["/usr/bin/entry.sh"]
