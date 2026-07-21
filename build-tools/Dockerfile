FROM archlinux:latest

ARG CPU_TYPE=generic
ARG KERNEL_VERSION=stable

# Update system and install build dependencies
RUN pacman -Syu --noconfirm && \
    pacman -S --noconfirm \
    base-devel \
    clang \
    llvm \
    lld \
    git \
    ccache \
    sudo \
    jq \
    curl \
    wget && \
    pacman -Scc --noconfirm

# Create non-root user for building
RUN useradd -m -s /bin/bash builder && \
    echo "builder ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers.d/builder

WORKDIR /linux-tkg

# Clone linux-tkg
RUN git clone https://github.com/Frogging-Family/linux-tkg.git .

# Copy customization files from build-tools/linux-tkg-p03/
COPY linux-tkg-p03/customization.cfg ./customization.cfg
COPY linux-tkg-p03/patches/ ./patches/
COPY linux-tkg-p03/p03.config ./p03.config
COPY build.sh /build-tools/build.sh

# Set permissions
RUN mkdir -p /output && \
    chmod +x /build-tools/build.sh && \
    chown -R builder:builder /linux-tkg /build-tools /output

# Create ccache directory
RUN mkdir -p /home/builder/.ccache && \
    chown -R builder:builder /home/builder/.ccache

# Pre-configure ccache for optimal performance
RUN echo "max_size = 10G" > /home/builder/.ccache/ccache.conf && \
    echo "compression = true" >> /home/builder/.ccache/ccache.conf && \
    echo "compression_level = 6" >> /home/builder/.ccache/ccache.conf && \
    echo "sloppiness = pch_defines,time_macros,include_file_mtime,include_file_ctime" >> /home/builder/.ccache/ccache.conf && \
    echo "cache_dir = /home/builder/.ccache" >> /home/builder/.ccache/ccache.conf && \
    chown -R builder:builder /home/builder/.ccache

# Create ccache wrapper scripts for clang
RUN mkdir -p /home/builder/bin && \
    echo '#!/bin/bash' > /home/builder/bin/clang && \
    echo 'exec /usr/bin/ccache /usr/bin/clang "$@"' >> /home/builder/bin/clang && \
    echo '#!/bin/bash' > /home/builder/bin/clang++ && \
    echo 'exec /usr/bin/ccache /usr/bin/clang++ "$@"' >> /home/builder/bin/clang++ && \
    chmod +x /home/builder/bin/clang /home/builder/bin/clang++ && \
    chown -R builder:builder /home/builder/bin

# Switch to builder user
USER builder

# Add ccache wrappers to PATH
ENV PATH="/home/builder/bin:${PATH}"

# Set environment variables for faster compilation
ENV CPU_TYPE=${CPU_TYPE} \
    KERNEL_VERSION=${KERNEL_VERSION} \
    _compiler=llvm \
    _lto_mode=thin \
    _kernel_base=stable \
    CCACHE_DIR=/home/builder/.ccache \
    CCACHE_MAXSIZE=10G \
    CCACHE_SLOPPINESS=pch_defines,time_macros,include_file_mtime,include_file_ctime \
    CCACHE_COMPRESS=1 \
    CCACHE_COMPRESSLEVEL=6

# Run the build during image creation
RUN /build-tools/build.sh

# Copy packages to output directory (in case they're needed at runtime)
CMD ["/bin/bash", "-c", "cp /linux-tkg/*.pkg.tar.* /output/ 2>/dev/null; echo 'Build complete - packages are in /output/'"]
