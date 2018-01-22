#!/bin/bash

set -e

user=jenkins
group=jenkins
uid=1000
gid=${uid}

# groupadd -g ${gid} ${group}
# useradd -l -m -d "${JENKINS_HOME}" -u ${uid} -g ${gid} -G sudo -s /bin/bash ${user}

cp config.xml jenkins.model.JenkinsLocationConfiguration.xml ${JENKINS_HOME}

source /etc/default/jenkins
JENKINS_ARGS="$JENKINS_ARGS --prefix=/fuego"
sed -i -e "s#JENKINS_ARGS.*#JENKINS_ARGS\=\"${JENKINS_ARGS}\"#g" /etc/default/jenkins

JAVA_ARGS="$JAVA_ARGS -Djenkins.install.runSetupWizard=false"
if [ -n "$HTTP_PROXY" ]; then
	PROXYSERVER=$(echo $http_proxy | sed -E 's/^http://' | sed -E 's/\///g' | sed -E 's/(.*):(.*)/\1/');
	PROXYPORT=$(echo $http_proxy | sed -E 's/^http://' | sed -E 's/\///g' | sed -E 's/(.*):(.*)/\2/');
	JAVA_ARGS="$JAVA_ARGS -Dhttp.proxyHost=${PROXYSERVER} -Dhttp.proxyPort=${PROXYPORT} -Dhttps.proxyHost=${PROXYSERVER} -Dhttps.proxyPort=${PROXYPORT}";
fi
sed -i -e "s#^JAVA_ARGS.*#JAVA_ARGS\=\"${JAVA_ARGS}\"#g" /etc/default/jenkins

