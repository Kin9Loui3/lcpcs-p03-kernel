#!/usr/bin/env bash
set -euo pipefail

TKG="/linux-tkg"

# Map CPU_TYPE to _processor_opt
CPU_TYPE="${CPU_TYPE:-generic}"
case "${CPU_TYPE}" in
    zen3|zen4|zen4c)
        _processor_opt="${CPU_TYPE}"
        ;;
    generic)
        _processor_opt="x86-64"
        ;;
    generic-v3|generic-v4)
        _processor_opt="${CPU_TYPE}"
        ;;
    intel-haswell)
        _processor_opt="haswell"
        ;;
    intel-skylake)
        _processor_opt="skylake"
        ;;
    intel-broadwell)
        _processor_opt="broadwell"
        ;;
    *)
        echo "⚠ Unknown CPU_TYPE: ${CPU_TYPE}, falling back to x86-64"
        _processor_opt="x86-64"
        ;;
esac

# Set defaults for other variables
_compiler="${_compiler:-llvm}"
_lto_mode="${_lto_mode:-thin}"
_kernel_base="${_kernel_base:-stable}"

# Configurable schedulers via environment variable
SCHEDULERS_STR="${SCHEDULERS:-eevdf bore bmq}"
IFS=' ' read -ra SCHEDULERS <<< "$SCHEDULERS_STR"

# ============================================
# PERFORMANCE OPTIMIZATIONS
# ============================================

# Get number of CPU cores
NPROC=$(nproc)
echo "Detected ${NPROC} CPU cores"

# Enable ccache for compilers
export CC="ccache clang"
export CXX="ccache clang++"
export LD="ccache lld"
export HOSTCC="ccache clang"
export HOSTCXX="ccache clang++"

# Set parallel build flags
export MAKEFLAGS="-j${NPROC}"
export KBUILD_PARALLEL="${NPROC}"

# Compiler optimizations (disable debug info for speed)
export KCFLAGS="${KCFLAGS:-} -pipe -O2 -march=${_processor_opt} -g0"
export KCPPFLAGS="${KCPPFLAGS:-} -pipe -O2 -march=${_processor_opt}"

# ccache settings
export CCACHE_DIR="${CCACHE_DIR:-/home/builder/.ccache}"
export CCACHE_MAXSIZE="${CCACHE_MAXSIZE:-10G}"
export CCACHE_COMPRESS="${CCACHE_COMPRESS:-1}"
export CCACHE_COMPRESSLEVEL="${CCACHE_COMPRESSLEVEL:-6}"
export CCACHE_SLOPPINESS="${CCACHE_SLOPPINESS:-pch_defines,time_macros,include_file_mtime,include_file_ctime}"

# Show ccache stats
echo "ccache configuration:"
ccache --show-stats || true

echo "========================================"
echo "Linux TKG Build Configuration"
echo "========================================"
echo "CPU_TYPE: ${CPU_TYPE}"
echo "_processor_opt: ${_processor_opt}"
echo "_compiler: ${_compiler}"
echo "_lto_mode: ${_lto_mode}"
echo "_kernel_base: ${_kernel_base}"
echo "Schedulers: ${SCHEDULERS[*]}"
echo "Parallel jobs: ${NPROC}"
echo "========================================"

# Create output directory for built packages
mkdir -p /output

for _cpusched in "${SCHEDULERS[@]}"; do
    echo ""
    echo "========================================="
    echo "Building with $_cpusched scheduler"
    echo "========================================="
    cd "$TKG"
    
    # Clean previous builds (keep ccache intact)
    echo "Cleaning previous build artifacts..."
    rm -rf src/ pkg/ *.pkg.tar.* 2>/dev/null || true
    
    # Export build variables
    export _NUKR=true
    export _processor_opt="${_processor_opt}"
    export _compiler="${_compiler}"
    export _lto_mode="${_lto_mode}"
    export _kernel_base="${_kernel_base}"
    export _cpusched="${_cpusched}"
    export _llvm_ias="1"
    export _kernel_flavour="tkg"
    
    echo "Build environment:"
    echo "  _processor_opt: ${_processor_opt}"
    echo "  _compiler: ${_compiler}"
    echo "  _cpusched: ${_cpusched}"
    echo "  _lto_mode: ${_lto_mode}"
    echo "  Parallel jobs: ${NPROC}"
    echo "  CCache enabled: yes"
    
    # Run makepkg with performance flags
    if makepkg -s --noconfirm --skippgpcheck \
        LLVM=1 \
        LLVM_IAS=1 \
        CC=ccache\ clang \
        CXX=ccache\ clang++ \
        LD=ccache\ lld; then
        echo "✓ Build succeeded for $_cpusched"
        
        # Show ccache stats after build
        echo "ccache stats after build:"
        ccache --show-stats || true
        
        # Move built packages to output directory
        if mv *.pkg.tar.* /output/ 2>/dev/null; then
            echo "✓ Packages moved to /output"
        else
            echo "⚠ No packages found to move"
        fi
    else
        echo "✗ Build failed for $_cpusched"
        exit 1
    fi
    
    echo "========================================="
done

echo ""
echo "========================================="
echo "All schedulers built successfully!"
echo "========================================="
echo "Packages available in /output:"
ls -lh /output/
echo "========================================="

# Final ccache summary
echo ""
echo "ccache final summary:"
ccache --show-stats || true
