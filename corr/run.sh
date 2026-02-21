#!/bin/bash
# SPDX-License-Identifier: GPL-2.0

echo "Run damon-tests/corr on $(uname -r) kernel"

BINDIR=`dirname $0`
LOG=$PWD/log

# ensure no pass under warning
echo 1 > /proc/sys/kernel/panic_on_warn

repos_dir=$(realpath "$BINDIR/../../")

if [ -z $LINUX_DIR ]
then
	LINUX_DIR="$repos_dir/linux"
fi

if [ ! -d $LINUX_DIR ]
then
	echo "linux source directory not found at $LINUX_DIR"
	exit 1
fi

if ! "$BINDIR/install_deps.sh"
then
	echo "dependencies install failed"
	exit 1
fi

ksft_dir=tools/testing/selftests/damon-tests
ksft_abs_path=$LINUX_DIR/$ksft_dir

mkdir -p "$ksft_abs_path"
cp "$BINDIR"/tests/* "$ksft_abs_path/"

damo_dir="$repos_dir/damo"
if [ ! -x "$damo_dir/damo" ]
then
	echo "damo at $damo_dir/damo not found"
	exit 1
fi
rm -fr "$ksft_abs_path/damo"
cp -R "$damo_dir" "$ksft_abs_path/"

masim_dir="$repos_dir/masim"
if [ ! -d "$masim_dir" ]
then
	echo "$masim_dir not found"
	exit 1
fi
if [ ! -x "$masim_dir/masim" ]
then
	if ! make -C "$masim_dir"
	then
		echo "building masim failed"
		exit 1
	fi
fi
cp -R "$masim_dir" "$ksft_abs_path/"

damon_stat_enabled_file="/sys/module/damon_stat/parameters/enabled"
if [[ $(cat "$damon_stat_enabled_file") = "Y" ]]
then
	echo "DAMON_STAT is running.  Disable for testing."
	echo N > "$damon_stat_enabled_file"
	restart_damon_stat="true"
fi

# run
(
	cd $LINUX_DIR

	make --silent -C $ksft_dir/../damon run_tests | tee $LOG
	make --silent -C $ksft_dir/ run_tests | tee -a $LOG

	echo "# kselftest dir '$ksft_abs_path' is in dirty state."
	echo "# the log is at '$LOG'."
)

if [ "$restart_damon_stat" = "true" ]
then
	echo "DAMON_STAT was running before test.  Re-enable it."
	echo Y > "$damon_stat_enabled_file"
fi

# print results
if ! $BINDIR/_summary_results.sh $LOG
then
	exit 1
fi
