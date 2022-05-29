FROM gcc:12.1.0

RUN DEBIAN_FRONTEND="noninteractive" apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y sudo neovim \
    git \
    locales locales-all \
    rsync \
    tar gzip zip unzip p7zip-full \
    ca-certificates curl \
    build-essential binutils binutils-dev \
    nasm make meson \
    autoconf automake autotools-dev autopoint m4 libtool pkg-config \
    tcl tk bc libdw-dev libdwarf-dev \
    gdb doxygen && \
    locale-gen en_US.UTF-8

ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

RUN apt-get install -y python3 python-is-python3 python3-pip && \
    python -m pip install --upgrade pip && \
    python -m pip install cmakelang

RUN apt-get install -y lsb-release wget software-properties-common && \
    curl -fsSL https://apt.llvm.org/llvm.sh -o llvm.sh && \
    chmod +x llvm.sh && \
    ./llvm.sh 14 all && \
    rm llvm.sh

RUN apt-get install -y zsh && \
    curl -fsSL https://starship.rs/install.sh -o install.sh && \
    chmod +x install.sh && \
    ./install.sh -y && \
    rm install.sh && \
    mkdir ~/.zsh && \
    curl -fsSL git.io/antigen > ~/.zsh/antigen.zsh && \
    curl -fsSL https://gist.githubusercontent.com/KaiserLancelot/0f2ea5617f6bc30fc3f4b78dcbdeafcd/raw/d21053ab3426171cdcf337d68c97e14a4ba30f25/.zshrc > ~/.zshrc && \
    curl -fsSL https://gist.githubusercontent.com/KaiserLancelot/f5b842eb3f06b1d60733aad5b8ff1baa/raw/1f2d6209a9d508ef05daa2d26e576e50ca97c351/.starship.toml > ~/.starship.toml

SHELL ["/usr/bin/zsh", "-c"]

RUN source ~/.zshrc

RUN ln -s /usr/local/bin/gcc /usr/bin/gcc-12 && \
    ln -s /usr/local/bin/g++ /usr/bin/g++-12 && \
    ln -s /usr/local/bin/gcov /usr/bin/gcov-12 && \
    ln -s /usr/local/bin/gcc-ar /usr/bin/gcc-ar-12 && \
    ln -s /usr/local/bin/gcc-nm /usr/bin/gcc-nm-12 && \
    ln -s /usr/local/bin/gcc-ranlib /usr/bin/gcc-ranlib-12 && \
    update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-12 400 && \
    update-alternatives --install /usr/bin/g++ g++ /usr/bin/g++-12 400 && \
    update-alternatives --install /usr/bin/gcov gcov /usr/bin/gcov-12 400 && \
    update-alternatives --install /usr/bin/gcc-ar gcc-ar /usr/bin/gcc-ar-12 400 && \
    update-alternatives --install /usr/bin/gcc-nm gcc-nm /usr/bin/gcc-nm-12 400 && \
    update-alternatives --install /usr/bin/gcc-ranlib gcc-ranlib /usr/bin/gcc-ranlib-12 400 && \
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
    echo "#!/bin/bash\nexec \"/usr/bin/clang-14\" \"--gcc-toolchain=/usr/local\" \"\$@\"" | tee /usr/bin/clang && chmod +x /usr/bin/clang && \
    echo "#!/bin/bash\nexec \"/usr/bin/clang++-14\" \"--gcc-toolchain=/usr/local\" \"\$@\"" | tee /usr/bin/clang++ && chmod +x /usr/bin/clang++

RUN curl -fsSL https://github.com/KaiserLancelot/klib/releases/download/v1.22.5/klib-1.22.5-Linux.deb \
    -o klib.deb && \
    dpkg -i klib.deb && \
    rm klib.deb

RUN mkdir dependencies && \
    cd dependencies && \
    curl -fsSL https://github.com/KaiserLancelot/kpkg/releases/download/v1.13.3/kpkg-1.13.3-Linux.deb \
    -o kpkg.deb && \
    dpkg -i kpkg.deb && \
    kpkg install cmake ninja mold lcov

ENV CMAKE_GENERATOR Ninja

RUN cd dependencies && \
    kpkg install icu boost catch2 curl fmt libarchive nameof zstd \
    boringssl spdlog sqlcipher tidy-html5 pugixml onetbb cli11 indicators \
    semver gsl dbg-macro scope_guard argon2 simdjson opencc utfcpp \
    simdutf xxHash mimalloc cmark backward-cpp woff2 libvips highway \
    re2 parallel-hashmap libqrencode libmagic && \
    cd .. && \
    rm -rf dependencies && \
    dpkg -r kpkg

ENV ASAN_OPTIONS detect_stack_use_after_return=1:fast_unwind_on_malloc=0
ENV UBSAN_OPTIONS print_stacktrace=1

ENTRYPOINT [ "/usr/bin/zsh" ]
