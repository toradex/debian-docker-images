ARG IMAGE_ARCH=linux/arm
# For arm64v8 use:
# ARG IMAGE_ARCH=linux/arm64
ARG BASE_NAME=qt5-wayland
# For arm64v8 with Vivante use:
# ARG BASE_NAME=qt5-wayland-vivante
ARG IMAGE_TAG=3
ARG DOCKER_REGISTRY=torizon

ARG QT5_EXAMPLES_DEBIAN
# Uncomment the line below if building outside of the context of GitLab CI
# ARG QT5_EXAMPLES_DEBIAN=1
ARG QT5_EXAMPLES_DEBIAN_INSTALL=${QT5_EXAMPLES_DEBIAN:+"qtbase5-examples qtdeclarative5-examples"}

FROM --platform=$IMAGE_ARCH $DOCKER_REGISTRY/$BASE_NAME:$IMAGE_TAG AS base
ARG QT5_EXAMPLES_DEBIAN_INSTALL

RUN apt-get -y update && apt-get install -y --no-install-recommends \
    ${QT5_EXAMPLES_DEBIAN_INSTALL} \
    && apt-get clean && apt-get autoremove && rm -rf /var/lib/apt/lists/*
