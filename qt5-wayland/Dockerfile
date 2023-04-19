ARG IMAGE_ARCH=linux/arm
# For arm64v8 use:
# ARG IMAGE_ARCH=linux/arm64
ARG BASE_NAME=wayland-base
# For arm64v8 with Vivante use:
# ARG BASE_NAME=wayland-base-vivante
ARG IMAGE_TAG=3
ARG DOCKER_REGISTRY=torizon
FROM --platform=$IMAGE_ARCH $DOCKER_REGISTRY/$BASE_NAME:$IMAGE_TAG AS base

COPY kms-setup.sh /usr/bin/kms-setup.sh

RUN apt-get -y update && apt-get install -y --no-install-recommends \
    apt-utils \
    && apt-get -y upgrade \
    && apt-get clean && apt-get autoremove && rm -rf /var/lib/apt/lists/*

# Install libqt5gui5-gles before libqt5opengl5 which also has an alternate dependency on libqt5gui5(non-gles)
RUN apt-get -y update  && apt-get install -y --no-install-recommends libqt5gui5-gles \
    && apt-get clean && apt-get autoremove && rm -rf /var/lib/apt/lists/*

# Install libqt5opengl5.
# Under Bullesyse, libqt5opengl5:arm64 is currently at version 5.14.2+dfsg-6 and contains a redundant dependency for libqt5gui5 (>= 5.1.0):
#
# $ apt-cache show libqt5opengl5 | grep ^Depends:
# Depends: libc6 (>= 2.17), libqt5core5a (>= 5.14.1), libqt5gui5 (>= 5.1.0), libqt5gui5 (>= 5.12.5) | libqt5gui5-gles (>= 5.12.5), libqt5widgets5 (>= 5.9.0~beta), libstdc++6 (>= 5), qtbase-abi-5-14-2
# 
# This forbids installing qtbase5-examples with libqt5gui5-gles.
# Workaround the issue by mangling the package file and remove the leftover dependency.
RUN apt-get -y update \
    && if test "$(uname -m)" = 'armv7l' ; \
    then \
        apt-get -y install --no-install-recommends libqt5opengl5 ; \
    else \
        apt-get -y install --no-install-recommends binutils xz-utils \
        && WORK_DIR=$(mktemp -d) \
        && cd $WORK_DIR \
        && apt-get download libqt5opengl5 \
        && ar x libqt5opengl5_*_arm64.deb \
        && tar -xJf control.tar.xz \
        && sed -i '/^Depends:/s/, libqt5gui5 (>= 5.1.0)//' control \
        && tar -cJf control.tar.xz control md5sums shlibs symbols triggers \
        && ar rcs libqt5opengl5.deb debian-binary control.tar.xz data.tar.xz \
        && apt-get -y install --no-install-recommends ./libqt5opengl5.deb \
        && cd ~ \
        && rm -rf $WORK_DIR \
        && apt-get -y remove binutils xz-utils \
        && apt-mark hold libqt5opengl5 ; \
    fi \
    && apt-get clean && apt-get autoremove && rm -rf /var/lib/apt/lists/*

# Install remaining dependencies required to run qtbase and qtdeclarative examples
RUN apt-get -y update && apt-get install -y --no-install-recommends \
        libfontconfig1-dev \
        libqt5quick5-gles \
        libqt5quickparticles5-gles \
        libqt5concurrent5 \
        libqt5dbus5 \
        libqt5network5 \
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

# Install Wayland Qt module
RUN apt-get -y update && apt-get install -y --no-install-recommends \
    qtwayland5 \
    && apt-get clean && apt-get autoremove && rm -rf /var/lib/apt/lists/*

ENV QT_QPA_PLATFORM="wayland"

# EGLFS configuration
ENV QT_QPA_EGLFS_INTEGRATION="eglfs_kms"
ENV QT_QPA_EGLFS_KMS_ATOMIC="1"
ENV QT_QPA_EGLFS_KMS_CONFIG="/etc/kms.conf"
