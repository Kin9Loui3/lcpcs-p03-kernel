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

# Copy your customization and patches
COPY build-tools/customization.cfg ./customization.cfg
COPY build-tools/patches/ ./patches/
COPY build-tools/build.sh /build-tools/build.sh

RUN chmod +x /build-tools/build.sh

# Run the build
RUN /build-tools/build.sh
