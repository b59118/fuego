#!/bin/bash
set -e

function map_jenkins_uid_to_host() {
    if [ "$(id -u jenkins)" = "${UID}" ]; then
        return 0
    fi

    echo "Remapping Fuego's jenkins uid=$(id -u jenkins) to uid=${UID}..."

    usermod -u "${UID}" jenkins
    groupmod -g "${GID}" jenkins
    chown -R "${UID}":"${GID}" \
        /var/lib/jenkins /var/cache/jenkins /var/log/jenkins /fuego-rw
}

service jenkins stop >> /dev/null
map_jenkins_uid_to_host
service jenkins start
service netperf start

exec /bin/bash
