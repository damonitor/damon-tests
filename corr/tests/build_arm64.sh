#!/bin/bash
# SPDX-License-Identifier: GPL-2.0

# Test arm64 build failure problem reported by kbuild robot

ksft_skip=4

# lftp is used inside lkp-tests for downloading cross compilers.  It fails[1]
# when the system is not having global ipv6, though it isn't needed for http.
# Just skip the test on the system failing it.
#
# [1] https://github.com/lavv17/lftp/blob/fdb81537a2f854/src/Resolver.cc#L362
if ! lftp -c "open https://cdn.kernel.org/pub/tools/crosstool/files/bin/x86_64/"
then
	echo "lftp fail"
	exit $ksft_skip
fi

LINUX_SRC='../../../../'
TESTDIR=$PWD
ODIR=$TESTDIR/`basename $0`.out

mkdir -p bin
PATH=$TESTDIR/bin/lkp-tests/kbuild/:$PATH

if [ ! -x ./bin/lkp-tests/kbuild/make.cross ]
then
	git clone https://github.com/intel/lkp-tests ./bin/lkp-tests
	# By default make.cross compiles kernel with strict compiler flags on
	# top. To disable them and make a regular kernel build, edit or erase
	# extra flags in kbuld-kcflags file:
	# echo "" > ./bin/lkp-tests/kbuild/etc/kbuild-kcflags
	chmod +x ./bin/lkp-tests/kbuild/make.cross
fi

mkdir -p $ODIR

cd $LINUX_SRC
make O=$ODIR ARCH=arm64 allnoconfig
cat "$TESTDIR/damon_config" >> $ODIR/.config

export COMPILER_INSTALL_PATH=$HOME/0day
export COMPILER=gcc-9.3.0
export ARCH=arm64
export URL=https://cdn.kernel.org/pub/tools/crosstool/files/bin/x86_64/9.3.0

make.cross O=$ODIR olddefconfig
make.cross O=$ODIR -j$(nproc)
exit $?
