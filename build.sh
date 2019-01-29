#!/bin/sh -xe

REPOSITORY=torizon
ARCH=arm32v7

IMAGE_BASE=${REPOSITORY}/${ARCH}-debian-base:buster
IMAGE_WESTON=${REPOSITORY}/${ARCH}-debian-weston:buster

case "$1" in
"build")
	docker build -f base/Dockerfile -t ${IMAGE_BASE} base/
	docker build -f weston/Dockerfile -t ${IMAGE_WESTON} weston/
	;;
"deploy")
	docker push ${IMAGE_BASE}
	docker push ${IMAGE_WESTON}
	;;
*)
	echo "Use \"build\" or \"deploy\" as argument."
	;;
esac
