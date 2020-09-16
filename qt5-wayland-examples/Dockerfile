ARG IMAGE_ARCH=linux/arm
# For arm64v8 use:
# ARG IMAGE_ARCH=linux/arm64
ARG BASE_NAME=qt5-wayland
# For arm64v8 with Vivante use:
# ARG BASE_NAME=qt5-wayland-vivante
ARG IMAGE_TAG=2

ARG QT5_EXAMPLES_DEBIAN
ARG QT5_EXAMPLES_VIVANTE
ARG QT5_EXAMPLES_DEBIAN_INSTALL=${QT5_EXAMPLES_DEBIAN:+"qtbase5-examples qtdeclarative5-examples"}
ARG QT5_EXAMPLES_VIVANTE_INSTALL=${QT5_EXAMPLES_VIVANTE:+"qtbase5-vivante-examples qtdeclarative5-vivante-examples"}

FROM --platform=$IMAGE_ARCH torizon/$BASE_NAME:$IMAGE_TAG AS base
ARG QT5_EXAMPLES_DEBIAN_INSTALL
ARG QT5_EXAMPLES_VIVANTE_INSTALL

RUN apt-get -y update && apt-get install -y --no-install-recommends \
    ${QT5_EXAMPLES_DEBIAN_INSTALL} ${QT5_EXAMPLES_VIVANTE_INSTALL} \
    && apt-get clean && apt-get autoremove && rm -rf /var/lib/apt/lists/*
