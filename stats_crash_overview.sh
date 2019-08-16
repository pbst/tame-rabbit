#!/bin/bash

set -eu

# provide number of unique validated crashes for each run based on crashids.txt

RUNDIRS=$(find ./out/ -mindepth 3 -maxdepth 3 -type d)


for RUNDIR in $RUNDIRS; do
	# filter out runs that do not have a crashids.txt present
	test -e $RUNDIR/crashids.txt || continue


	#echo  $RUNDIR/crashids.txt
	num="$(cat $RUNDIR/crashids.txt | cut -d' ' -f1 | sort | uniq | wc -l)"

	# split paths
	challenge="$(echo $RUNDIR | cut -d'/' -f 3)"
	fuzzer="$(echo $RUNDIR | cut -d'/' -f 4)"
	timestamp="$(echo $RUNDIR | cut -d'/' -f 5)"

	#echo "${challenge} ${fuzzer} ${timestamp} ${num}"
	echo "${challenge} ${fuzzer} ${num}"
done
