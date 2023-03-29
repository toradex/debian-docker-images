ARG IMAGE_ARCH=linux/arm
ARG BASE_NAME=wayland-base
ARG IMAGE_TAG=3
ARG DOCKER_REGISTRY=torizon

FROM --platform=$IMAGE_ARCH $DOCKER_REGISTRY/$BASE_NAME:$IMAGE_TAG AS base

# Install the libdrm-tests, kmscube and glmark2
RUN apt-get -y update && apt-get install -y --no-install-recommends \
    libdrm-tests \
    kmscube \
    glmark2-es2-wayland \
    && apt-get clean && apt-get autoremove && rm -rf /var/lib/apt/lists/*

WORKDIR /home/torizon
