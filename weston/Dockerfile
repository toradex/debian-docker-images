ARG IMAGE_ARCH=arm32v7
FROM torizon/$IMAGE_ARCH-debian-wayland-base:buster

RUN apt-get -y update && apt-get install -y --no-install-recommends\
    apt-utils \
    && apt-mark hold dash && apt-get -y upgrade && apt-mark unhold dash \
    && apt-get clean && apt-get autoremove && rm -rf /var/lib/apt/lists/*

RUN apt-get -y update && apt-get install -y --no-install-recommends \
    udev \
    weston \
    xwayland \
    && apt-get clean && apt-get autoremove && rm -rf /var/lib/apt/lists/*

ENV UDEV 1

COPY entry.sh /usr/bin/entry.sh
COPY weston.ini /etc/xdg/weston/weston.ini

ENTRYPOINT ["/usr/bin/entry.sh"]
