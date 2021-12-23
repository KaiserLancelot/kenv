FROM gcc:11.2.0

RUN export DEBIAN_FRONTEND=noninteractive && \
    apt-get update && \
    apt-get -y upgrade && \
    apt-get install -y python3 python-is-python3 sudo \
    git curl lsb-release software-properties-common fuse patchelf \
    locales locales-all binutils binutils-dev build-essential \
    make cmake autoconf automake \
    autotools-dev autopoint libtool m4 tcl tk re2c flex bison \
    pkg-config ca-certificates libdw-dev libdwarf-dev

RUN curl -L https://apt.llvm.org/llvm.sh -o llvm.sh && \
    chmod +x llvm.sh && \
    ./llvm.sh 13 && \
    rm llvm.sh

RUN export DEBIAN_FRONTEND=noninteractive && \
    apt-get install -y lld-13 clang-tidy-13 llvm-13 && \
    rm -rf /var/lib/apt/lists/*

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
    update-alternatives --install /usr/bin/lld lld /usr/bin/lld-13 400 && \
    update-alternatives --install /usr/bin/ld.lld ld.lld /usr/bin/ld.lld-13 400 && \
    update-alternatives --install /usr/bin/llvm-ar llvm-ar /usr/bin/llvm-ar-13 400 && \
    update-alternatives --install /usr/bin/llvm-nm llvm-nm /usr/bin/llvm-nm-13 400 && \
    update-alternatives --install /usr/bin/llvm-ranlib llvm-ranlib /usr/bin/llvm-ranlib-13 400 && \
    update-alternatives --install /usr/bin/clang-tidy clang-tidy /usr/bin/clang-tidy-13 400 && \
    update-alternatives --install /usr/bin/llvm-profdata llvm-profdata /usr/bin/llvm-profdata-13 400 && \
    update-alternatives --install /usr/bin/llvm-cov llvm-cov /usr/bin/llvm-cov-13 400 && \
    update-alternatives --install /usr/bin/llvm-symbolizer llvm-symbolizer /usr/bin/llvm-symbolizer-13 400 && \
    echo "#!/bin/bash\nexec \"/usr/bin/clang-13\" \"--gcc-toolchain=/usr/local\" \"\$@\"" | tee /usr/bin/clang && chmod +x /usr/bin/clang && \
    echo "#!/bin/bash\nexec \"/usr/bin/clang++-13\" \"--gcc-toolchain=/usr/local\" \"\$@\"" | tee /usr/bin/clang++ && chmod +x /usr/bin/clang++

RUN mkdir dependencies && \
    cd dependencies && \
    curl -L https://github.com/KaiserLancelot/kpkg/releases/download/v0.11.2/kpkg-0.11.2-Linux.deb \
    -o kpkg.deb && \
    dpkg -i kpkg.deb && \
    kpkg install cmake ninja doxygen lcov && \
    kpkg install boost catch2 curl fmt icu libarchive nameof zstd \
    openssl spdlog sqlcipher tidy-html5 pugixml onetbb cli11 indicators \
    aria2 semver gsl-lite dbg-macro scope_guard argon2 simdjson opencc \
    simdutf xxHash mimalloc cmark backward-cpp && \
    kpkg install python && \
    python3 -m pip install --upgrade pip && \
    python3 -m pip install nuitka fonttools[woff] && \
    curl -L https://github.com/AppImage/AppImageKit/releases/download/13/appimagetool-x86_64.AppImage \
    -o appimagetool-x86_64.AppImage && \
    mkdir -p /root/.local/share/Nuitka/appimagetool-x86_64.AppImage/x86_64/13 && \
    mv appimagetool-x86_64.AppImage /root/.local/share/Nuitka/appimagetool-x86_64.AppImage/x86_64/13/appimagetool-x86_64.AppImage && \
    cd .. && \
    rm -rf dependencies && \
    dpkg -r kpkg

ENV LC_ALL en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US.UTF-8

ENV CMAKE_GENERATOR Ninja
ENV ASAN_OPTIONS detect_stack_use_after_return=1
ENV UBSAN_OPTIONS print_stacktrace=1
