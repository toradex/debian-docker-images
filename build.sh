#!/bin/sh -xe

REPOSITORY=torizon
ARCH=arm32v7

IMAGE_BASE=${REPOSITORY}/${ARCH}-debian-base:buster
IMAGE_WESTON=${REPOSITORY}/${ARCH}-debian-weston:buster
IMAGE_WAYLAND_CLIENT=${REPOSITORY}/${ARCH}-debian-wayland-client:buster
IMAGE_QT5_WAYLAND=${REPOSITORY}/${ARCH}-debian-qt5-wayland:buster

case "$1" in
"build")
    docker build -f base/Dockerfile -t ${IMAGE_BASE} base/
    docker build -f weston/Dockerfile -t ${IMAGE_WESTON} weston/
    docker build -f wayland-client/Dockerfile -t ${IMAGE_WAYLAND_CLIENT} wayland-client/
    docker build -f qt5-wayland/Dockerfile -t ${IMAGE_QT5_WAYLAND} qt5-wayland/
    ;;
"deploy")
    docker push ${IMAGE_BASE}
    docker push ${IMAGE_WESTON}
    docker push ${IMAGE_WAYLAND_CLIENT}
    docker push ${IMAGE_QT5_WAYLAND}
    ;;
*)
    echo "Use \"build\" or \"deploy\" as argument."
    ;;
esac
