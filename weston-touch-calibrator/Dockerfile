# First stage: build the package
ARG IMAGE_ARCH=arm32v7
# Second stage: create the final container
ARG BASE_NAME=$IMAGE_ARCH-debian-weston
FROM gitlab.int.toradex.com:4567/rd/torizon-core/debian/debian-package-devel/$IMAGE_ARCH-debian-package-devel:buster
WORKDIR /weston/
# The toradex feed generate an error when trying to install build-dep weston
RUN sed -i 's/\(.*feeds.toradex.com.*\)/# \1/' /etc/apt/sources.list
RUN echo "deb-src http://http.us.debian.org/debian buster main" >> /etc/apt/sources.list && \
    echo "deb-src https://feeds.toradex.com/debian/testing/ buster main" >> /etc/apt/sources.list
RUN apt-get -y update && apt-get -y source weston && apt-get -y build-dep weston
COPY control /weston/
COPY weston-touch-calibrator.install /weston/
RUN cp /weston/control weston-5.0.0/debian/ && cp /weston/weston-touch-calibrator.install weston-5.0.0/debian/
RUN cd weston-5.0.0/ && dpkg-buildpackage -nc --no-sign

FROM torizon/$BASE_NAME:latest
WORKDIR /weston-touch-calibrator
# Copy deb from previous stage
COPY --from=0 /weston/weston-touch-calibrator_5.0.0-3_*.deb .
# arm64 is missing these libraries, install them
RUN apt-get -y update && apt-get install -y --no-install-recommends \
    libpangocairo-1.0-0 \
    libjpeg62-turbo \
    && apt-get clean && apt-get autoremove && rm -rf /var/lib/apt/lists/*

RUN dpkg -i weston-touch-calibrator_5.0.0-3_*.deb && rm weston-touch-calibrator_5.0.0-3_*.deb

COPY entry.sh /usr/bin/
RUN mkdir -p /etc/xdg/weston/
COPY weston.ini /etc/xdg/weston/
COPY save-calibration.sh /usr/bin/

USER root

ENTRYPOINT ["/usr/bin/entry.sh"]
