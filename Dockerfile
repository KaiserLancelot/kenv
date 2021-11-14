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

RUN mv /usr/local/bin/* /usr/bin && \
    cp -r /usr/local/include/* /usr/include && \
    rm -rf /usr/local/include/* && \
    cp -r /usr/local/lib/* /usr/lib && \
    rm -rf /usr/local/lib/* && \
    cp -r /usr/local/lib64/* /usr/lib32 && \
    rm -rf /usr/local/lib64/* && \
    cp -r /usr/local/libexec/* /usr/libexec  && \
    rm -rf /usr/local/libexec/* && \
    cp -r /usr/local/share/* /usr/share  && \
    rm -rf /usr/local/share/* && \
    ln -s /usr/bin/gcc /usr/bin/gcc-11 && \
    ln -s /usr/bin/g++ /usr/bin/g++-11 && \
    ln -s /usr/bin/gcov /usr/bin/gcov-11 && \
    update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-11 400 && \
    update-alternatives --install /usr/bin/g++ g++ /usr/bin/g++-11 400 && \
    update-alternatives --install /usr/bin/gcov gcov /usr/bin/gcov-11 400 && \
    update-alternatives --install /usr/bin/clang clang /usr/bin/clang-13 400 && \
    update-alternatives --install /usr/bin/clang++ clang++ /usr/bin/clang++-13 400 && \
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
    update-alternatives --install /usr/bin/clangd clangd /usr/bin/clangd-13 400 && \
    ldconfig

RUN mkdir dependencies && \
    cd dependencies && \
    curl -L https://github.com/KaiserLancelot/kpkg/releases/download/v0.8.0/kpkg-v0.8.0-ubuntu-20.04.deb \
    -o kpkg.deb && \
    dpkg -i kpkg.deb && \
    kpkg install spdlog && \
    ldconfig && \
    cd .. && \
    rm -rf dependencies

RUN echo kenv ALL=NOPASSWD: ALL > /etc/sudoers.d/kenv && \
    useradd -m -U kenv

USER kenv:kenv
