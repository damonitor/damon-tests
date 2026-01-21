#!/bin/bash
# SPDX-License-Identifier: GPL-2.0

# Test i386 build failure problem reported[1] by kbuild robot
#
# [1] https://lore.kernel.org/linux-mm/202002051834.cKoViGVl%25lkp@intel.com/

bindir=$(realpath "$(dirname "$0")")

out_dir=${bindir}/$(basename $0).out
mkdir -p $out_dir

linux_root=$(realpath "${bindir}/../../../../")
cd $linux_root
make "O=${out_dir}" ARCH=i386 allnoconfig
cat "${bindir}/damon_config" >> "${out_dir}/.config"

make "O=${out_dir}" ARCH=i386 olddefconfig
make "O=${out_dir}" ARCH=i386 -j$(nproc)
exit $?
