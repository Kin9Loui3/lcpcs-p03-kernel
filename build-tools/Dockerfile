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
    pacman -Scc --noconfirm

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

# Create output directory and ccache directory
RUN mkdir -p /output /home/builder/.ccache && \
    chown -R builder:builder /home/builder/.ccache

# Pre-configure ccache for optimal performance
RUN echo "max_size = 10G" > /home/builder/.ccache/ccache.conf && \
    echo "compression = true" >> /home/builder/.ccache/ccache.conf && \
    echo "compression_level = 6" >> /home/builder/.ccache/ccache.conf && \
    echo "sloppiness = pch_defines,time_macros,include_file_mtime,include_file_ctime" >> /home/builder/.ccache/ccache.conf && \
    echo "cache_dir = /home/builder/.ccache" >> /home/builder/.ccache/ccache.conf

# Switch to builder user
USER builder

# Set environment variables for faster compilation
ENV CPU_TYPE=${CPU_TYPE} \
    _compiler=llvm \
    _lto_mode=thin \
    _kernel_base=stable \
    CCACHE_DIR=/home/builder/.ccache \
    CCACHE_MAXSIZE=10G \
    CCACHE_SLOPPINESS=pch_defines,time_macros,include_file_mtime,include_file_ctime \
    CCACHE_COMPRESS=1 \
    CCACHE_COMPRESSLEVEL=6 \
    MAKEFLAGS="-j$(nproc)" \
    KBUILD_PARALLEL=$(nproc) \
    KCFLAGS="-pipe -O2 -march=${CPU_TYPE} -g0" \
    KCPPFLAGS="-pipe -O2 -march=${CPU_TYPE}" \
    _nofail=1

# Run the build
CMD ["/build-tools/build.sh"]
