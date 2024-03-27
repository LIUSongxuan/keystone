#!/bin/bash
set -e

# Arguments
#	1. Bitness (i.e. 32, 64)

if [[ "$#" -lt 1 ]]; then
	echo "usage: test-generic.sh [bits]"
	exit 1
fi

export KEYSTONE_BITS="$1"

if [[ -z "$CMD_LOGFILE" ]]; then
	echo "CMD_LOGFILE undefined"
	exit 1
fi

###############
## Run tests ##
###############
set -x

# Fix permissions on the key
chmod 600 "build-generic$KEYSTONE_BITS/buildroot.build/target/root/.ssh/id-rsa"

# Launch QEMU
export KEYSTONE_PLATFORM="generic"
export QEMU_PORT=$(( RANDOM + 1024 ))
export LD_LIBDRARY_PATH="build-generic$KEYSTONE_BITS/buildroot.build/host/lib"
screen -L -dmS qemu bash -c "make run 2>&1 | tee $LOGFILE"

# TODO: check for connectivity instead of sleeping
sleep 60

export CALL_LOGFILE="$CMD_LOGFILE"
echo "" > "$CALL_LOGFILE"

KEYSTONE_COMMAND="modprobe keystone-driver" make call
KEYSTONE_COMMAND="/usr/share/keystone/examples/tests.ke" make call
KEYSTONE_COMMAND="/usr/share/keystone/examples/attestor.ke" make call
KEYSTONE_COMMAND="poweroff" make call

screen -S qemu -X quit
exit 0
