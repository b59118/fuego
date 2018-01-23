#!/bin/bash

set -e

user=jenkins
group=jenkins
uid=1000
gid=${uid}

# groupadd -g ${gid} ${group}
# useradd -l -m -d "${JENKINS_HOME}" -u ${uid} -g ${gid} -G sudo -s /bin/bash ${user}

cp config.xml jenkins.model.JenkinsLocationConfiguration.xml "${JENKINS_HOME}"

echo 'JENKINS_ARGS="${JENKINS_ARGS} --prefix=/fuego"' >> /etc/default/jenkins
echo 'JAVA_ARGS="${JAVA_ARGS} -Djenkins.install.runSetupWizard=false"' >> /etc/default/jenkins

echo "source /setup/jenkins/set-java-args-proxy.sh" >> /etc/default/jenkins

