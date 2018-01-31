#!/bin/bash

set -e

chown -R jenkins:jenkins /usr/local/src/serio
cp /usr/local/src/serio/serio /usr/local/bin/
ln -s /usr/local/bin/serio /usr/local/bin/sercp
ln -s /usr/local/bin/serio /usr/local/bin/sersh
