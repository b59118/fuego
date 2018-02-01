#!/bin/bash
set -e

. /fuego-ro/conf/fuego.conf

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
service jenkins start
service netperf start

exec /bin/bash
