# fuego toolchain script
# this sets up the environment needed for fuego to use a toolchain
# this includes the following variables:
# CC, CXX, CPP, CXXCPP, CONFIGURE_FLAGS, AS, LD, ARCH
# CROSS_COMPILE, PREFIX, HOST, SDKROOT
# CFLAGS and LDFLAGS are optional
#
# this script is sourced by ${FUEGO_RO}/toolchains/tools.sh

export PREFIX=
export CC=gcc
export CPP=cpp
export CXX=g++
export SDKROOT=/
export CONFIGURE_FLAGS=""
export LDFLAGS=" "
export AS=as
export LD=ld
export AR=ar
export RANLIB=ranlib
export ARCH=x86_64
export CROSS_COMPILE=
HOST=x86_64-linux

# save original path, to get to non-toolchain version of python
ORIG_PATH=$PATH
unset PYTHONHOME
env -u PYTHONHOME
