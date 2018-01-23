#!/bin/bash
# $1 - name for the docker image (default: fuego)
DOCKERIMAGE=${1:-fuego}

if [ "$(id -u)" == "0" ]; then
	JENKINS_UID=$(id -u $SUDO_USER)
	JENKINS_GID=$(id -g $SUDO_USER)
else
	JENKINS_UID=$(id -u $USER)
	JENKINS_GID=$(id -g $USER)
fi

sudo docker build -t ${DOCKERIMAGE} \
    --build-arg http_proxy=${http_proxy} \
    --build-arg https_proxy=${https_proxy} \
    --build-arg uid=${JENKINS_UID} \
    --build-arg gid=${JENKINS_GID} \
    .
