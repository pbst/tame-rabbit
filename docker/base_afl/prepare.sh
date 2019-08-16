#!/bin/sh

set -eu

# compile challenge
cd /challenge/ && ./build.sh

# put metadata in output
mkdir /out/metadata
env > /out/metadata/env.txt
