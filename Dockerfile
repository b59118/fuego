# ==============================================================================
# WARNING: this Dockerfile assumes that the container will be created with
# several volume bind mounts (see docker-create-container.sh)
# ==============================================================================

FROM debian:jessie
MAINTAINER tim.bird@sony.com

# ==============================================================================
# Prepare basic image
# ==============================================================================

ARG DEBIAN_FRONTEND=noninteractive

COPY setup/apt/sources/fuego-debian-jessie.list \
        /etc/apt/sources.list.d/fuego-debian-jessie.list
RUN apt-get update && \
    apt-get -yV install \
        apt-utils \
        at \
        autoconf \
        automake \
        bc \
        bsdmainutils \
        bzip2 \
        cmake \
        curl \
        daemon \
        diffstat \
        g++ \
        gcc \
        gettext \
        git \
        inotify-tools \
        iperf \
        lava-tool \
        libaio-dev \
        libcairo2-dev \
        libglib2.0-dev \
        libsdl1.2-dev \
        libtool \
        libxmu-dev \
        libxmuu-dev \
        lzop \
        make \
        mc \
        minicom \
        net-tools \
        netcat \
        netperf \
        netpipe-tcp \
        openjdk-7-jdk \
        openjdk-7-jre \
        openssh-server \
        pkg-config \
        python-lxml \
        python-matplotlib \
        python-openpyxl \
        python-paramiko \
        python-parsedatetime \
        python-pip \
        python-requests \
        python-serial \
        python-simplejson \
        python-xmltodict \
        python-yaml \
        rsync \
        sshpass \
        sudo \
        time \
        u-boot-tools \
        vim \
        wget \
        xmlstarlet && \
    rm -rf /var/lib/apt/lists/* && \
    echo dash dash/sh boolean false | debconf-set-selections && \
    dpkg-reconfigure dash

RUN pip install \
        filelock \
        python-jenkins==0.4.14

# TODO: Move toolchain-related instalation steps to a derivate image, like fuego:${version}-arhmhf
RUN echo deb http://emdebian.org/tools/debian/ jessie main > /etc/apt/sources.list.d/crosstools.list && \
    curl http://emdebian.org/tools/debian/emdebian-toolchain-archive.key | apt-key add - && \
    dpkg --add-architecture armhf && \
    apt-get update && \
    apt-get -yV install \
        binutils-arm-linux-gnueabihf \
        cpp-arm-linux-gnueabihf \
        crossbuild-essential-armhf \
        gcc-arm-linux-gnueabihf && \
    rm -rf /var/lib/apt/lists/*

# ==============================================================================
# Download and Install Jenkins
# ==============================================================================

ARG JENKINS_VERSION=2.32.1
ARG JENKINS_SHA=bfc226aabe2bb089623772950c4cc13aee613af1
ARG JENKINS_URL=https://pkg.jenkins.io/debian-stable/binary/jenkins_${JENKINS_VERSION}_all.deb
ENV JENKINS_HOME=/var/lib/jenkins

RUN curl -L -O ${JENKINS_URL} && \
    echo "${JENKINS_SHA} jenkins_${JENKINS_VERSION}_all.deb" | sha1sum -c - && \
    dpkg -i jenkins_${JENKINS_VERSION}_all.deb && \
    rm jenkins_${JENKINS_VERSION}_all.deb

# ==============================================================================
# Post installation
# ==============================================================================

COPY setup/jenkins /setup/jenkins
WORKDIR /setup/jenkins
RUN ./setup.sh

WORKDIR /setup/jenkins/plugins
RUN ./install.sh

COPY setup/tools /setup/tools
WORKDIR /setup

RUN git clone https://github.com/tbird20d/ttc.git /usr/local/src/ttc && \
    ./tools/setup-ttc.sh

COPY setup/serial /setup/serial
RUN git clone https://github.com/frowand/serio.git /usr/local/src/serio && \
    ./serial/setup-serio.sh

RUN git clone https://github.com/tbird20d/serlogin.git /usr/local/src/serlogin && \
    ./serial/setup-serlogin.sh

COPY setup/lava /setup/lava
RUN ./lava/setup.sh

COPY docs/fuego-docs.pdf $JENKINS_HOME/userContent/docs/fuego-docs.pdf

# ==============================================================================
# Setup startup command
# ==============================================================================

WORKDIR /
COPY setup/entrypoint.sh /
ENTRYPOINT ["/entrypoint.sh"]
