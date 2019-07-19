ARG IMAGE_ARCH=arm32v7
FROM $IMAGE_ARCH/debian:buster-slim

ARG DEBIAN_FRONTEND=noninteractive
ONBUILD ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y --no-install-recommends \
    sudo \
    ca-certificates \
    netbase \
    && rm -rf /var/lib/apt/lists/*

ENV LC_ALL C.UTF-8

# Create 01_nodoc
ADD 01_nodoc /etc/dpkg/dpkg.cfg.d/01_nodoc

# Create 01_buildconfig
RUN echo 'APT::Get::Assume-Yes "true";\n\
    APT::Install-Recommends "0";\n\
    APT::Install-Suggests "0";\n\
    quiet "true";' > /etc/apt/apt.conf.d/01_buildconfig

RUN mkdir -p /usr/share/man/man1

# Add user and group torizon with id matching those used by the host os
RUN groupadd --gid 1000 torizon \
    && useradd --gid 1000 --uid 1000 -M torizon

COPY toradex-buster.gpg /etc/apt/trusted.gpg.d/

ARG ADD_TORADEX_REPOSITORY=0
RUN if [ "$ADD_TORADEX_REPOSITORY" = "1" ]; then \
    echo "deb https://feeds.toradex.com/debian/testing/ buster main" >> /etc/apt/sources.list ; \
    echo -e "Package: *\nPin: origin feeds.toradex.com\nPin-Priority: 900" > /etc/apt/preferences.d/toradex-feeds ; \
    fi
