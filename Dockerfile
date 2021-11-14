FROM gcc:11.2.0

# RUN sed -i 's/deb.debian.org/mirrors.ustc.edu.cn/g' /etc/apt/sources.list

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && \
    apt-get -y upgrade && \
    apt-get install -y python3 python-is-python3 sudo \
    git wget curl lsb-release software-properties-common apt-utils \
    binutils build-essential valgrind gdb \
    make cmake autoconf automake \
    autotools-dev autopoint libtool m4 tcl re2c flex bison \
    pkg-config ca-certificates

RUN curl -L https://apt.llvm.org/llvm.sh -o llvm.sh && \
    chmod +x llvm.sh && \
    ./llvm.sh 13 && \
    rm llvm.sh

RUN apt-get install -y lldb-13 lld-13 clang-tidy-13 \
    clang-format-13 clangd-13 llvm-13 && \
    rm -rf /var/lib/apt/lists/*

RUN echo "#!/bin/bash\nexec \"/usr/bin/clang-13\" \"--gcc-toolchain=/usr/local\" \"$@\"" | tee /usr/bin/clang && chmod +x /usr/bin/clang && \
    echo "#!/bin/bash\nexec \"/usr/bin/clang++-13\" \"--gcc-toolchain=/usr/local\" \"$@\"" | tee /usr/bin/clang++ && chmod +x /usr/bin/clang++

RUN ln -s /usr/local/bin/gcc /usr/bin/gcc-11 && \
    ln -s /usr/local/bin/g++ /usr/bin/g++-11 && \
    ln -s /usr/local/bin/gcov /usr/bin/gcov-11 && \
    update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-11 400 && \
    update-alternatives --install /usr/bin/g++ g++ /usr/bin/g++-11 400 && \
    update-alternatives --install /usr/bin/gcov gcov /usr/bin/gcov-11 400 && \
    update-alternatives --install /usr/bin/lld lld /usr/bin/lld-13 400 && \
    update-alternatives --install /usr/bin/ld.lld ld.lld /usr/bin/ld.lld-13 400 && \
    update-alternatives --install /usr/bin/llvm-ar llvm-ar /usr/bin/llvm-ar-13 400 && \
    update-alternatives --install /usr/bin/llvm-nm llvm-nm /usr/bin/llvm-nm-13 400 && \
    update-alternatives --install /usr/bin/llvm-ranlib llvm-ranlib /usr/bin/llvm-ranlib-13 400 && \
    update-alternatives --install /usr/bin/clang-tidy clang-tidy /usr/bin/clang-tidy-13 400 && \
    update-alternatives --install /usr/bin/llvm-profdata llvm-profdata /usr/bin/llvm-profdata-13 400 && \
    update-alternatives --install /usr/bin/llvm-cov llvm-cov /usr/bin/llvm-cov-13 400 && \
    update-alternatives --install /usr/bin/llvm-symbolizer llvm-symbolizer /usr/bin/llvm-symbolizer-13 400 && \
    update-alternatives --install /usr/bin/lldb lldb /usr/bin/lldb-13 400 && \
    update-alternatives --install /usr/bin/clang-format clang-format /usr/bin/clang-format-13 400 && \
    update-alternatives --install /usr/bin/clangd clangd /usr/bin/clangd-13 400

RUN echo kenv ALL=NOPASSWD: ALL > /etc/sudoers.d/kenv && \
    useradd -m -U kenv

USER kenv:kenv

RUN cd /home/kenv && \
    mkdir dependencies && \
    cd dependencies && \
    curl -L https://github.com/KaiserLancelot/kpkg/releases/download/v0.8.0/kpkg-v0.8.0-ubuntu-20.04.deb \
    -o kpkg.deb && \
    sudo dpkg -i kpkg.deb && \
    kpkg install spdlog && \
    sudo ldconfig && \
    cd .. && \
    rm -rf dependencies

ENV ASAN_OPTIONS=detect_stack_use_after_return=1
ENV UBSAN_OPTIONS=print_stacktrace=1
