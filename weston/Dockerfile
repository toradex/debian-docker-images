ARG IMAGE_ARCH=linux/arm
# For arm64 use:
# ARG IMAGE_ARCH=linux/arm64
ARG BASE_NAME=wayland-base
# For arm64v8 use: 
# ARG BASE_NAME=wayland-base-vivante
ARG WESTON=weston
ARG IMAGE_TAG=1
FROM --platform=$IMAGE_ARCH torizon/$BASE_NAME:$IMAGE_TAG AS base

ARG WESTON

RUN apt-get -y update && apt-get install -y --no-install-recommends \
    ${WESTON} \
    xwayland \
    kbd \
    && apt-get clean && apt-get autoremove && rm -rf /var/lib/apt/lists/*

COPY entry.sh /usr/bin/entry.sh
COPY weston.ini /etc/xdg/weston/weston.ini
COPY weston-dev.ini /etc/xdg/weston-dev/weston.ini

# Work around Weston issue by using bash instead of dash
# see https://gitlab.freedesktop.org/wayland/weston/merge_requests/294
RUN ln -sf bash /bin/sh

# The compositor needs access to input devices
RUN usermod -a -G input torizon

WORKDIR /home/torizon

ENTRYPOINT ["/usr/bin/entry.sh"]