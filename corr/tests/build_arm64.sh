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

bindir=$(realpath "$(dirname "$0")")

mkdir -p "${bindir}/bin"
PATH=${bindir}/bin/:$PATH

PATH=${bindir}/bin/lkp-tests/kbuild/:$PATH

if [ ! -x "${bindir}/bin/lkp-tests/kbuild/make.cross" ]
then
	git clone https://github.com/intel/lkp-tests "${bindir}/bin/lkp-tests"
	# By default make.cross compiles kernel with strict compiler flags on
	# top. To disable them and make a regular kernel build, edit or erase
	# extra flags in kbuld-kcflags file:
	# echo "" > ./bin/lkp-tests/kbuild/etc/kbuild-kcflags
	chmod +x "${bindir}/bin/lkp-tests/kbuild/make.cross"
fi

out_dir=${bindir}/$(basename "$0").out
mkdir -p $out_dir

# bindir is supposed to be tools/testing/selftets/damon-tests/ of linux tree
linux_root=$(realpath "${bindir}/../../../../")
cd $linux_root
make "O=${out_dir}" ARCH=arm64 allnoconfig
cat "${bindir}/damon_config" >> "${out_dir}/.config"

export COMPILER_INSTALL_PATH=$HOME/0day
export COMPILER=gcc-9.3.0
export ARCH=arm64
export URL=https://cdn.kernel.org/pub/tools/crosstool/files/bin/x86_64/9.3.0

make.cross "O=${out_dir}" olddefconfig
make.cross "O=${out_dir}" -j$(nproc)
exit $?
