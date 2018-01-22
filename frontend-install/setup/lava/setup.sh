#!/bin/bash

set -e

# CONVENIENCE HACKS
# not mounted, yet
#RUN echo "fuego-create-node --board raspberrypi3" >> /root/firststart.sh
#RUN echo "fuego-create-jobs --board raspberrypi3 --testplan testplan_docker --distrib nosyslogd.dist" >> /root/firststart.sh

ln -s /fuego-ro/scripts/fuego-lava-target-setup /usr/local/bin
ln -s /fuego-ro/scripts/fuego-lava-target-teardown /usr/local/bin
