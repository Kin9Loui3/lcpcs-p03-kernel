#!/bin/bash
set -e

echo "Starting kernel build for CPU_TYPE=${CPU_TYPE}, KERNEL_VERSION=${KERNEL_VERSION}"

cd /linux-tkg

# Update PKGBUILD for custom kernel version if specified
if [ "${KERNEL_VERSION}" != "stable" ]; then
    echo "Setting kernel version to ${KERNEL_VERSION}"
    sed -i "s/_linux_version=.*/_linux_version=${KERNEL_VERSION}/" customization.cfg
fi

# Set CPU type
echo "Setting CPU type to ${CPU_TYPE}"
sed -i "s/_processor_opt=.*/_processor_opt=${CPU_TYPE}/" customization.cfg

# Enable P03 patchset if config exists
if [ -f p03.config ]; then
    echo "Applying P03 patchset configuration"
    cat p03.config >> customization.cfg
fi

# Set compiler to LLVM/Clang
echo "Configuring for LLVM/Clang compilation"
sed -i "s/_compiler=.*/_compiler=llvm/" customization.cfg
sed -i "s/_lto_mode=.*/_lto_mode=thin/" customization.cfg
sed -i "s/_use_llvm_lto=.*/_use_llvm_lto=1/" customization.cfg

# Enable ccache
sed -i "s/_use_ccache=.*/_use_ccache=1/" customization.cfg

# Set make flags for parallel compilation
NPROC=$(nproc)
sed -i "s/_makeflags=.*/_makeflags=-j${NPROC}/" customization.cfg

# Build the kernel
echo "Starting kernel build..."
cd /linux-tkg
makepkg -s --noconfirm

# List built packages
echo "Built packages:"
ls -la /linux-tkg/*.pkg.tar.*

# Copy packages to output directory
mkdir -p /output
cp /linux-tkg/*.pkg.tar.* /output/ 2>/dev/null || echo "No packages found to copy"

echo "Build completed successfully!"
