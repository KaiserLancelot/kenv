FROM gcc:11.2.0

RUN DEBIAN_FRONTEND="noninteractive" apt-get update && \
    apt-get install -y tzdata

RUN apt-get upgrade -y && \
    apt-get install -y python3 python-is-python3 python3-pip sudo \
    git curl lsb-release software-properties-common \
    locales locales-all binutils binutils-dev build-essential \
    make cmake autoconf automake \
    autotools-dev autopoint libtool m4 tcl tk re2c \
    pkg-config ca-certificates libdw-dev libdwarf-dev bc gdb tar rsync dos2unix \
    perl golang libunwind-dev nasm zsh doxygen

RUN sh -c "$(curl -fsSL https://github.com/deluan/zsh-in-docker/releases/download/v1.1.2/zsh-in-docker.sh)"

RUN curl -L https://apt.llvm.org/llvm.sh -o llvm.sh && \
    chmod +x llvm.sh && \
    ./llvm.sh 14 && \
    rm llvm.sh

RUN apt-get install -y lld-14 llvm-14 lldb-14 \
    clang-tidy-14 clang-format-14 clangd-14 && \
    apt-get clean

RUN ln -s /usr/local/bin/gcc /usr/bin/gcc-11 && \
    ln -s /usr/local/bin/g++ /usr/bin/g++-11 && \
    ln -s /usr/local/bin/gcov /usr/bin/gcov-11 && \
    ln -s /usr/local/bin/gcc-ar /usr/bin/gcc-ar-11 && \
    ln -s /usr/local/bin/gcc-nm /usr/bin/gcc-nm-11 && \
    ln -s /usr/local/bin/gcc-ranlib /usr/bin/gcc-ranlib-11 && \
    update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-11 400 && \
    update-alternatives --install /usr/bin/g++ g++ /usr/bin/g++-11 400 && \
    update-alternatives --install /usr/bin/gcov gcov /usr/bin/gcov-11 400 && \
    update-alternatives --install /usr/bin/gcc-ar gcc-ar /usr/bin/gcc-ar-11 400 && \
    update-alternatives --install /usr/bin/gcc-nm gcc-nm /usr/bin/gcc-nm-11 400 && \
    update-alternatives --install /usr/bin/gcc-ranlib gcc-ranlib /usr/bin/gcc-ranlib-11 400 && \
    update-alternatives --install /usr/bin/lld lld /usr/bin/lld-14 400 && \
    update-alternatives --install /usr/bin/ld.lld ld.lld /usr/bin/ld.lld-14 400 && \
    update-alternatives --install /usr/bin/llvm-ar llvm-ar /usr/bin/llvm-ar-14 400 && \
    update-alternatives --install /usr/bin/llvm-nm llvm-nm /usr/bin/llvm-nm-14 400 && \
    update-alternatives --install /usr/bin/llvm-ranlib llvm-ranlib /usr/bin/llvm-ranlib-14 400 && \
    update-alternatives --install /usr/bin/llvm-profdata llvm-profdata /usr/bin/llvm-profdata-14 400 && \
    update-alternatives --install /usr/bin/llvm-cov llvm-cov /usr/bin/llvm-cov-14 400 && \
    update-alternatives --install /usr/bin/llvm-symbolizer llvm-symbolizer /usr/bin/llvm-symbolizer-14 400 && \
    update-alternatives --install /usr/bin/lldb lldb /usr/bin/lldb-14 400 && \
    update-alternatives --install /usr/bin/clang-tidy clang-tidy /usr/bin/clang-tidy-14 400 && \
    update-alternatives --install /usr/bin/clang-format clang-format /usr/bin/clang-format-14 400 && \
    update-alternatives --install /usr/bin/clangd clangd /usr/bin/clangd-14 400 && \
    echo "#!/bin/bash\nexec \"/usr/bin/clang-14\" \"--gcc-toolchain=/usr/local\" \"\$@\"" | tee /usr/bin/clang && chmod +x /usr/bin/clang && \
    echo "#!/bin/bash\nexec \"/usr/bin/clang++-14\" \"--gcc-toolchain=/usr/local\" \"\$@\"" | tee /usr/bin/clang++ && chmod +x /usr/bin/clang++

RUN curl -L https://github.com/KaiserLancelot/klib/releases/download/v1.10.0/klib-1.10.0-Linux.deb \
    -o klib.deb && \
    dpkg -i klib.deb && \
    rm klib.deb

RUN mkdir dependencies && \
    cd dependencies && \
    curl -L https://github.com/KaiserLancelot/kpkg/releases/download/v1.3.10/kpkg-1.3.10-Linux.deb \
    -o kpkg.deb && \
    dpkg -i kpkg.deb && \
    kpkg install cmake ninja mold lcov \
    icu boost catch2 curl fmt libarchive nameof zstd \
    boringssl spdlog sqlcipher tidy-html5 pugixml onetbb cli11 indicators \
    semver gsl dbg-macro scope_guard argon2 simdjson opencc utfcpp \
    simdutf xxHash mimalloc cmark backward-cpp llhttp woff2 libwebp && \
    apt-get remove -y cmake && \
    apt-get autoremove -y && \
    cd .. && \
    rm -rf dependencies

ENV LC_ALL en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US.UTF-8

ENV CMAKE_GENERATOR Ninja
ENV ASAN_OPTIONS detect_stack_use_after_return=1
ENV UBSAN_OPTIONS print_stacktrace=1
