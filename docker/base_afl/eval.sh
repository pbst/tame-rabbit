#!/bin/bash

set -eu

source /challenge/info.sh

function getcrashid () {
	filename="$1"
	args="$(echo "${BINARY_ARGUMENTS}" | sed -e "s|@@|$filename|")"
	lava_id="$(/challenge/built.lavalog/${BINARY_PATH} ${args} 2>&1 \
		| grep LAVALOG | cut -d':' -f2 | tr -d ' ')"
	if [ ! -z "${lava_id}" ]; then
		echo "$lava_id $filename" >> /out/crashids.txt
	fi
}

test ! -e /out/crashids.txt || (echo "crashids.txt already present." && exit 0)

crashes_dirs="$(find /out/ -type d -name crashes)"
for crashes_dir in ${crashes_dirs}; do
	crashes="$(find "${crashes_dir}" -name "id:*")"
	for crash in ${crashes}; do
		getcrashid "${crash}"
	done
done

# create empty crashids.txt so we know there were no valid crashes
touch /out/crashids.txt
