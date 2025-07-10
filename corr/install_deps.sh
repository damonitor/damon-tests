#!/bin/bash

# Debian-based distros
if which apt &> /dev/null; then
	# Basic requirements
	sudo apt install -y xz-utils lftp

	if ! sudo apt install -y python &> /dev/null
	then
		# python package is not in Ubuntu 22.04
		sudo apt install -y python-is-python3
	fi

	# Required for minimal installations in Ubuntu 22.04 and 24.04.
	sudo apt install -y make gcc flex bison bc

	# required from v6.11-rc1 for arm64 build
	sudo apt install -y libgmp-dev libmpc-dev

# Red Hat-based distros
elif which dnf &> /dev/null; then
	sudo dnf install -y make gcc gcc-c++ flex bison lftp gmp-devel \
	libmpc-devel

else
	echo '#################################################################'
	echo '# This distribution is not officially maintained by damon_tests #'
	echo '# project.  You have to install required packages manually.     #'
	echo '#################################################################'
fi
