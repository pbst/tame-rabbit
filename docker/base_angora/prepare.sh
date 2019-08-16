#!/bin/sh

set -eu

touch tmp/list.txt
/angora/tools/gen_library_abilist.sh /usr/lib/x86_64-linux-gnu/libz.so discard >> /tmp/list.txt

# compile challenge
cd /challenge/ && ANGORA_TAINT_RULE_LIST=/tmp/list.txt USE_TRACK=1 ./build.sh
bin=$(find /challenge/rebuilt/bin/ -type f)
mv ${bin} /tmp/tmp.bin

#cd /challenge/ && USE_FAST=1 ./build.sh
cd /challenge/ && ./build.sh
mv /tmp/tmp.bin ${bin}.tt

# put metadata in output
mkdir /out/metadata
env > /out/metadata/env.txt
