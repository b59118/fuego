#!/bin/bash
# $1 - name for the docker image (default: fuego)
DOCKERIMAGE=${1:-fuego}

sudo docker build -t ${DOCKERIMAGE} \
    --build-arg http_proxy=${http_proxy} \
    --build-arg https_proxy=${https_proxy} .
