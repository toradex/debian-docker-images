ARG IMAGE_ARCH=arm32v7
ARG BASE_NAME=$IMAGE_ARCH-debian-wayland-base
FROM torizon/$BASE_NAME:buster

RUN apt-get -y update && apt-get install -y --no-install-recommends\
    apt-utils \
    && apt-mark hold dash && apt-get -y upgrade && apt-mark unhold dash \
    && apt-get clean && apt-get autoremove && rm -rf /var/lib/apt/lists/*

RUN apt-get -y update && apt-get install -y --no-install-recommends \
    weston \
    xwayland \
    && apt-get clean && apt-get autoremove && rm -rf /var/lib/apt/lists/*

COPY entry.sh /usr/bin/entry.sh
COPY weston.ini /etc/xdg/weston/weston.ini
COPY weston-dev.ini /etc/xdg/weston-dev/weston.ini

# The compositor needs access to input devices
RUN usermod -a -G input torizon

ENTRYPOINT ["/usr/bin/entry.sh"]
