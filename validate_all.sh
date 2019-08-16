#!/bin/bash

# help to run one_validate.sh for each run that do not have a crashids.txt

set -eu

RUNDIRS=$(find ./out/ -mindepth 3 -maxdepth 3 -type d)


for RUNDIR in $RUNDIRS; do
	# filter runs with crashids.txt present
	test -e $RUNDIR/crashids.txt && continue

	# split paths
	challenge="$(echo $RUNDIR | cut -d'/' -f 3)"
	fuzzer="$(echo $RUNDIR | cut -d'/' -f 4)"
	timestamp="$(echo $RUNDIR | cut -d'/' -f 5)"

	# run one verify
	echo $challenge $fuzzer $timestamp
	./validate_one.sh $challenge $fuzzer $timestamp
done
