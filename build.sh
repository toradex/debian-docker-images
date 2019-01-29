#!/bin/sh -xe

REPOSITORY=torizon
ARCH=arm32v7

IMAGE_BASE=${REPOSITORY}/${ARCH}-debian-base:buster

case "$1" in
"build")
	docker build -f base/Dockerfile -t ${IMAGE_BASE} base/
	;;
"deploy")
	docker push ${IMAGE_BASE}
	;;
*)
	echo "Use \"build\" or \"deploy\" as argument."
	;;
esac
