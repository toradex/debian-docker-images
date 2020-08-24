ARG IMAGE_ARCH=linux/arm
# For arm64v8 use:
# ARG IMAGE_ARCH=linux/arm64
ARG BASE_NAME=debian
ARG IMAGE_TAG=1-buster
FROM --platform=$IMAGE_ARCH torizon/$BASE_NAME:$IMAGE_TAG AS base

RUN apt-get -y update && apt-get install -y --no-install-recommends\
    docker-compose \
    && apt-get clean && apt-get autoremove && rm -rf /var/lib/apt/lists/*