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

RUN pip install \
        filelock \
        python-jenkins==0.4.14

# ==============================================================================
# Install Jenkins with the same UID/GID as the host user
# ==============================================================================

ARG user=jenkins
ARG group=jenkins
ARG uid=1000
ARG gid=${uid}
ARG JENKINS_VERSION=2.32.1
ARG JENKINS_SHA=bfc226aabe2bb089623772950c4cc13aee613af1
ARG JENKINS_URL=https://pkg.jenkins.io/debian-stable/binary/jenkins_${JENKINS_VERSION}_all.deb
ENV JENKINS_HOME=/var/lib/jenkins

RUN groupadd -g ${gid} ${group} \
	&& useradd -l -m -d "${JENKINS_HOME}" -u ${uid} -g ${gid} -G sudo -s /bin/bash ${user}
RUN wget -nv ${JENKINS_URL}
RUN echo "${JENKINS_SHA} jenkins_${JENKINS_VERSION}_all.deb" | sha1sum -c -
RUN dpkg -i jenkins_${JENKINS_VERSION}_all.deb
RUN rm jenkins_${JENKINS_VERSION}_all.deb

# ==============================================================================
# get ttc script and helpers
# ==============================================================================
RUN git clone https://github.com/tbird20d/ttc.git /usr/local/src/ttc
RUN /usr/local/src/ttc/install.sh /usr/local/bin
RUN perl -p -i -e "s#config_dir = \"/etc\"#config_dir = \"/fuego-ro/conf\"#" /usr/local/bin/ttc

# ==============================================================================
# Serial Config
# ==============================================================================

RUN /bin/bash -c 'git clone https://github.com/frowand/serio.git /usr/local/src/serio ;  chown -R jenkins /usr/local/src/serio ; cp /usr/local/src/serio/serio /usr/local/bin/ ; ln -s /usr/local/bin/serio /usr/local/bin/sercp ; ln -s /usr/local/bin/serio /usr/local/bin/sersh'

RUN /bin/bash -c 'git clone https://github.com/tbird20d/serlogin.git /usr/local/src/serlogin ;  chown -R jenkins /usr/local/src/serlogin ; cp /usr/local/src/serlogin/serlogin /usr/local/bin'

# ==============================================================================
# Post installation
# ==============================================================================

RUN source /etc/default/jenkins && \
	JENKINS_ARGS="$JENKINS_ARGS --prefix=/fuego" && \
	sed -i -e "s#JENKINS_ARGS.*#JENKINS_ARGS\=\"${JENKINS_ARGS}\"#g" /etc/default/jenkins

RUN source /etc/default/jenkins && \
	JAVA_ARGS="$JAVA_ARGS -Djenkins.install.runSetupWizard=false" && \
	if [ -n "$HTTP_PROXY" ]; then \
		PROXYSERVER=$(echo $http_proxy | sed -E 's/^http://' | sed -E 's/\///g' | sed -E 's/(.*):(.*)/\1/') && \
		PROXYPORT=$(echo $http_proxy | sed -E 's/^http://' | sed -E 's/\///g' | sed -E 's/(.*):(.*)/\2/') && \
		JAVA_ARGS="$JAVA_ARGS -Dhttp.proxyHost="${PROXYSERVER}" -Dhttp.proxyPort="${PROXYPORT}" -Dhttps.proxyHost="${PROXYSERVER}" -Dhttps.proxyPort="${PROXYPORT}; \
	fi && \
	sed -i -e "s#^JAVA_ARGS.*#JAVA_ARGS\=\"${JAVA_ARGS}\"#g" /etc/default/jenkins;

COPY frontend-install/plugins/flot-plotter-plugin/flot.hpi /tmp

RUN service jenkins start && \
	sleep 30 && \
	sudo -u jenkins java -jar /var/cache/jenkins/war/WEB-INF/jenkins-cli.jar -s http://localhost:8080/fuego install-plugin description-setter && \
	sudo -u jenkins java -jar /var/cache/jenkins/war/WEB-INF/jenkins-cli.jar -s http://localhost:8080/fuego install-plugin pegdown-formatter && \
    sudo -u jenkins java -jar /var/cache/jenkins/war/WEB-INF/jenkins-cli.jar -s http://localhost:8080/fuego install-plugin /tmp/flot.hpi && \
    sleep 10

# Let Jenkins install flot before making the symlink
RUN service jenkins restart && sleep 30 && \
    rm $JENKINS_HOME/plugins/flot/flot/mod.js && \
    ln -s /fuego-core/engine/scripts/mod.js $JENKINS_HOME/plugins/flot/flot/mod.js

RUN ln -s /fuego-rw/logs $JENKINS_HOME/userContent/fuego.logs
COPY docs/fuego-docs.pdf $JENKINS_HOME/userContent/docs/fuego-docs.pdf

RUN ln -s /fuego-core/engine/scripts/ftc /usr/local/bin/
COPY frontend-install/config.xml $JENKINS_HOME/config.xml
COPY frontend-install/jenkins.model.JenkinsLocationConfiguration.xml $JENKINS_HOME/jenkins.model.JenkinsLocationConfiguration.xml

RUN chown -R jenkins:jenkins $JENKINS_HOME/

# ==============================================================================
# Lava
# ==============================================================================

RUN ln -s /fuego-ro/scripts/fuego-lava-target-setup /usr/local/bin
RUN ln -s /fuego-ro/scripts/fuego-lava-target-teardown /usr/local/bin
# CONVENIENCE HACKS
# not mounted, yet
#RUN echo "fuego-create-node --board raspberrypi3" >> /root/firststart.sh
#RUN echo "fuego-create-jobs --board raspberrypi3 --testplan testplan_docker --distrib nosyslogd.dist" >> /root/firststart.sh

# ==============================================================================
# Setup startup command
# ==============================================================================

ENTRYPOINT service jenkins start && service netperf start && /bin/bash
