ARG IMAGE_ARCH=arm32v7
ARG BASE_NAME=$IMAGE_ARCH-debian-qt5-wayland

ARG QT5_EXAMPLES_DEBIAN
ARG QT5_EXAMPLES_VIVANTE
ARG QT5_EXAMPLES_DEBIAN_INSTALL=${QT5_EXAMPLES_DEBIAN:+"qtbase5-examples qtdeclarative5-examples"}
ARG QT5_EXAMPLES_VIVANTE_INSTALL=${QT5_EXAMPLES_VIVANTE:+"qtbase5-vivante-examples qtdeclarative5-vivante-examples"}

FROM torizon/$BASE_NAME:buster
ARG QT5_EXAMPLES_DEBIAN_INSTALL
ARG QT5_EXAMPLES_VIVANTE_INSTALL

RUN apt-get -y update && apt-get install -y --no-install-recommends \
    ${QT5_EXAMPLES_DEBIAN_INSTALL} ${QT5_EXAMPLES_VIVANTE_INSTALL} \
    && apt-get clean && apt-get autoremove && rm -rf /var/lib/apt/lists/*
