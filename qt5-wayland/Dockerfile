ARG IMAGE_ARCH=arm32v7
FROM torizon/$IMAGE_ARCH-debian-wayland-base:buster

RUN apt-get -y update && apt-get install -y --no-install-recommends \
    apt-utils \
    && apt-mark hold dash && apt-get -y upgrade && apt-mark unhold dash \
    && apt-get clean && apt-get autoremove && rm -rf /var/lib/apt/lists/*

RUN apt-get -y update && apt-get install -y --no-install-recommends \
    qtwayland5 \
    qtbase5-examples \
    && apt-get clean && apt-get autoremove && rm -rf /var/lib/apt/lists/*


ENV QT_QPA_PLATFORM="wayland"
