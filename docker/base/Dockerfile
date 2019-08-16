FROM ubuntu:18.04

RUN \
	dpkg --add-architecture i386 && \
	apt-get update && \
	apt-get install -y \
		build-essential \
		clang-7 \
		git \
		libc6-dev-i386 \
		zlib1g-dev:i386
