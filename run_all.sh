#!/bin/bash

set -eu

HELP="""
usage $0 challenge

Sequentially run run_one.sh with each available fuzzer (listed in
all_fuzzers.sh) on the challenge. This may take a while.
"""

if [ ! "$#" -eq 1 ]; then
	echo "${HELP}"
	exit 1
fi

challenge="$1"

images=""

source all_fuzzers.sh

for image in ${images}; do
	echo "[*] fuzzer $image..."
	./fuzzit.sh $challenge $image
done
