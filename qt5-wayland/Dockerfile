ARG IMAGE_ARCH=arm32v7
ARG BASE_NAME=$IMAGE_ARCH-debian-wayland-base
ARG LIBQT5QUICK5="libqt5quick5"
ARG QT5_DEPS_DEBIAN
ARG QT5_DEPS_VIVANTE
ARG QT5_DEPS_DEBIAN_INSTALL=${QT5_DEPS_DEBIAN:+"libqt5concurrent5 \
    libqt5opengl5 \
    libqt5printsupport5 \
    libqt5quickparticles5 \
    libqt5quicktest5 \
    libqt5quickwidgets5 \
    libqt5sql5 \
    libqt5sql5-sqlite \
    libqt5test5 \
    libqt5widgets5 \
    libqt5xml5 \
    libqt5xmlpatterns5 \
    qml-module-qtqml-models2 \
    qml-module-qtquick-dialogs \
    qml-module-qtquick-layouts \
    qml-module-qtquick-localstorage \
    qml-module-qtquick-particles2 \
    qml-module-qtquick-privatewidgets \
    qml-module-qtquick-window2 \
    qml-module-qtquick-xmllistmodel \
    qml-module-qtquick2 \
    qml-module-qttest"}

ARG QT5_DEPS_VIVANTE_INSTALL=${QT5_DEPS_VIVANTE:+"libqt5concurrent5-vivante \
    libqt5opengl5-vivante \
    libqt5printsupport5-vivante \
    libqt5quickparticles5-vivante \
    libqt5quicktest5-vivante \
    libqt5quickwidgets5-vivante \
    libqt5sql5-vivante \
    libqt5sql5-vivante-sqlite \
    libqt5test5-vivante \
    libqt5widgets5-vivante \
    libqt5xml5-vivante \
    libqt5xmlpatterns5 \
    qml-module-qtqml-models2-vivante \
    qml-module-qtquick-dialogs \
    qml-module-qtquick-layouts-vivante \
    qml-module-qtquick-localstorage-vivante \
    qml-module-qtquick-particles2-vivante \
    qml-module-qtquick-privatewidgets \
    qml-module-qtquick-window2-vivante \
    qml-module-qtquick-xmllistmodel-vivante \
    qml-module-qtquick2-vivante \
    qml-module-qttest-vivante"}

FROM torizon/$BASE_NAME:buster

ARG LIBQT5QUICK5
ARG QT5_DEPS_DEBIAN_INSTALL
ARG QT5_DEPS_VIVANTE_INSTALL

RUN apt-get -y update && apt-get install -y --no-install-recommends \
    apt-utils \
    && apt-mark hold dash && apt-get -y upgrade && apt-mark unhold dash \
    && apt-get clean && apt-get autoremove && rm -rf /var/lib/apt/lists/*

# qtdeclarative5-examples depends on qml-module-qtquick-dialogs which in turn
# depends on libqt5quick5. For vivante boards we need to install the vivante
# version first to avoid install time conflict.
RUN apt-get -y update && apt-get install -y --no-install-recommends \
    ${LIBQT5QUICK5} \
    && apt-get clean && apt-get autoremove && rm -rf /var/lib/apt/lists/*

# Install Qt5 dependencies required to run qtbase and qtdeclarative examples
RUN apt-get -y update && apt-get install -y --no-install-recommends \
    ${QT5_DEPS_DEBIAN_INSTALL} ${QT5_DEPS_VIVANTE_INSTALL} \
    && apt-get clean && apt-get autoremove && rm -rf /var/lib/apt/lists/*

# Install QtWayland Qt 5 module
RUN apt-get -y update && apt-get install -y --no-install-recommends \
    qtwayland5 \
    && apt-get clean && apt-get autoremove && rm -rf /var/lib/apt/lists/*

ENV QT_QPA_PLATFORM="wayland"
