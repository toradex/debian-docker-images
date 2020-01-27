ARG IMAGE_ARCH=arm32v7
ARG BASE_NAME=$IMAGE_ARCH-debian-wayland-base
FROM torizon/$BASE_NAME:buster

RUN apt-get -y update && apt-get install -y --no-install-recommends \
    weston \
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
