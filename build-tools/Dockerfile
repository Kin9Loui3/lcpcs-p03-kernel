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

# Create a non-root user for building
RUN useradd -m -s /bin/bash builder && \
    echo "builder ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers.d/builder

WORKDIR /linux-tkg

# Clone linux-tkg
RUN git clone https://github.com/Frogging-Family/linux-tkg.git .

# Copy your customization and patches
COPY linux-tkg-p03/customization.cfg ./customization.cfg
COPY linux-tkg-p03/patches/ ./patches/
COPY linux-tkg-p03/p03.config ./p03.config
COPY linux-tkg-p03/build.sh /build-tools/build.sh

RUN chmod +x /build-tools/build.sh

# Change ownership to builder user
RUN chown -R builder:builder /linux-tkg /build-tools

# Switch to builder user
USER builder

# Run the build
RUN /build-tools/build.sh
