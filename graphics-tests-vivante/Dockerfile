ARG IMAGE_ARCH=linux/arm64
ARG BASE_NAME=wayland-base-vivante
ARG IMAGE_TAG=3
ARG DOCKER_REGISTRY=torizon
FROM --platform=$IMAGE_ARCH $DOCKER_REGISTRY/$BASE_NAME:$IMAGE_TAG AS base

RUN apt-get -y update && apt-get upgrade &&  apt-get install -y --no-install-recommends \
       kmscube \
       libdrm-tests \
       imx-gpu-viv-demos \
       glmark2-es2-wayland \
    && apt-get clean && apt-get autoremove && rm -rf /var/lib/apt/lists/*

WORKDIR /home/torizon
