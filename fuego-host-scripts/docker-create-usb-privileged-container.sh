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

sudo docker create -it --name ${DOCKERCONTAINER} \
    --privileged \
    -v /boot:/boot:ro \
    -v /dev/bus/usb:/dev/bus/usb \
    -v /dev/ttyACM0:/dev/ttyACM0 \
    -v /dev/ttyACM1:/dev/ttyACM1 \
    -v /dev/ttyUSB0:/dev/ttyUSB0 \
    -v /dev/serial:/dev/serial \
    -v $DIR/../fuego-rw:/fuego-rw \
    -v $DIR/../fuego-ro:/fuego-ro:ro \
    -v $DIR/../../fuego-core:/fuego-core:ro \
    -e http_proxy=${http_proxy} \
    -e https_proxy=${https_proxy:-$http_proxy} \
    --net="host" ${DOCKERIMAGE} || \
    echo "Could not create fuego-container. See error messages."
