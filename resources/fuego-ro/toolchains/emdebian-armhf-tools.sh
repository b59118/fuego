# fuego toolchain script
# this sets up the environment needed for fuego to use a toolchain
# this includes the following variables:
# CC, CXX, CPP, CXXCPP, CONFIGURE_FLAGS, AS, LD, ARCH
# CROSS_COMPILE, PREFIX, HOST, SDKROOT
# CFLAGS and LDFLAGS are optional
#
# this script is sourced by ${FUEGO_RO}/toolchains/tools.sh
#
# Note that to use this script, you should install the
# Debian cross-compiler toolchains, using the script
# install_cross_toolchain.sh
#
# do this, inside the container, as follows:
#  /fuego-ro/toolchain/install_cross_toolchain.sh armhf

export ARCH=arm

export SDKROOT=/
export PREFIX=arm-linux-gnueabihf
export_tools
CPP="${CC} -E"
CXXCPP="${CXX} -E"

# save original path, to get to non-toolchain version of python
ORIG_PATH=$PATH
unset PYTHONHOME
env -u PYTHONHOME
