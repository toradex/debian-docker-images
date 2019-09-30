ARG IMAGE_ARCH=arm32v7
ARG BASE_NAME=$IMAGE_ARCH-debian-wayland-base
FROM torizon/$BASE_NAME:buster

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
ENV ACCEPT_FSL_EULA=""

COPY entry.sh /usr/bin/entry.sh
COPY weston.ini /etc/xdg/weston/weston.ini
COPY Vivante-EULA /etc/Vivante-EULA

ENTRYPOINT sh -c "/usr/bin/entry.sh ${ACCEPT_FSL_EULA:+"--accept-fsl-eula=${ACCEPT_FSL_EULA}"}"
