#!/bin/bash
# SPDX-License-Identifier: GPL-2.0

# Test i386 build failure problem reported[1] by Randy.
#
# [1] https://lore.kernel.org/mm-commits/2232228f-573b-ac19-1cb0-88690fdf6177@infradead.org/

LINUX_SRC='../../../../'
TESTDIR=$PWD
ODIR=$PWD/`basename $0`.out

mkdir -p $ODIR

cd $LINUX_SRC
make O=$ODIR ARCH=i386 allnoconfig
echo 'CONFIG_HIGHPTE=y' >> "$ODIR/.config"
cat "$TESTDIR/damon_config" >> "$ODIR/.config"

make O=$ODIR ARCH=i386 olddefconfig
make O=$ODIR ARCH=i386 -j`grep -e '^processor' /proc/cpuinfo | wc -l`
exit $?
