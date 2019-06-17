FROM torizon/arm32v7-debian-base:buster

RUN apt-get -y update && apt-get install -y --no-install-recommends\
    findutils \
    gnupg \
    dirmngr \
    inetutils-ping \
    netbase \
    curl \
    udev \
    iproute2 \
    && apt-get clean && apt-get autoremove && rm -rf /var/lib/apt/lists/*
