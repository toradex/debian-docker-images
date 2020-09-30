ARG IMAGE_ARCH=linux/arm/v7
# For arm64v8 use:
# ARG IMAGE_ARCH=linux/arm64/v8
ARG IMAGE_TAG=bullseye-20200908-slim
ARG DEBIAN_SNAPSHOT=20200908T070000Z
ARG ADD_TORADEX_REPOSITORY=1
FROM --platform=$IMAGE_ARCH debian:$IMAGE_TAG AS base

ARG DEBIAN_FRONTEND=noninteractive
ONBUILD ARG DEBIAN_FRONTEND=noninteractive

# Debian Bullseye is not yet a stable distribution at the moment of this writing;
# therefore its package list may change in incompatible ways with Torizon software.
# Let's lock Torizon containers to a known snapshot of the Bullseye package list as a workaround.
ARG DEBIAN_SNAPSHOT
RUN echo "deb [check-valid-until=no] http://snapshot.debian.org/archive/debian/$DEBIAN_SNAPSHOT bullseye main\n\
deb [check-valid-until=no] http://snapshot.debian.org/archive/debian/$DEBIAN_SNAPSHOT bullseye-updates main\n\
deb [check-valid-until=no] http://snapshot.debian.org/archive/debian-security/$DEBIAN_SNAPSHOT bullseye-security main" >/etc/apt/sources.list

# Upgrade & install required packages
RUN apt-get update \
    && apt-get upgrade -y \
    && apt-get install -y --no-install-recommends \
        sudo \
        ca-certificates \
        netbase \
    && apt-get clean \
    && apt-get autoremove \
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

FROM base as add_toradex-repository-0

FROM base as add_toradex-repository-1

# Enable the Toradex package feed
# (same key is used in https://gitlab.int.toradex.com/rd/torizon-core-containers/debian-cross-toolchains
# if you change the key or feed configuration, please check the other repo!)
ADD https://feeds.toradex.com/debian/toradex-debian-repo.gpg /etc/apt/trusted.gpg.d/
RUN chmod 0644 /etc/apt/trusted.gpg.d/toradex-debian-repo.gpg \
    && echo "deb https://feeds.toradex.com/debian/ testing main non-free" >>/etc/apt/sources.list \
    && echo "Package: *\nPin: origin feeds.toradex.com\nPin-Priority: 900" > /etc/apt/preferences.d/toradex-feeds

FROM add_toradex-repository-${ADD_TORADEX_REPOSITORY}
