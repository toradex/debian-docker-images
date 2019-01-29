FROM torizon/arm32v7-debian-base:buster

RUN apt-get -y update && apt-get install -y --no-install-recommends \
    apt-utils \
    && apt-mark hold dash && apt-get -y upgrade && apt-mark unhold dash \
    && apt-get clean && apt-get autoremove && rm -rf /var/lib/apt/lists/*

RUN apt-get -y update && apt-get install -y --no-install-recommends \
    vim-tiny \
    less \
    kmod \
    wget \
    usbutils \
    debconf \
    udev \
    && apt-get clean && apt-get autoremove && rm -rf /var/lib/apt/lists/*

RUN apt-get -y update && apt-get install -y --no-install-recommends \
    weston \
    libglx-mesa0 \
    libegl1 \
    mesa-utils-extra \
    suckless-tools \
    && apt-get clean && apt-get autoremove && rm -rf /var/lib/apt/lists/*

ENV UDEV 1

COPY entry.sh /usr/bin/entry.sh
ENTRYPOINT ["/usr/bin/entry.sh"]
