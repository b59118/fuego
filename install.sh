#!/bin/bash

set -e

source fuego-host-scripts/docker-build-image.sh $1
sudo /bin/sh -c "if [ -f /etc/ttc.conf -a ! -f fuego-ro/conf/ttc.conf ] ; then cp /etc/ttc.conf fuego-ro/conf/ttc.conf ; fi"
