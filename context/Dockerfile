ARG BUILD_FROM=debian:buster-slim

FROM $BUILD_FROM

RUN apt-get update \
	&& echo 'deb http://deb.debian.org/debian buster-backports main' >> /etc/apt/sources.list \
        && apt-get update \
	&& apt-get install -y -qq --no-install-recommends \
	         build-essential \
#                 cmake \
                 curl \
	         git \
	         gnupg2 \
	         golang \
                 libtinfo5 \
                 ninja-build \
	         python3-pip \
	         openssh-client \
                 software-properties-common \
	         virtualenv \
	         wget \
	         zlib1g-dev \
	&& apt-get install -y -qq --no-install-recommends -t buster-backports cmake \
        && useradd \
	     -m \
             -d /home/envoydev \
             -k /etc/skel \
             -s /bin/bash \
	     envoydev \
	&& mkdir -p  /source /build \
        && chown envoydev:envoydev /source /build

COPY ./install.sh /usr/local/bin/install.sh
COPY ./build-docs.sh /usr/local/bin/build-docs.sh

RUN /usr/local/bin/install.sh

USER envoydev
WORKDIR /home/envoydev

USER root
