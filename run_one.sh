#!/bin/bash

set -eu

HELP="""
usage: $0 challenge fuzzer

This will fuzz a challenge for a predefined time.

Define environment variable 'MANUAL=1' to get dropped into a shell. Once before
'prepare' and once before 'fuzz' stage.
"""

if [ ! "$#" -eq 2 ]; then
	echo "${HELP}"
	exit 1
fi
CHALLENGE="$1"
FUZZER="$2"

# ---

CHALLENGE_DIR_ORIG="$(find ./challenges -maxdepth 2 -name "$CHALLENGE")"
test "$(echo "$CHALLENGE_DIR_ORIG" | wc -l)" -eq "1" || \
	(echo "[!] challenge not found (non-uniq name?)"; exit 1)
test -z "${CHALLENGE_DIR_ORIG}" && \
	(echo "[!] challenge not found"; exit 1)
CHALLENGE_DIR_ORIG="$(realpath "${CHALLENGE_DIR_ORIG}")"
echo "[+] found challenge ${CHALLENGE} in ${CHALLENGE_DIR_ORIG}"

test "$(echo "${FUZZER}" | grep "^fuzzer_" | wc -l)" -eq "1" \
	|| (echo "[!] invalid fuzzer name"; exit 1)
test "$(docker images | cut -d' ' -f1 | grep "^${FUZZER}\$" | wc -l)" -eq "1" \
	|| (echo "[!] fuzzer not found"; exit 1)
echo "[+] found fuzzer ${FUZZER}"

OUT_DIR_STORAGE="out/${CHALLENGE}/${FUZZER}/$(date +%s)"
OUT_DIR=$(mktemp -d -p /dev/shm out.XXXXXXXXXX)

# create tmp challenge dir (because in tree builds)
CHALLENGE_DIR=$(mktemp -d -p /tmp challenge.XXXXXXXXXX)
rsync -a "${CHALLENGE_DIR_ORIG}/" "${CHALLENGE_DIR}/"
./challenge_info.py "${CHALLENGE_DIR_ORIG}" > "${CHALLENGE_DIR}/info.sh"

# "empty" input to set
mkdir -p "${CHALLENGE_DIR}/inputs"
echo "fuzz" > "${CHALLENGE_DIR}/inputs/empty"

if [ ! -z ${MANUAL+x} ]; then
	echo "[i] pre-prepare shell"
	docker run --rm -it \
		-v "${CHALLENGE_DIR}:/challenge" \
		-v "${OUT_DIR}:/out" \
		"${FUZZER}"
fi

echo "[*] start prepare phase"
command time -o "${OUT_DIR}/time.prepare" \
	docker run --rm -it \
		-v "${CHALLENGE_DIR}:/challenge" \
		-v "${OUT_DIR}:/out" \
		"${FUZZER}" ./prepare.sh

if [ ! -z ${MANUAL+x} ]; then
	echo "[i] pre-fuzz shell"
	docker run --rm -it \
		-v "${CHALLENGE_DIR}:/challenge" \
		-v "${OUT_DIR}:/out" \
		"${FUZZER}"
fi

echo "[*] start fuzz phase"
command time -o "${OUT_DIR}/time.fuzz" \
	docker run --rm -it \
		-v "${CHALLENGE_DIR}:/challenge" \
		-v "${OUT_DIR}:/out" \
		-e FUZZ_DURATION="25h" \
		"${FUZZER}" ./fuzz.sh

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

echo "[+] archive OUT_DIR to ${OUT_DIR_STORAGE}"
mkdir -p "${OUT_DIR_STORAGE}"
rsync -a "${OUT_DIR}/" "${OUT_DIR_STORAGE}/"
