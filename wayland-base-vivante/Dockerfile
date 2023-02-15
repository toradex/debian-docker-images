ARG IMAGE_ARCH=linux/arm64
ARG BASE_NAME=debian
ARG IMAGE_TAG=3-bookworm
ARG DOCKER_REGISTRY=torizon
FROM --platform=$IMAGE_ARCH $DOCKER_REGISTRY/$BASE_NAME:$IMAGE_TAG AS base

RUN apt-get -y update && apt-get install -y --no-install-recommends \
    apt-utils \
    curl \
    html2text \
    && apt-get -y upgrade \
    && apt-get clean && apt-get autoremove && rm -rf /var/lib/apt/lists/*

ARG LIC_URL=https://www.nxp.com/docs/en/disclaimer/LA_OPT_NXP_SW.html
ARG LIC_FILE_HTML=LA_OPT_NXP_SW.html
ARG LIC_FILE_TXT=LA_OPT_NXP_SW.txt
RUN curl -sSf ${LIC_URL} --output /etc/${LIC_FILE_HTML} \
    && html2text -o /etc/${LIC_FILE_TXT} /etc/${LIC_FILE_HTML} \
    && grep -q "NXP Software License Agreement" /etc/${LIC_FILE_TXT}
ARG ACCEPT_FSL_EULA=0
RUN if [ "${ACCEPT_FSL_EULA}" != "1" ];then \
        echo "Error: This image contains Vivante Packages."; \
        echo "Use --build-arg ACCEPT_FSL_EULA=1 to accept Vivante EULA"; \
        exit 1; \
    else \
        echo "INFO: Vivante EULA has been accepted!"; \
    fi

RUN apt-get -y update && apt-get install -y --no-install-recommends \
    libwayland-client0 \
    libwayland-server0 \
    imx-gpu-viv-wayland \
    libg2d-dpu \
    libg2d-viv \
    && apt-get clean && apt-get autoremove && rm -rf /var/lib/apt/lists/*

# Make sure the user can access DRM and video devices
RUN usermod -a -G video,render torizon

ENV WAYLAND_USER="torizon"
ENV XDG_RUNTIME_DIR="/tmp/1000-runtime-dir"
ENV WAYLAND_DISPLAY="wayland-0"
ENV DISPLAY=":0"

COPY nxp-eula.sh /etc/profile.d/nxp-eula.sh

# workaround "Failed to load module: /usr/lib/libgbm.so" error in downstream weston.
RUN ln -s /usr/lib/aarch64-linux-gnu/libgbm.so /usr/lib/libgbm.so

CMD [ "bash", "-l" ]
