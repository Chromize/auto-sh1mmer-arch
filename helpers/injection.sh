#!/usr/bin/env bash
set -euo pipefail

echo " >> NOTE: This process will take around 5GB of storage."
echo " >> NOTE: This script injects the Sh1mmer payload into a built shim image."

if [ -z "${1:-}" ]; then
    echo " >> FAIL: No input image specified!"
    exit 1
fi

if [ ! -f "$1" ]; then
    echo " >> FAIL: Input image does not exist: $1"
    exit 1
fi

echo " >> WORK: Downloading Sh1mmer source tree...Setting stuff up..."
echo

if [ ! -d sh1mmer ]; then
    git clone https://github.com/CoolElectronics/sh1mmer.git
fi

cd ./sh1mmer/wax
wget -O chromebrew.tar.gz \
    https://raw.githubusercontent.com/Chromize/chromeOS-archives/main/chromebrew.tar.gz

sudo modprobe loop
sudo losetup -f >/dev/null || { echo " >> FAIL: No free loop devices"; exit 1; }

chmod +x ./wax.sh
sudo ./wax.sh -i $1
cd ../..

echo
echo " >> DONE! Sh1mmer injection completed."
echo " >> WORK: Moving image to auto-sh1mmer-arch directory..."

mv $1 ./build
rm -rf sh1mmer
rm -rf shims
