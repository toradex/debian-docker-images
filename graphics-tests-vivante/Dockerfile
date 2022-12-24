ARG IMAGE_ARCH=linux/arm64
ARG BASE_NAME=wayland-base-vivante
ARG IMAGE_TAG=2
ARG DOCKER_REGISTRY=torizon

FROM --platform=$IMAGE_ARCH $DOCKER_REGISTRY/$BASE_NAME:$IMAGE_TAG AS base

# The components we install and what they test
# kmscube: DRM/KMS
# libdrm-tests: DRM/KMS
# glmark2: OpenGL
# clinfo: OpenCL
RUN apt-get -y update && apt-get upgrade &&  apt-get install -y --no-install-recommends \
        kmscube \
        libdrm-tests \
        imx-gpu-viv-demos \
        libg2d-dpu-samples \
        libg2d-viv-samples \
        glmark2-es-wayland \
        clinfo \
    && apt-get clean && apt-get autoremove && rm -rf /var/lib/apt/lists/*

WORKDIR /home/torizon
