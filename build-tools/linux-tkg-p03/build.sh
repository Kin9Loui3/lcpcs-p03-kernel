#!/usr/bin/env bash
set -euo pipefail

TKG="/linux-tkg"
CPU_LEVEL="${CPU_LEVEL:-x86-64}"
_processor_opt="${_processor_opt:-$CPU_LEVEL}"
_compiler="${_compiler:-llvm}"
_lto_mode="${_lto_mode:-thin}"
_kernel_base="${_kernel_base:-stable}"

SCHEDULERS=("eevdf" "bore" "bmq")

# Create output directory for built packages
mkdir -p /output

for _cpusched in "${SCHEDULERS[@]}"; do
    echo "=== Building with $_cpusched scheduler ==="
    cd "$TKG"
    
    export _NUKR=true
    export _processor_opt="$_processor_opt"
    export _compiler="$_compiler"
    export _lto_mode="$_lto_mode"
    export _kernel_base="$_kernel_base"
    export _cpusched="$_cpusched"
    export _llvm_ias="1"
    export _kernel_flavour="tkg"
    
    makepkg -s --noconfirm --skippgpcheck LLVM=1 LLVM_IAS=1
    
    # Move built packages to output directory
    mv *.pkg.tar.* /output/ 2>/dev/null || true
    
    echo "=== $_cpusched build complete ==="
done

echo "=== All schedulers built successfully ==="
echo "=== Packages available in /output ==="
ls -lh /output/
