FROM base_afl

RUN git clone https://github.com/vanhauser-thc/AFLplusplus AFLplusplus
	
# build
RUN cd AFLplusplus && \
	git reset --hard 9246f21f2a75fbe4113dd7340f870679a7953b24 && \
	make && \
	make -C llvm_mode CC=clang-7 CXX=clang-7 LLVM_CONFIG=llvm-config-7

# create clang link to clang-7 in PATH
RUN ln -s /usr/bin/clang-7 /usr/local/bin/clang

# setup env
ENV AFL_PATH /AFLplusplus
ENV PATH "${PATH}:${AFL_PATH}"

# we probably always want this enabled(?)
ENV AFL_HARDEN=1
