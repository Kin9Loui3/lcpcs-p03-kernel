#!/usr/bin/env bash
set -euo pipefail

TKG="/linux-tkg"

# Map CPU_TYPE to _processor_opt
CPU_TYPE="${CPU_TYPE:-generic}"
case "${CPU_TYPE}" in
    zen3)
        _processor_opt="zen3"
        ;;
    zen4)
        _processor_opt="zen4"
        ;;
    zen4c)
        _processor_opt="zen4c"
        ;;
    generic)
        _processor_opt="x86-64"
        ;;
    generic-v3)
        _processor_opt="generic-v3"
        ;;
    generic-v4)
        _processor_opt="generic-v4"
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
        _processor_opt="x86-64"
        ;;
esac

# Set defaults for other variables
_compiler="${_compiler:-llvm}"
_lto_mode="${_lto_mode:-thin}"
_kernel_base="${_kernel_base:-stable}"

SCHEDULERS=("eevdf" "bore" "bmq")

echo "========================================"
echo "Linux TKG P03 Build Configuration"
echo "========================================"
echo "CPU_TYPE: ${CPU_TYPE}"
echo "_processor_opt: ${_processor_opt}"
echo "_compiler: ${_compiler}"
echo "_lto_mode: ${_lto_mode}"
echo "_kernel_base: ${_kernel_base}"
echo "Schedulers: ${SCHEDULERS[*]}"
echo "========================================"

# Create output directory for built packages
mkdir -p /output

# Update customization.cfg with correct processor opt
if [ -f "$TKG/customization.cfg" ]; then
    echo "Updating customization.cfg with _processor_opt=${_processor_opt}"
    sed -i "s/_processor_opt=.*/_processor_opt=\"${_processor_opt}\"/" "$TKG/customization.cfg"
    echo "Updated _processor_opt:"
    grep "_processor_opt=" "$TKG/customization.cfg"
fi

for _cpusched in "${SCHEDULERS[@]}"; do
    echo ""
    echo "========================================="
    echo "Building with $_cpusched scheduler"
    echo "========================================="
    cd "$TKG"
    
    # Clean previous builds
    rm -rf src/ pkg/ *.pkg.tar.* .makepkg.conf 2>/dev/null || true
    
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
    
    # Run makepkg
    if makepkg -s --noconfirm --skippgpcheck LLVM=1 LLVM_IAS=1; then
        echo "✓ Build succeeded for $_cpusched"
        
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
