# fuego toolchain script
# this sets up the environment needed for fuego to use a toolchain
# this includes the following variables:
# CC, CXX, CPP, CXXCPP, CONFIGURE_FLAGS, AS, LD, ARCH
# CROSS_COMPILE, PREFIX, HOST, SDKROOT
# CFLAGS and LDFLAGS are optional
#
# this script should be sourced by ${FUEGO_RO}/toolchains/tools.sh

SDKROOT=/

# the Yocto project environment setup script changes PATH so that python uses
# libs from sysroot, which is not what we want, so save the original path
# and use it later
ORIG_PATH=$PATH

PREFIX=aarch64-linux-gnu
export_tools

# avoid "could not find -lm" errors
LDFLAGS=
