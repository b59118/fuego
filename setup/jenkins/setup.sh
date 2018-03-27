#!/bin/bash

set -e

echo "JENKINS_HOME=${JENKINS_HOME}" >> /etc/default/jenkins
echo "JENKINS_CACHE=${JENKINS_CACHE}" >> /etc/default/jenkins
echo "JENKINS_LOG=${JENKINS_LOG}" >> /etc/default/jenkins

echo 'JENKINS_ARGS="${JENKINS_ARGS} --prefix=/fuego"' >> /etc/default/jenkins
echo 'JAVA_ARGS="${JAVA_ARGS} -Djenkins.install.runSetupWizard=false"' >> /etc/default/jenkins

cp config.xml jenkins.model.JenkinsLocationConfiguration.xml "${JENKINS_HOME}"

echo "source /setup/jenkins/set-java-args-proxy.sh" >> /etc/default/jenkins

