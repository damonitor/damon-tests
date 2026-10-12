This directory contains files for the continuous test of DAMON.

It checks updates to several kernel trees, trigger tests on remote test
machines, and retrieve the test results from them.

Setup: Machines
===============

You need to prepare two machines: 'triger' and 'runner'.  'Trigger' machine
monitors updates to the test target kernel trees and request 'runner' machine
to fetch the source code, build, reboot, and run DAMON tests in it.  Hence,
'trigger' machine needs no much h/w resources.  Meanwhile, 'runner' machine
should have enough resource to build the kernel.  Both should have disk space
that is large enough to keep having the full git history of Linux and built
kernels.

One of easiest and tested setup is using virtual machines.  For example, below
setup is tested.
[lazybox/vmm](https://github.com/sjp38/lazybox/tree/master/vmm) is used for the
virtual machines setup.

- Host: 16 cores, 27 GiB memory, 500 GiB disk
- Trigger: 2 cores, 8 GiB memory, 30 GiB disk
- Runner: 14 cores, 8 GiB memory, 40 GiB disk

'Trigger' machine should be able to `ssh` into 'runner' machine without any
password prompt.  Setting `~/.ssh/authorized_keys` in the 'runner' machine
would be a way for this.  'Trigger' machine should also be able to run `sudo`
without prompts.  Setting `sudoer` file via `visudo` would be a way to do that.

Both machines should have `git` and `rsync` installed.  'Runner' machine should
also have `drgn` instlled.

Setup: CI config
================

Write down `config.sh` file in your test setup directory.  The file should
define `test_machines`, `test_users`, `test_ssh_ports` variables as arrays.

Optionally, if the 'triger' machine is configured to be able to send mail via
`git send-email` without prompts, it can send test results via mail if the
`config.sh` file has `result_noti_recipients` set.

    test_machines=(test_machine1_x86 test_machine2_arm64)
    test_users=(alice alice)
    test_ssh_ports=(22 2222)
    result_noti_recipients="alice@wonder.land"

The target trees to test are set in `_run.sh` file.  It is currently testing
test LTS, stable, mainline, mm-stable, mm-unstable, mm-new and damon/next
trees.  Modify the file if need to test different target trees.

Test Run
========

Execute `run.sh` file.  It will check updates to the test target trees every
hour.  Then, if any update to any of the tree is found, the script will install
the updated kernel on the 'runner' machines, reboot it, and run the
`damon-tests/corr` tests on it.  Test results are available under `logs`
directory.  Summarized results will be sent to `result_noti_recipients` if it
is set in `config.sh` file.
