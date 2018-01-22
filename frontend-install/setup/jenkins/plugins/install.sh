#!/bin/bash

set -e

service jenkins start
sleep 30
sudo -u jenkins java -jar /var/cache/jenkins/war/WEB-INF/jenkins-cli.jar -s http://localhost:8080/fuego install-plugin description-setter
sudo -u jenkins java -jar /var/cache/jenkins/war/WEB-INF/jenkins-cli.jar -s http://localhost:8080/fuego install-plugin pegdown-formatter
sudo -u jenkins java -jar /var/cache/jenkins/war/WEB-INF/jenkins-cli.jar -s http://localhost:8080/fuego install-plugin flot-plotter-plugin/flot.hpi
sleep 10

# Let Jenkins install flot before making the symlink
service jenkins restart
sleep 30
rm $JENKINS_HOME/plugins/flot/flot/mod.js
ln -s /fuego-core/engine/scripts/mod.js $JENKINS_HOME/plugins/flot/flot/mod.js
ln -s /fuego-rw/logs $JENKINS_HOME/userContent/fuego.logs
ln -s /fuego-core/engine/scripts/ftc /usr/local/bin/

chown -R jenkins:jenkins $JENKINS_HOME/

