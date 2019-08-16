#!/bin/bash

set -eu

# create dated copies of a file when the sha1sum does not match the one of the previous check

if [ ! "$#" -eq "1" ]; then
	echo "usage: $0 filename"
	exit 1
fi

filename="$1"

old_sum="0000000000000000000000000000000000000000"
while true; do
	new_sum="$(sha1sum -- "${filename}" | cut -d' ' -f 1)"
	if [ "${new_sum}" != "${old_sum}" ]; then
		ts="$(date +%s)"
		echo "${old_sum} -> ${new_sum} @ ${ts}"
		cp -- "${filename}" "${filename}.${ts}"
	fi
	old_sum="${new_sum}"
	sleep 3
done

