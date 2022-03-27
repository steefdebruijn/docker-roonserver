FROM debian:buster-20211011-slim
MAINTAINER steef@debruijn.ws

RUN apt-get update \
        && apt-get -y upgrade \
        && apt-get -y install bash curl bzip2 ffmpeg cifs-utils alsa-utils

ENV ROON_SERVER_PKG RoonServer_linuxx64.tar.bz2
ENV ROON_SERVER_URL https://download.roonlabs.net/builds/${ROON_SERVER_PKG}
ENV ROON_DATAROOT /data
ENV ROON_ID_DIR /data

VOLUME [ "/app", "/data", "/music", "/backup" ]

ADD run.sh /
ENTRYPOINT /run.sh

