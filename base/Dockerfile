ARG IMAGE_ARCH=linux/arm/v7
# For arm64v8 use:
# ARG IMAGE_ARCH=linux/arm64/v8
ARG IMAGE_TAG=10.4-slim
FROM --platform=$IMAGE_ARCH debian:$IMAGE_TAG AS base

ARG DEBIAN_FRONTEND=noninteractive
ONBUILD ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y --no-install-recommends \
    sudo \
    ca-certificates \
    netbase \
    && rm -rf /var/lib/apt/lists/*

ENV LC_ALL C.UTF-8

# Create 01_nodoc
ADD 01_nodoc /etc/dpkg/dpkg.cfg.d/01_nodoc

# Create 01_buildconfig
RUN echo 'APT::Get::Assume-Yes "true";\n\
    APT::Install-Recommends "0";\n\
    APT::Install-Suggests "0";\n\
    quiet "true";' > /etc/apt/apt.conf.d/01_buildconfig

RUN mkdir -p /usr/share/man/man1

RUN groupadd --gid 101 input
RUN groupadd --gid 102 kvm
RUN groupadd --gid 103 render
RUN groupadd --gid 49 gpio
RUN groupadd --gid 51 i2cdev
RUN groupadd --gid 52 spidev

# Add user and group torizon with id matching those used by the host os
RUN groupadd --gid 1000 torizon \
    && useradd --gid 1000 --uid 1000 --create-home torizon

# Adds Toradex feeds and gpg key
# (same key is used in https://gitlab.int.toradex.com/rd/torizon-core-containers/debian-cross-toolchains
# if you change the key or feed configuration, please check the other repo!)
ADD https://feeds.toradex.com/debian/toradex-debian-repo.pub /etc/apt/trusted.gpg.d/toradex-buster.asc



ARG ADD_TORADEX_REPOSITORY=1
RUN if [ "$ADD_TORADEX_REPOSITORY" = "1" ]; then \
    chmod 644 /etc/apt/trusted.gpg.d/toradex-buster.asc ;\
    echo "deb https://feeds.toradex.com/debian/testing/ buster main" >> /etc/apt/sources.list ; \
    echo "Package: *\nPin: origin feeds.toradex.com\nPin-Priority: 900" > /etc/apt/preferences.d/toradex-feeds ; \
    fi