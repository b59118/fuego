#!/bin/bash

set -e

function install_jenkins_plugin {
    echo "Waiting for Jenkins update center..."
    while ! ret=$(java -jar /var/cache/jenkins/war/WEB-INF/jenkins-cli.jar -s http://localhost:8080/fuego install-plugin "$1" 2>/dev/null); do
        sleep "$2"
    done
    echo "${ret}"
}

function wait_for_jenkins {
    echo "Waiting for Jenkins..."
    while ! curl --output /dev/null --silent --head --fail http://localhost:8080/fuego/ ; do
        sleep "$1"
    done
}

readonly sleep_time_s=1
readonly required_plugins="
   description-setter
   pegdown-formatter
   flot-plotter-plugin/flot.hpi
   "

service jenkins start
wait_for_jenkins ${sleep_time_s}

for plugin in ${required_plugins}; do
    install_jenkins_plugin "${plugin}" "${sleep_time_s}"
done

# Let Jenkins install flot before making the symlink
service jenkins restart
wait_for_jenkins 1

rm "$JENKINS_HOME/plugins/flot/flot/mod.js"
ln -s /fuego-core/engine/scripts/mod.js "$JENKINS_HOME/plugins/flot/flot/mod.js"

mkdir -p "${JENKINS_HOME}/userContent/docs"
cp "${RESOURCES}/docs/fuego-docs.pdf" "${JENKINS_HOME}/userContent/docs/fuego-docs.pdf"

ln -s /fuego-rw/logs "$JENKINS_HOME/userContent/fuego.logs"
ln -s /fuego-core/engine/scripts/ftc /usr/local/bin/

chown -R jenkins:jenkins "$JENKINS_HOME/"

# Cleanup
service jenkins stop
rm -rf /var/cache/jenkins/*
