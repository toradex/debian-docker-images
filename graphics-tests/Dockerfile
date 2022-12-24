ARG IMAGE_ARCH=linux/arm
ARG BASE_NAME=wayland-base
ARG IMAGE_TAG=2
ARG DOCKER_REGISTRY=torizon

FROM --platform=$IMAGE_ARCH $DOCKER_REGISTRY/$BASE_NAME:$IMAGE_TAG AS base

# The components we install and what they test
# kmscube: DRM/KMS
# libdrm-tests: DRM/KMS
# glmark2: OpenGL
# clinfo: OpenCL
# OpenImageIO: includes an image comparison tool
RUN apt-get -y update && apt-get install -y --no-install-recommends \
        kmscube \
        libdrm-tests \
        glmark2-es-wayland \
        clinfo \
        openimageio-tools \
    && apt-get clean && apt-get autoremove && rm -rf /var/lib/apt/lists/*

WORKDIR /home/torizon
