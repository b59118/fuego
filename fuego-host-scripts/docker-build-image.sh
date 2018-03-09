#!/bin/bash
# $1 - name for the docker image (default: fuego)
DOCKERIMAGE=${1:-fuego}

if [ "${UID}" == "0" ]; then
	uid=$(id -u "${SUDO_USER}")
	gid=$(id -g "${SUDO_USER}")
else
	uid="${UID}"
	gid=$(id -g "${USER}")
fi

sudo docker build -t ${DOCKERIMAGE} \
    --build-arg uid=${uid} \
    --build-arg gid=${gid} \
    --build-arg http_proxy=${http_proxy} \
    --build-arg https_proxy=${https_proxy} .
