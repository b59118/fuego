# Copyright (c) 2014 Cogent Embedded, Inc.

# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:

# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.

# DESCRIPTION
# This script defines (or calls env. setup script) build variables for ${PLATFORM}

function export_tools () {
    export AS=${PREFIX}-as
    export CC=${PREFIX}-gcc
    export CXX=${PREFIX}-g++
    export AR=${PREFIX}-ar
    export RANLIB=${PREFIX}-ranlib
    export CPP=${PREFIX}-cpp
    export CXXCPP=${PREFIX}-cpp
    export LD=${PREFIX}-ld
    export LDFLAGS="--sysroot ${SDKROOT} -lm"
    export CROSS_COMPILE=${PREFIX}-
    export HOST=${PREFIX}
    export CONFIGURE_FLAGS="--target=${PREFIX} --host=${PREFIX} --build=`uname -m`-unknown-linux-gnu"
}

# scan the toolchains directory for a matching $PLATFORM-tools.sh file
if [ -f "${FUEGO_RO}/toolchains/${PLATFORM}-tools.sh" ];
then
    source ${FUEGO_RO}/toolchains/${PLATFORM}-tools.sh
else
    abort_job "Missing toolchain setup script ${FUEGO_RO}/toolchains/${PLATFORM}-tools.sh"
fi
