#!/bin/bash
# SPDX-License-Identifier: GPL-2.0

# Test i386 build failure problem reported[1] by kbuild robot
#
# [1] https://lore.kernel.org/202508241831.EKwdwXZL-lkp@intel.com/

LINUX_SRC='../../../../'
TESTDIR=$PWD
ODIR=$PWD/`basename $0`.out

mkdir -p $ODIR

cd $LINUX_SRC
make O=$ODIR ARCH=i386 allnoconfig
cat "$TESTDIR/damon_config" >> "$ODIR/.config"
echo >> "$ODIR/.config"
echo 'CONFIG_X86_PAE=y' >> "$ODIR/.config"

make O=$ODIR ARCH=i386 olddefconfig
make O=$ODIR ARCH=i386 -j$(nproc)
exit $?
