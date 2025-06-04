#!/bin/bash
# SPDX-License-Identifier: GPL-2.0

# Test m68k build failure problem reported[1] by kbuild robot
#
# [1] https://lore.kernel.org/linux-mm/202002130710.3P1Y98f7%25lkp@intel.com/

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
PATH=$TESTDIR/bin/:$PATH

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
make O=$ODIR ARCH=m68k allnoconfig
echo 'CONFIG_MODULES=y' >> $ODIR/.config
cat "$TESTDIR/damon_config" >> "$ODIR/.config"

export COMPILER_INSTALL_PATH=$HOME/0day
export COMPILER=gcc-8.1.0
export URL=https://cdn.kernel.org/pub/tools/crosstool/files/bin/x86_64/8.1.0

make.cross O=$ODIR ARCH=m68k olddefconfig
make.cross O=$ODIR ARCH=m68k -j`grep -e '^processor' /proc/cpuinfo | wc -l`
exit $?
