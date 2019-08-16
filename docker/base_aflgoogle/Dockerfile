FROM base_afl

RUN git clone https://github.com/google/AFL
	
# create clang link to clang-7 in PATH
RUN ln -s /usr/bin/clang-7 /usr/local/bin/clang
RUN ln -s /usr/bin/clang++-7 /usr/local/bin/clang++
RUN ln -s /usr/bin/llvm-config-7 /usr/local/bin/llvm-config

# build
RUN cd AFL && \
	make CC=clang-7 LLVM_CONFIG=llvm-config-7  && \
	make CC=clang-7 LLVM_CONFIG=llvm-config-7 -C llvm_mode

# setup env
ENV AFL_PATH /AFL
ENV PATH "${PATH}:${AFL_PATH}"

# we probably always want this enabled(?)
ENV AFL_HARDEN=1
