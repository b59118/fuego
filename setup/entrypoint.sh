#!/bin/bash
#set -e

if [ -e /fuego-ro/conf/fuego.conf ] ; then
    . /fuego-ro/conf/fuego.conf
else
    echo "ERROR: Missing fuego-ro/conf/fuego.conf"
    exit 1
fi

function set_jenkins_port() {
    if [ -n "${jenkins_port}" ] ; then
        sed -i "s/^HTTP_PORT=.*/HTTP_PORT=${jenkins_port}/" /etc/default/jenkins
    fi
}

function map_jenkins_uid_to_host() {
    if [ "$(id -u jenkins)" = "${docker_jenkins_uid}" ]; then
        return 0
    fi

    DJUID=${docker_jenkins_uid}
    DJGID=${docker_jenkins_gid}

    echo "Remapping Fuego's jenkins uid=$(id -u jenkins) to uid=${DJUID}..."

    usermod -u "${DJUID}" jenkins
    groupmod -g "${DJGID}" jenkins
    chown -R "${DJUID}":"${DJGID}" \
        /var/lib/jenkins /var/cache/jenkins /var/log/jenkins /fuego-rw
}

service jenkins stop >> /dev/null
map_jenkins_uid_to_host
set_jenkins_port
service jenkins start
service netperf start

exec /bin/bash
