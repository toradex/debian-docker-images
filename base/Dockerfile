FROM arm32v7/debian:buster-slim

RUN apt-get update && apt-get install -y --no-install-recommends \
    sudo \
    ca-certificates \
    findutils \
    gnupg \
    dirmngr \
    inetutils-ping \
    netbase \
    curl \
    udev \
    iproute2 \
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

ENTRYPOINT ["/bin/bash"]
