FROM archlinux:latest

ARG CPU_TYPE=generic

RUN pacman -Syu --noconfirm && \
    pacman -S --noconfirm \
    base-devel \
    clang \
    llvm \
    lld \
    git \
    ccache \
    sudo

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

# Create output directory
RUN mkdir -p /output && chown builder:builder /output

# Switch to builder user
USER builder

# Set environment variables - use ARG value
ENV CPU_TYPE=${CPU_TYPE} \
    _compiler=llvm \
    _lto_mode=thin \
    _kernel_base=stable

# Map CPU_TYPE to _processor_opt
RUN case "${CPU_TYPE}" in \
    zen3) export _processor_opt="zen3" ;; \
    zen4) export _processor_opt="zen4" ;; \
    zen4c) export _processor_opt="zen4c" ;; \
    generic) export _processor_opt="x86-64" ;; \
    generic-v3) export _processor_opt="generic-v3" ;; \
    generic-v4) export _processor_opt="generic-v4" ;; \
    intel-haswell) export _processor_opt="haswell" ;; \
    intel-skylake) export _processor_opt="skylake" ;; \
    intel-broadwell) export _processor_opt="broadwell" ;; \
    *) export _processor_opt="x86-64" ;; \
    esac && \
    echo "_processor_opt=${_processor_opt}" >> /tmp/cpu_mapping.env

# Run the build with CPU mapping
CMD bash -c "source /tmp/cpu_mapping.env && /build-tools/build.sh"
