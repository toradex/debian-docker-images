ARG IMAGE_ARCH=linux/arm
# For arm64v8 use:
# ARG IMAGE_ARCH=linux/arm64
ARG BASE_NAME=wayland-base
# For arm64v8 with Vivante use:
# ARG BASE_NAME=wayland-base-vivante
ARG IMAGE_TAG=1-bullseye
ARG DOCKER_REGISTRY=torizon
ARG LIBQT5QUICK5="libqt5quick5"

FROM --platform=$IMAGE_ARCH $DOCKER_REGISTRY/$BASE_NAME:$IMAGE_TAG AS base

ARG LIBQT5QUICK5

RUN apt-get -y update && apt-get install -y --no-install-recommends \
    apt-utils \
    && apt-get -y upgrade \
    && apt-get clean && apt-get autoremove && rm -rf /var/lib/apt/lists/*

# Debian Bullseye has higher versions of some same packages than the Toradex feed.
# Force install of Bullseye versions of these packages in order to keep the container equivalent for 32 and 64 bits architectures.
RUN HOLD_PKGS='libdrm-common libdrm-amdgpu1 libdrm2' \
    && apt-get -y update \
    && for P in $HOLD_PKGS ; do \
        echo ${P}=$(apt-cache show $P | sed -r -e '/^Version:/!d' -e 's/.* //' -e '/toradex/d' -e 'q') ; \
    done | xargs -r apt-get install -y --no-install-recommends \
    && apt-mark hold $HOLD_PKGS \
    && apt-get clean && apt-get autoremove && rm -rf /var/lib/apt/lists/*

# qtdeclarative5-examples depends on qml-module-qtquick-dialogs which in turn
# depends on libqt5quick5. For vivante boards we need to install the vivante
# version first to avoid install time conflict.
RUN apt-get -y update && apt-get install -y --no-install-recommends \
    ${LIBQT5QUICK5} \
    && apt-get clean && apt-get autoremove && rm -rf /var/lib/apt/lists/*

# Install Qt5 dependencies required to run qtbase and qtdeclarative examples
RUN apt-get -y update && apt-get install -y --no-install-recommends \
        libqt5concurrent5 \
        libqt5dbus5 \
        libqt5network5 \
        libqt5opengl5 \
        libqt5printsupport5 \
        libqt5sql5 \
        libqt5test5 \
        libqt5widgets5 \
        libqt5xml5 \
        libqt5qml5 \
        libqt5quicktest5 \
        libqt5quickwidgets5 \
        qml-module-qt-labs-qmlmodels \
        qml-module-qtqml-models2 \
        qml-module-qtquick-layouts \
        qml-module-qtquick-localstorage \
        qml-module-qtquick-particles2 \
        qml-module-qtquick-shapes \
        qml-module-qttest \
    && apt-get clean && apt-get autoremove && rm -rf /var/lib/apt/lists/*

# Install QtWayland Qt 5 module
RUN apt-get -y update && apt-get install -y --no-install-recommends \
    qtwayland5 \
    && apt-get clean && apt-get autoremove && rm -rf /var/lib/apt/lists/*

ENV QT_QPA_PLATFORM="wayland"
