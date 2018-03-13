#!/bin/bash
# $1: architecture (e.g.: arm64 armel armhf mips mipsel powerpc ppc64el)

if [ -z ${1+x} ]; then
    ARCH=armhf
else
    ARCH=$1
fi

case $ARCH in
	arm64 | armel | armhf | mips | mipsel | powerpc | ppc64el)
		;;
	*)
		echo "Unsupported toolchain architecture: $ARCH"
		echo "Please use one of: arm64 armel armhf mips mipsel powerpc ppc64el"
		exit 1
		;;
esac

# use working directory as a lock
if [ -d /tmp/toolchain_install ] ; then
    echo "Cannout use /tmp/toolchain_install as it's already present"
    echo "Try again after other operation completes, or you remove it manually"
    exit
fi
mkdir -p /tmp/toolchain_install

echo deb http://emdebian.org/tools/debian/ jessie main > /etc/apt/sources.list.d/crosstools.list
dpkg --add-architecture $ARCH
curl http://emdebian.org/tools/debian/emdebian-toolchain-archive.key | sudo apt-key add -
DEBIAN_FRONTEND=noninteractive apt-get update
DEBIAN_FRONTEND=noninteractive apt-get -yV install crossbuild-essential-$ARCH

# libaio is needed for LTP
DEBIAN_FRONTEND=noninteractive apt-get -yV install libaio1:$ARCH

# manually install libio-dev from the arch-specific libaio-dev debian package
# (because 'apt-get install' removes any other libaio-dev package installed)
echo "Install libaio-dev:$ARCH... (in a way that's a bit tricky)"
SAVEDIR=$(pwd)
cd /tmp/toolchain_install
echo "  current directory: $(pwd)"
apt-get download libaio-dev:$ARCH
PKG=$(echo libaio-dev*.deb)
echo "  downloaded package: $PKG"
toolchain_dir=$(dpkg --contents $PKG | grep /usr/lib | head -n 2 | tail -n 1 | cut -b 59- )
echo "  toolchain_dir: $toolchain_dir"
# extract the package contents
dpkg -x $PKG .
# copy the file and symlink we need
cp -vd usr/lib/${toolchain_dir}libaio.* /usr/lib/${toolchain_dir}
# clean up
cd $SAVEDIR
rm -rf /tmp/toolchain_install
