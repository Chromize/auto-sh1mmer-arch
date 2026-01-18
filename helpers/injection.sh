#!/usr/bin/env bash
set -euo pipefail

echo " >> NOTE: This process will take around 5GB of storage."
echo " >> NOTE: This script injects the Sh1mmer payload into a built shim image."
echo

if [ -z "${1:-}" ]; then
    echo " >> FAIL: No input image specified!"
    exit 1
fi

if [ ! -f "$1" ]; then
    echo " >> FAIL: Input image does not exist: $1"
    exit 1
fi

echo " >> WORK: Downloading Sh1mmer source tree..."
echo

if [ ! -d sh1mmer ]; then
    git clone https://github.com/CoolElectronics/sh1mmer.git
fi

cd sh1mmer/wax

wget -O chromebrew.tar.gz \
    https://raw.githubusercontent.com/Chromize/sh1mmer-archives/main/chromebrew.tar.gz

cp "$1" ./shim.bin

sudo modprobe loop
sudo losetup -f >/dev/null || { echo " >> FAIL: No free loop devices"; exit 1; }

chmod +x ./wax.sh
sudo ./wax.sh shim.bin

[ -f shim.bin ] || { echo " >> FAIL: shim.bin missing after wax"; exit 1; }

echo
echo " >> DONE! Sh1mmer injection completed."
sleep 3

echo " >> WORK: Copying image to auto-sh1mmer-arch directory..."

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cp shim.bin "$SCRIPT_DIR/../sh1mmer-payload.bin"
cd "$SCRIPT_DIR/.." || exit 1
rm -rf sh1mmer