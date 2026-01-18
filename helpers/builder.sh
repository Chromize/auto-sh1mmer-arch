#!/usr/bin/env bash
set -euo pipefail
echo

if [ -z "${1:-}" ]; then
    echo " >> FAIL: No Chromebook board specified!"
    exit 1
fi

echo " >> NOTE: This uses around 45GB of disk space."
echo " >> NOTE: Is \"$1\" your Chromebook's board? Cancel if not!"
echo " >> EXIT: You can safely exit for the next 8 SECONDS..."
sleep 8

mkdir -p build && cd build

echo " >> WORK: Downloading depot_tools..."
echo
if [ ! -d depot_tools ]; then
    git clone https://chromium.googlesource.com/chromium/tools/depot_tools.git
fi

DEPOT_TOOLS_DIR="$(pwd)/depot_tools"
export PATH="$DEPOT_TOOLS_DIR:$PATH"

echo
echo " >> WORK: Checking system architecture..."
if ! uname -m | grep -q "64"; then
    echo " >> ARCH: 32-bit is not supported."
    exit 1
fi

echo " >> WORK: Creating source directory..."
mkdir -p ~/chromiumos && cd ~/chromiumos

echo " >> WORK: Initializing repo for Chromium OS..."
echo
if ! echo "y" | repo init -u https://chromium.googlesource.com/chromiumos/manifest -b main -g minilayout; then
    echo " >> FAIL: Failed to initialize repo. Please check your network or the manifest URL."
    exit 1
fi

echo
echo " >> WORK: Syncing repositories..."
echo
if ! repo sync -j"$(nproc)"; then
    echo " >> FAIL: Repo sync failed. Check for missing dependencies or network issues."
    exit 1
fi

if [ ! -d "$HOME/chromiumos/.repo" ]; then
    echo " >> FAIL: Repo initialization failed. '.repo' directory not found!"
    exit 1
fi

echo
echo " >> WORK: Setting up cros_sdk..."
if ! cros_sdk --debug; then
    echo " >> FAIL: Failed to set up cros_sdk."
    exit 1
fi

echo " >> WORK: Starting chroot-based build..."
cros_sdk -- bash -e <<EOT
    sudo mkdir -p /mnt/imgs

    setup_board --board=$1

    cros build-packages --board=$1
    cros build-image --board=$1

    echo
    echo " >> WORK: Building RMA shim for board: \"$1\""
EOT

echo " >> DONE! RMA shim developed."
echo " >> NOTE: Image located at ~/chromiumos/chroot/mnt/imgs/build_shim.bin"