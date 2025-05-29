#!/bin/bash

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
