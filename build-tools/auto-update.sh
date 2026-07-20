# ===== KERNEL AUTO-UPDATE =====

# Check latest kernel version
get_latest_kernel() {
    curl -s https://www.kernel.org/releases.json | jq -r '.releases[0].version' 2>/dev/null || echo ""
}

# Get current version from build.sh
get_current_kernel_version() {
    grep 'KERNEL_VERSION=' zen3/latest/build.sh | head -1 | cut -d'"' -f2
}

# Update all kernel build scripts
update_kernel_scripts() {
    local new_version="$1"
    sed -i "s/KERNEL_VERSION=\"[0-9.]*\"/KERNEL_VERSION=\"$new_version\"/" zen3/latest/build.sh
    sed -i "s/KERNEL_VERSION=\"[0-9.]*\"/KERNEL_VERSION=\"$new_version\"/" zen3/lts/build.sh
    sed -i "s/KERNEL_VERSION=\"[0-9.]*\"/KERNEL_VERSION=\"$new_version\"/" zen3/rc/build.sh
    echo "Kernel updated to $new_version"
}

# Check and update kernels
LATEST_KERNEL=$(get_latest_kernel)
CURRENT_KERNEL=$(get_current_kernel_version)

if [ "$LATEST_KERNEL" != "$CURRENT_KERNEL" ] && [ -n "$LATEST_KERNEL" ]; then
    echo "New kernel: $LATEST_KERNEL"
    update_kernel_scripts "$LATEST_KERNEL"
    ./zen3/latest/build.sh
    ./zen3/lts/build.sh
    ./zen3/rc/build.sh
fi
