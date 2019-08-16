#!/bin/bash

set -eu

# - map challenge out dir.
# - verify and map crashes to their LAVAID
# - feed this data to analysis script(python)
#
# Normally the functionality of this scipt is included in the eval phase of a run and automaticly
# executed. So this script is just here to allow to easily verify bugs in debugging situations.

HELP="""
usage: $0 challenge fuzzer timestamp

example: $0 xtoy1 fuzzer_aflplusplus_default 1372924742

Validate crashes and generate report for all .
"""

if [ ! "$#" -eq 3 ]; then
	echo "${HELP}"
	exit 1
fi
CHALLENGE="$1"
FUZZER="$2"
TIMESTAMP="$3"

# ---

CHALLENGE_DIR_ORIG="$(find ./challenges -maxdepth 2 -name "$CHALLENGE")"
test "$(echo "$CHALLENGE_DIR_ORIG" | wc -l)" -eq "1" || \
	(echo "[!] challenge not found (non-uniq name?)"; exit 1)
test -z "$CHALLENGE_DIR_ORIG" && \
	(echo "[!] challenge not found"; exit 1)
CHALLENGE_DIR_ORIG="$(realpath "${CHALLENGE_DIR_ORIG}")"
echo "[+] found challenge $CHALLENGE in $CHALLENGE_DIR_ORIG"

test "$(echo "${FUZZER}" | grep "^fuzzer_" | wc -l)" -eq "1" \
	|| (echo "[!] invalid fuzzer name"; exit 1)
test "$(docker images | cut -d' ' -f1 | grep "^${FUZZER}\$" | wc -l)" -eq "1" \
	|| (echo "[!] fuzzer not found"; exit 1)
echo "[+] found fuzzer ${FUZZER}"

OUT_DIR_STORAGE="$(realpath "out/${CHALLENGE}/${FUZZER}/${TIMESTAMP}")"
test -d "${OUT_DIR_STORAGE}" || \
	(echo "[!] could not find output directory for given timesamp"; exit 1)

OUT_DIR="${OUT_DIR_STORAGE}"

# create tmp challenge dir (because in tree builds)
CHALLENGE_DIR=$(mktemp -d -p /tmp challenge.XXXXXXXXXX)
rsync -a "${CHALLENGE_DIR_ORIG}/" "${CHALLENGE_DIR}/"
./challenge_info.py "${CHALLENGE_DIR_ORIG}" > "${CHALLENGE_DIR}/info.sh"

if [ ! -z ${MANUAL+x} ]; then
	echo "[i] pre-eval shell"
	docker run --rm -it \
		-v "${CHALLENGE_DIR}:/challenge" \
		-v "${OUT_DIR}:/out" \
		"${FUZZER}"
fi

echo "[*] start eval phase"
command time -o "${OUT_DIR}/time.eval" \
	docker run --rm -it \
		-v "${CHALLENGE_DIR}:/challenge" \
		-v "${OUT_DIR}:/out" \
		"${FUZZER}" "./eval.sh"
