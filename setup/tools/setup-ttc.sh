#!/bin/bash

set -e

/usr/local/src/ttc/install.sh /usr/local/bin
perl -p -i -e "s#config_dir = \"/etc\"#config_dir = \"/fuego-ro/conf\"#" \
    /usr/local/bin/ttc
