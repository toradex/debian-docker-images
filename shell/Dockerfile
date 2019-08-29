ARG IMAGE_ARCH=arm32v7
FROM torizon/$IMAGE_ARCH-debian-base:buster

RUN apt-get -y update && apt-get install -y --no-install-recommends\
    findutils \
    gnupg \
    dirmngr \
    inetutils-ping \
    netbase \
    curl \
    iproute2 \
    && apt-get clean && apt-get autoremove && rm -rf /var/lib/apt/lists/*
