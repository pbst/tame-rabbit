#!/bin/bash

set -eu

source /challenge/info.sh

echo "start fuzzing..."

# start fuzzers
afl-fuzz -M master -o /out -i /challenge/inputs ${AFL_FLAGS} -- ${BINARY_PREFIX}/${BINARY_PATH} ${BINARY_ARGUMENTS} > /out/afl_master.log 2>&1 &
#afl-fuzz -S slave1 -o /out -i /challenge/inputs ${AFL_FLAGS} -- ${BINARY_PREFIX}/${BINARY_PATH} ${BINARY_ARGUMENTS} > /out/afl_slave1.log 2>&1 &
#afl-fuzz -S slave2 -o /out -i /challenge/inputs ${AFL_FLAGS} -- ${BINARY_PREFIX}/${BINARY_PATH} ${BINARY_ARGUMENTS} > /out/afl_slave2.log 2>&1 &

# give AFL time to terminate itsef (in case there are errors)
sleep 5s

# if there are AFL instances missing we want to terminate early
test "$(ps | grep afl-fuzz | wc -l)" -eq "1"
echo "if you can read this AFL is running :)"

# do log all the fuzzer_stats
./stats.sh /out/master/fuzzer_stats &

# let AFL run for $FUZZ_DURATION
sleep $FUZZ_DURATION

# terminate afl instances
pkill -P $$

# indicate that everything went smooth
date +%s > "/out/done"

# make out files world readable
find /out -type f -exec chmod 644 {} \;
find /out -type d -exec chmod 755 {} \;
