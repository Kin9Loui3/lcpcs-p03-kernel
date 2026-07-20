FROM archlinux:latest

ARG CPU_TYPE=generic

# Update system and install build dependencies
RUN pacman -Syu --noconfirm && \
    pacman -S --noconfirm \
    base-devel \
    clang \
    llvm \
    lld \
    git \
    ccache \
    sudo && \
    pacman -Scc --noconfirm  # Clean package cache to reduce image size

# Create non-root user for building
RUN useradd -m -s /bin/bash builder && \
    echo "builder ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers.d/builder

WORKDIR /linux-tkg

# Clone linux-tkg
RUN git clone https://github.com/Frogging-Family/linux-tkg.git .

# Copy customization files
COPY linux-tkg-p03/customization.cfg ./customization.cfg
COPY linux-tkg-p03/patches/ ./patches/
COPY linux-tkg-p03/p03.config ./p03.config
COPY linux-tkg-p03/build.sh /build-tools/build.sh

# Set permissions
RUN mkdir -p /output && \
    chmod +x /build-tools/build.sh && \
    chown -R builder:builder /linux-tkg /build-tools /output

# Create output directory
RUN mkdir -p /output

# Switch to builder user
USER builder

# Set environment variables
ENV CPU_TYPE=${CPU_TYPE} \
    _compiler=llvm \
    _lto_mode=thin \
    _kernel_base=stable

# Run the build
CMD ["/build-tools/build.sh"]
