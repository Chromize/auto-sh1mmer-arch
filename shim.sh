#!/usr/bin/env bash
set -u

if ! command -v pacman >/dev/null; then
    echo "Arch Linux required."
    exit 1
fi

echo
echo " >> NOTE: You may be required to enter your root password various amounts of times."

if [ -z "$1" ]; then
    echo " >> FAIL: No Chromebook board was specified!"
    exit 1
fi

##########################################################

    DEPENDENCIES_INSTALLER="./helpers/dependencies.sh"

    chmod +x "$DEPENDENCIES_INSTALLER"
    "$DEPENDENCIES_INSTALLER"

##########################################################

    BUILDER="./helpers/builder.sh"

    chmod +x "$BUILDER"
    "$BUILDER" "$1"

##########################################################

    INJECTOR="./helpers/injection.sh"
    IMG=~/chromiumos/chroot/mnt/imgs/build_shim.bin

    chmod +x "$INJECTOR"
    [[ -f "$IMG" ]] || { echo "Build image missing!"; exit 1; }
    "$INJECTOR" "$IMG"

    echo
    echo " >> DONE! Your image should be located in \"./sh1mmer-payload.bin\"."
    echo " >> NOTE: You can flash this image to your flash drive or SD card using the following command:"
    echo
    echo " dd if=./sh1mmer-payload.bin of=/dev/sdx"
    echo
    echo " >> NOTE: \"/dev/sdx\" should be replaced with the block device representing your flash drive or SD card."

##########################################################

echo
echo ">> NOTE: Help keep maintenance for auto shimming on our GitHub by starring our repository!"
echo ">> NOTE: https://github.com/Chromize/auto-sh1mmer-arch"
