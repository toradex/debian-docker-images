ARG IMAGE_ARCH=linux/arm
# For arm64v8 use:
# ARG IMAGE_ARCH=linux/arm64
ARG BASE_NAME=wayland-base
# For arm64v8 with Vivante use:
# ARG BASE_NAME=wayland-base-vivante
ARG IMAGE_TAG=2-bullseye
ARG DOCKER_REGISTRY=torizon
FROM --platform=$IMAGE_ARCH $DOCKER_REGISTRY/$BASE_NAME:$IMAGE_TAG AS base

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

# Decide whether to install the Toradex or the Debian version of libqt5gui5-gles.
# The Toradex version pulls Vivante dependencies, so it should be avoided in non-Vivante containers.
RUN apt-get -y update \
    && if dpkg -s libegl-vivante1 ; \
    then \
        echo "Installing libqt5gui5-gles from Toradex feed." 1>&2 \
        && apt-get install -y --no-install-recommends libqt5gui5-gles ; \
    else \
        echo "Forcing libqt5gui5-gles from Debian feed." 1>&2 \
        && apt-get install -y --no-install-recommends libqt5gui5-gles=$(apt-cache show libqt5gui5-gles | sed -r -e '/^Version:/!d' -e 's/.* //' -e '/toradex/d' -e 'q') \
        && apt-mark hold libqt5gui5-gles ; \
    fi \
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
        && apt-get -y remove binutils xz-utils ; \
    fi \
    && apt-get clean && apt-get autoremove && rm -rf /var/lib/apt/lists/*

# Install remaining dependencies required to run qtbase and qtdeclarative examples
RUN apt-get -y update && apt-get install -y --no-install-recommends \
        libqt5quick5-gles \
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
