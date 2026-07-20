FROM archlinux:latest

ARG CPU_TYPE=generic

RUN pacman -Syu --noconfirm && \
    pacman -S --noconfirm \
    base-devel \
    clang \
    llvm \
    lld \
    git \
    ccache

WORKDIR /linux-tkg

# Clone linux-tkg
RUN git clone https://github.com/Frogging-Family/linux-tkg.git .

# Copy your customization and patches (build context is ./build-tools)
COPY linux-tkg-p03/customization.cfg ./customization.cfg
COPY linux-tkg-p03/patches/ ./patches/
COPY linux-tkg-p03/p03.config ./p03.config
COPY linux-tkg-p03/build.sh /build-tools/build.sh

RUN chmod +x /build-tools/build.sh

# Run the build
RUN /build-tools/build.sh
