#!/bin/bash

# create fuzzer_stats files copies and append a timestamp to the the duplicate
# TODO: only copy when changed..

while true; do
	find /out/ -name fuzzer_stats -exec cp {} {}.$(date +%s) \;
	sleep 10s
done
