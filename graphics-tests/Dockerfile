ARG IMAGE_ARCH=linux/arm
ARG BASE_NAME=wayland-base
ARG IMAGE_TAG=2-bullseye
ARG DOCKER_REGISTRY=torizon

FROM --platform=$IMAGE_ARCH $DOCKER_REGISTRY/$BASE_NAME:$IMAGE_TAG AS base

# Install the libdrm-tests.
RUN apt-get -y update && apt-get install -y --no-install-recommends \
    libdrm-tests \
    && apt-get clean && apt-get autoremove && rm -rf /var/lib/apt/lists/*

WORKDIR /home/torizon