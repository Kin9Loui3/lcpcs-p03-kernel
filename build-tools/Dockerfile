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

WORKDIR /build

# Clone linux-tkg
RUN git clone https://github.com/Frogging-Family/linux-tkg.git /linux-tkg

# Copy your customization and patches
COPY build-tools/customization.cfg /build/customization.cfg
COPY build-tools/patches/ /build/patches/
COPY build-tools/build.sh /build/build.sh

RUN chmod +x /build/build.sh

# Run the build
RUN /build/build.sh
