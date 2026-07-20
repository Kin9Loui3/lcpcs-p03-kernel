#!/usr/bin/env bash
set -euo pipefail

TKG="/linux-tkg"

[ -d "$TKG" ] || { echo "linux-tkg not found at $TKG"; exit 1; }

# Stage customization and patches
cp /build/customization.cfg "$TKG/customization.cfg"
for p in /build/patches/*.patch; do 
    [ -f "$p" ] && cp "$p" "$TKG/$(basename "${p%.patch}").mypatch"
done

echo "Staged $(ls "$TKG"/*.mypatch 2>/dev/null | wc -l) p03 *.mypatch + customization.cfg into linux-tkg."

cd "$TKG"
_NUKR=true makepkg -s --noconfirm --skippgpcheck CC=clang CXX=clang++ LLVM=1 LLVM_IAS=1
echo "Done. Packages:"; ls -1 "$TKG"/linux-tkg-p03*.pkg.tar.* 2>/dev/null || echo "(check $TKG for *.pkg.tar.zst)"
