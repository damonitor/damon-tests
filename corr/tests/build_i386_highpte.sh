#!/bin/bash
# SPDX-License-Identifier: GPL-2.0

# Test i386 build failure problem reported[1] by Randy.
#
# [1] https://lore.kernel.org/mm-commits/2232228f-573b-ac19-1cb0-88690fdf6177@infradead.org/

bindir=$(realpath "$(dirname "$0")")

out_dir=${bindir}/$(basename $0).out
mkdir -p $out_dir

linux_root=$(realpath "${bindir}/../../../../")
cd $linux_root
make "O=${out_dir}" ARCH=i386 allnoconfig
echo 'CONFIG_HIGHPTE=y' >> "${out_dir}/.config"
cat "${bindir}/damon_config" >> "${out_dir}/.config"

make "O=${out_dir}" ARCH=i386 olddefconfig
make "O=${out_dir}" ARCH=i386 -j$(nproc)
exit $?
