ARG IMAGE_ARCH=linux/arm
# For arm64v8 use:
# ARG IMAGE_ARCH=linux/arm64
ARG BASE_NAME=debian
ARG IMAGE_TAG=1-buster
FROM --platform=$IMAGE_ARCH torizon/$BASE_NAME:$IMAGE_TAG AS base

RUN apt-get -y update && apt-get install -y --no-install-recommends \
    apt-utils \
    && apt-mark hold dash && apt-get -y upgrade && apt-mark unhold dash \
    && apt-get clean && apt-get autoremove && rm -rf /var/lib/apt/lists/*

RUN apt-get -y update && apt-get install -y --no-install-recommends \
    libwayland-client0 \
    libwayland-server0 \
    libglx-mesa0 \
    libegl1 \
    mesa-utils-extra \
    && apt-get clean && apt-get autoremove && rm -rf /var/lib/apt/lists/*

# Make sure the user can access DRM and video devices
RUN usermod -a -G video,render torizon

ENV WAYLAND_USER="torizon"
ENV XDG_RUNTIME_DIR="/tmp/1000-runtime-dir"
ENV WAYLAND_DISPLAY="wayland-0"
ENV DISPLAY=":0"