ARG IMAGE_ARCH=linux/arm
# For arm64v8 use:
# ARG IMAGE_ARCH=linux/arm64
ARG BASE_NAME=debian
ARG IMAGE_TAG=2-bullseye
ARG DOCKER_REGISTRY=torizon
FROM --platform=$IMAGE_ARCH $DOCKER_REGISTRY/$BASE_NAME:$IMAGE_TAG AS base

RUN apt-get -y update && apt-get install -y --no-install-recommends\
    findutils \
    gnupg \
    dirmngr \
    inetutils-ping \
    netbase \
    curl \
    iproute2 \
    && apt-get clean && apt-get autoremove && rm -rf /var/lib/apt/lists/*
