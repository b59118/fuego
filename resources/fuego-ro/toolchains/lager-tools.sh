# fuego toolchain script
# this sets up the environment needed for fuego to use a toolchain
# this includes the following variables:
# CC, CXX, CPP, CXXCPP, CONFIGURE_FLAGS, AS, LD, ARCH
# CROSS_COMPILE, PREFIX, HOST, SDKROOT
# CFLAGS and LDFLAGS are optional
#
# this script should be sourced by ${FUEGO_RO}/toolchains/tools.sh

export SDKROOT=${FUEGO_RO}/toolchains/lager-poky-toolchain/sysroots/cortexa15hf-vfp-neon-poky-linux-gnueabi

# the Yocto project environment setup script changes PATH so that python uses
# libs from sysroot, which is not what we want, so save the original path
# and use it later
ORIG_PATH=$PATH

PREFIX=arm-poky-linux-gnueabi
source ${FUEGO_RO}/toolchains/lager-poky-toolchain/environment-setup-cortexa15hf-vfp-neon-poky-linux-gnueabi
HOST=arm-poky-linux-gnueabi

# don't use PYTHONHOME from environment setup script
unset PYTHONHOME
env -u PYTHONHOME
