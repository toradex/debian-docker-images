ARG IMAGE_ARCH=arm64v8
FROM torizon/$IMAGE_ARCH-debian-base:buster

RUN apt-get -y update && apt-get install -y --no-install-recommends \
    apt-utils \
    && apt-mark hold dash && apt-get -y upgrade && apt-mark unhold dash \
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
