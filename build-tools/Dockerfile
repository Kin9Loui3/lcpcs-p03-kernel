FROM ubuntu:24.04

ARG CPU_TYPE=generic

# Install build dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    linux-headers-generic \
    git \
    bc \
    bison \
    flex \
    libelf-dev \
    libssl-dev \
    pahole \
    wget \
    curl \
    cpio \
    kmod \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /build

# Copy only the build-tools directory
COPY build-tools/ /build/

# Make build script executable
RUN chmod +x /build/build.sh

# Run the build with the specified CPU type
RUN /build/build.sh --cpu-type=${CPU_TYPE}

# Output the kernel
CMD ["bash"]
