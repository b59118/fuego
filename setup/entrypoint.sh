#!/bin/bash
#set -e

function set_jenkins_port() {
    if [ -n "${jenkins_port}" ] ; then
        sed -i "s/^HTTP_PORT=.*/HTTP_PORT=${jenkins_port}/" /etc/default/jenkins
    fi
}

function map_jenkins_uid_to_host() {
    if [ "$(id -u jenkins)" = "${JENKINS_UID}" ]; then
        return 0
    fi

    if [ -z "${JENKINS_UID}" ] || [ -z "${JENKINS_UID}" ]; then
        return 0
    fi

    echo "Remapping Fuego's jenkins uid=$(id -u jenkins) to uid=${JENKINS_UID}..."

    usermod -u "${JENKINS_UID}" jenkins
    groupmod -g "${JENKINS_GID}" jenkins

    rm -rf "${JENKINS_CACHE}"
    mkdir -p "${JENKINS_CACHE}"

    chown -R -L "${JENKINS_UID}":"${JENKINS_GID}" \
        "${JENKINS_CACHE}" "${JENKINS_LOG}"
}

function check_ownership {
    user=${1:-$(id -u)}
    root=${2:-.}

    not_owned=$(find "${root}" \! -user "${user}" -print -quit)

    if [ -n "${not_owned}" ]; then
        ls -lah "${not_owned}"
        return 1
    fi

    return 0
}

function print_path() {
    # Remove double slashes that may exist on the path
    readlink -m "${1}"
}

function collect_if_not_present() {
    source="${1}"
    dest="${2}"
    owner="${3}"

    if [ "$#" -ne 3 ]; then
        exit 1
    fi

    dest_dirname=$(dirname "${dest}")
    owner_uid=$(id -u "${owner}")

    if [ ! -e "${dest}" ]; then
        echo "Generating $(print_path ${dest})..."
        mkdir -p "${dest_dirname}"
        cp -r "$source" "${dest}"
        chown -R "${owner}:${owner}" "${dest}"
    else
        echo "Using pre-existing $(print_path ${dest})"
        if ! check_ownership jenkins "${dest}" ; then
            echo "Warning: Some files from ${dest} are not owned by ${owner}."\
                 "The user ${owner} (uid ${owner_uid}) may not be able"\
                 "to access those files."
        fi
    fi
}

function collect_from_git_if_not_present() {
    source="${1}"
    branch="${2}"
    dest="${3}"
    owner="${4}"

    if [ "$#" -ne 4 ]; then
        exit 1
    fi

    tmp_source="/tmp/"$(basename "${dest}")

    if [ ! -d "${dest}" ]; then
        git clone --depth 1 --single-branch --branch "${branch}" "${source}" "${tmp_source}"
    fi

    collect_if_not_present "${tmp_source}" "${dest}" "${owner}"
    rm -rf "${tmp_source}"
}

function collect_resources() {
    if [ ! -d "${FUEGO_HOME}" ]; then
        mkdir -p "${FUEGO_HOME}"
    fi

    collect_if_not_present "${RESOURCES}/fuego-rw" "${FUEGO_HOME}/fuego-rw" jenkins
    collect_if_not_present "${RESOURCES}/fuego-ro" "${FUEGO_HOME}/fuego-ro" jenkins
    collect_from_git_if_not_present "https://bitbucket.org/profusionmobi/fuego-core" \
        "master" "${FUEGO_HOME}/fuego-core" jenkins

    # Move the contents of ${JENKINS_HOME} to ${FUEGO_HOME}/${JENKINS_HOME} and
    # create the symbolic link ${JENKINS_HOME} -> ${FUEGO_HOME}/${JENKINS_HOME}
    collect_if_not_present "${JENKINS_HOME}" "${FUEGO_HOME}/${JENKINS_HOME}" jenkins
    rm -rf "${JENKINS_HOME}"
    ln -s "${FUEGO_HOME}/${JENKINS_HOME}" "${JENKINS_HOME}"

    collect_if_not_present "${JENKINS_CACHE}" "${FUEGO_HOME}/${JENKINS_CACHE}" jenkins
    rm -rf "${JENKINS_CACHE}"
    ln -s "${FUEGO_HOME}/${JENKINS_CACHE}" "${JENKINS_CACHE}"

    collect_if_not_present "${JENKINS_LOG}" "${FUEGO_HOME}/${JENKINS_LOG}" jenkins
    rm -rf "${JENKINS_LOG}"
    ln -s "${FUEGO_HOME}/${JENKINS_LOG}" "${JENKINS_LOG}"

    if [ -e /fuego-ro/conf/fuego.conf ] ; then
        . /fuego-ro/conf/fuego.conf
    else
        echo "ERROR: Missing fuego-ro/conf/fuego.conf"
        exit 1
    fi
}

service jenkins stop >> /dev/null
map_jenkins_uid_to_host
collect_resources
set_jenkins_port
service jenkins start
service netperf start

if [ $# -eq 0 ]; then
    gosu jenkins:jenkins /bin/bash
else
    gosu jenkins:jenkins "$@"
fi
