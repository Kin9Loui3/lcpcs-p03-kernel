#!/usr/bin/env bash
set -euo pipefail

TKG="/linux-tkg"
CPU_LEVEL="${CPU_LEVEL:-x86-64}"  # default to v1 (LEGACY)
_processor_opt="${_processor_opt:-$CPU_LEVEL}"

[ -d "$TKG" ] || { echo "linux-tkg not found at $TKG"; exit 1; }

echo "=== Building for CPU Level: $CPU_LEVEL ==="

cd "$TKG"

echo "=== Starting kernel build with Clang ==="
_NUKR=true \
    _processor_opt="$_processor_opt" \
    makepkg -s --noconfirm --skippgpcheck \
    CC=clang CXX=clang++ LLVM=1 LLVM_IAS=1

echo "Done. Packages:"
ls -1 "$TKG"/linux-tkg-*.pkg.tar.* 2>/dev/null || echo "(check $TKG for *.pkg.tar.zst)"
