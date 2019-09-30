ARG IMAGE_ARCH=arm64v8
FROM torizon/$IMAGE_ARCH-debian-base:buster

RUN apt-get -y update && apt-get install -y --no-install-recommends \
    apt-utils \
    && apt-mark hold dash && apt-get -y upgrade && apt-mark unhold dash \
    && apt-get clean && apt-get autoremove && rm -rf /var/lib/apt/lists/*

RUN apt-get -y update && apt-get install -y --no-install-recommends \
    libwayland-client0 \
    libwayland-server0 \
    libgal-vivante1 \
    libvsc-vivante1 \
    libgbm-vivante1 \
    libegl-vivante1 \
    libglesv2-vivante1 \
    libglesv1-cm-vivante1 \
    libglslc-vivante1 \
    && apt-get clean && apt-get autoremove && rm -rf /var/lib/apt/lists/*

ENV XDG_RUNTIME_DIR="/tmp/0-runtime-dir"
ENV WAYLAND_DISPLAY="wayland-0"
ENV DISPLAY=":0"
