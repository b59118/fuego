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
    -v $DIR/../fuego-rw:/fuego-rw \
    -v $DIR/../fuego-ro:/fuego-ro:ro \
    -v $DIR/../../fuego-core:/fuego-core:ro \
    --net="host" ${DOCKERIMAGE} || \
    echo "Could not create fuego-container. See error messages."
