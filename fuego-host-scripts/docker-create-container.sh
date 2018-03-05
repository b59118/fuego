#!/bin/bash
# $1 - name for the docker image (default: fuego)
# $2 - name for the docker container (default: fuego-container)
SOURCE="${BASH_SOURCE[0]}"
while [ -h "$SOURCE" ]; do # resolve $SOURCE until the file is no longer a symlink
  DIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )"
  SOURCE="$(readlink "$SOURCE")"
  [[ $SOURCE != /* ]] && SOURCE="$DIR/$SOURCE" # if $SOURCE was a relative symlink, we need to resolve it relative to the path where the symlink file was located
done
DIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )"

DOCKERIMAGE=${1:-fuego}
DOCKERCONTAINER=${2:-fuego-container}

if [ ! -d $DIR/../../fuego-core ]; then
   echo "You need to clone fuego-core at $DIR/../../fuego-core"
   exit 1
fi

if [ "${UID}" == "0" ]; then
	uid=$(id -u "${SUDO_USER}")
	gid=$(id -g "${SUDO_USER}")
else
	uid="${UID}"
	gid=$(id -g "${USER}")
fi

sed -i "s/docker_jenkins_uid=1000/docker_jenkins_uid=$uid/" $DIR/../fuego-ro/conf/fuego.conf
sed -i "s/docker_jenkins_gid=500/docker_jenkins_gid=$gid/" $DIR/../fuego-ro/conf/fuego.conf

sudo docker create -it --name ${DOCKERCONTAINER} \
    -v /var/run/docker.sock:/var/run/docker.sock \
    -v /boot:/boot:ro \
    -v $DIR/../fuego-rw:/fuego-rw \
    -v $DIR/../fuego-ro:/fuego-ro:ro \
    -v $DIR/../../fuego-core:/fuego-core:ro \
    -e http_proxy=${http_proxy} \
    -e https_proxy=${https_proxy:-$http_proxy} \
    --net="host" ${DOCKERIMAGE} || \
    echo "Could not create fuego-container. See error messages."
