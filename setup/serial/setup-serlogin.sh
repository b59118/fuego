#!/bin/bash

set -e

chown -R jenkins:jenkins /usr/local/src/serlogin
cp /usr/local/src/serlogin/serlogin /usr/local/bin
