#!/bin/bash

set -eu

images=""

# base images
images="${images} base"
images="${images} base_afl"
images="${images} base_aflgoogle"
images="${images} base_aflplusplus"
images="${images} base_angora"

source all_fuzzers.sh

for image in ${images}; do
	echo "[*] build $image..."
	docker build -t ${image} docker/${image}
done
