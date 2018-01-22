# ==============================================================================
# WARNING: this Dockerfile assumes that the container will be created with
# several volume bind mounts (see docker-create-container.sh)
# ==============================================================================

FROM debian:jessie
MAINTAINER tim.bird@sony.com

# ==============================================================================
# Proxy variables
# ==============================================================================

ARG HTTP_PROXY
ENV http_proxy ${HTTP_PROXY}
ENV https_proxy ${HTTP_PROXY}

# ==============================================================================
# Prepare basic image
# ==============================================================================

WORKDIR /
COPY frontend-install/apt/sources/fuego-debian-jessie.list \
        /etc/apt/sources.list.d/fuego-debian-jessie.list
RUN if [ -n "$HTTP_PROXY" ]; then \
        echo 'Acquire::http::proxy "'$HTTP_PROXY'";' > /etc/apt/apt.conf.d/80proxy; \
    fi && \
    DEBIAN_FRONTEND=noninteractive apt-get update && \
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
    rm -rf /var/lib/apt/lists/*

RUN echo dash dash/sh boolean false | debconf-set-selections ; DEBIAN_FRONTEND=noninteractive dpkg-reconfigure dash && \
    if [ -n "$HTTP_PROXY" ]; then \
        echo "use_proxy = on" >> /etc/wgetrc; \
        echo -e "http_proxy=$HTTP_PROXY\nhttps_proxy=$HTTP_PROXY" >> /etc/environment; \
    fi

RUN pip install \
        filelock \
        python-jenkins==0.4.14

# TODO: Move toolchain-related instalation steps to a derivate image, like fuego:${version}-arhmhf
RUN echo deb http://emdebian.org/tools/debian/ jessie main > /etc/apt/sources.list.d/crosstools.list && \
    curl http://emdebian.org/tools/debian/emdebian-toolchain-archive.key | apt-key add - && \
    dpkg --add-architecture armhf && \
    DEBIAN_FRONTEND=noninteractive apt-get update && \
    apt-get -yV install \
        binutils-arm-linux-gnueabihf \
        cpp-arm-linux-gnueabihf \
        crossbuild-essential-armhf \
        gcc-arm-linux-gnueabihf && \
    rm -rf /var/lib/apt/lists/*

# ==============================================================================
# Download and Install Jenkins
# ==============================================================================

ENV uid=1000
ENV gid=${uid}
ARG JENKINS_VERSION=2.32.1
ARG JENKINS_SHA=bfc226aabe2bb089623772950c4cc13aee613af1
ARG JENKINS_URL=https://pkg.jenkins.io/debian-stable/binary/jenkins_${JENKINS_VERSION}_all.deb
ENV JENKINS_HOME=/var/lib/jenkins

RUN groupadd -g ${gid} ${group} && \
    useradd -l -m -d "${JENKINS_HOME}" -u ${uid} -g ${gid} -G sudo -s /bin/bash ${user} && \
    curl -L -O ${JENKINS_URL} && \
    echo "${JENKINS_SHA} jenkins_${JENKINS_VERSION}_all.deb" | sha1sum -c - && \
    dpkg -i jenkins_${JENKINS_VERSION}_all.deb && \
    rm jenkins_${JENKINS_VERSION}_all.deb

# ==============================================================================
# Post installation
# ==============================================================================

COPY frontend-install/setup/jenkins /setup/jenkins
WORKDIR /setup/jenkins
RUN ./setup.sh

WORKDIR /setup/jenkins/plugins
RUN ./install.sh

COPY frontend-install/setup/serial /setup/serial
WORKDIR /setup

RUN git clone https://github.com/tbird20d/ttc.git /usr/local/src/ttc && \
    ./serial/setup-ttc.sh

RUN git clone https://github.com/frowand/serio.git /usr/local/src/serio && \
    ./serial/setup-serio.sh

RUN git clone https://github.com/tbird20d/serlogin.git /usr/local/src/serlogin && \
    ./serial/setup-serlogin.sh

COPY frontend-install/setup/lava /setup/lava
RUN ./lava/setup.sh

COPY docs/fuego-docs.pdf $JENKINS_HOME/userContent/docs/fuego-docs.pdf

# ==============================================================================
# Setup startup command
# ==============================================================================

ENTRYPOINT service jenkins start && service netperf start && /bin/bash
