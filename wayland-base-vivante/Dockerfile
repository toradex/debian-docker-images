ARG IMAGE_ARCH=linux/arm64
ARG BASE_NAME=debian
ARG IMAGE_TAG=1-bullseye
ARG DOCKER_REGISTRY=torizon
FROM --platform=$IMAGE_ARCH $DOCKER_REGISTRY/$BASE_NAME:$IMAGE_TAG AS base

RUN apt-get -y update && apt-get install -y --no-install-recommends \
    apt-utils \
    && apt-get -y upgrade \
    && apt-get clean && apt-get autoremove && rm -rf /var/lib/apt/lists/*

ARG ACCEPT_FSL_EULA=0
RUN if [ "${ACCEPT_FSL_EULA}" != "1" ];then \
        echo -n "Error: This image contains Vivante Packages. "; \
        echo "Use --build-arg ACCEPT_FSL_EULA=1 to accept Vivante EULA"; \
        exit 1; \
    else \
        echo "INFO: Vivante EULA has been accepted!"; \
    fi

RUN apt-get -y update && apt-get install -y --no-install-recommends \
    libwayland-client0 \
    libwayland-server0 \
    libgal-vivante1 \
    libvsc-vivante1 \
    libgbm-vivante1 \
    libegl-vivante1 \
    libgl-vivante1 \
    libglesv2-vivante1 \
    libglesv1-cm-vivante1 \
    libglslc-vivante1 \
    && apt-get clean && apt-get autoremove && rm -rf /var/lib/apt/lists/*

# Make sure the user can access DRM and video devices
RUN usermod -a -G video,render torizon

ENV XDG_RUNTIME_DIR="/tmp/1000-runtime-dir"
ENV WAYLAND_DISPLAY="wayland-0"
ENV DISPLAY=":0"

COPY nxp-eula.sh /etc/profile.d/nxp-eula.sh

CMD [ "bash", "-l" ]
