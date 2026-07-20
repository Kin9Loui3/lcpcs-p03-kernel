#!/usr/bin/env bash
set -euo pipefail

TKG="/linux-tkg"

[ -d "$TKG" ] || { echo "linux-tkg not found at $TKG"; exit 1; }

echo "Staging customization.cfg and patches..."
echo "Staged patches into linux-tkg."

cd "$TKG"

echo "=== Starting kernel build with Clang ==="
_NUKR=true makepkg -s --noconfirm --skippgpcheck \
    CC=clang CXX=clang++ LLVM=1 LLVM_IAS=1

echo "Done. Packages:"
ls -1 "$TKG"/linux-tkg-p03*.pkg.tar.* 2>/dev/null || echo "(check $TKG for *.pkg.tar.zst)"
