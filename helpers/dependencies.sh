#!/usr/bin/env bash
set -euo pipefail

echo " >> WORK: Updating your system..."
echo

sudo pacman -Syu --noconfirm

echo
echo " >> DONE! System updated."
echo " >> WORK: Installing required dependencies..."
echo

DEPS=(
    base-devel git curl wget xz zip unzip rsync cpio bc patch make gcc flex bison lzop
    util-linux e2fsprogs dosfstools mtools openssl ca-certificates sudo which file repo
    python python-setuptools python-virtualenv python-requests python-six python-pyelftools
)

errfile="$(mktemp)"
set +e
sudo pacman -S --needed --noconfirm "${DEPS[@]}" 2>"$errfile"
status=$?
set -e

SKIPPED=()

if [ $status -ne 0 ]; then
    while read -r line; do
        if [[ $line =~ "exists in filesystem" ]]; then
            pkg=$(echo "$line" | awk '{print $1}')
            SKIPPED+=("$pkg")
        fi
    done < "$errfile"
    if [ "${#SKIPPED[@]}" -gt 0 ]; then
        INSTALL_DEPS=()
        for pkg in "${DEPS[@]}"; do
            skip=false
            for s in "${SKIPPED[@]}"; do
                if [[ $pkg == "$s" ]]; then
                    skip=true
                    break
                fi
            done
            $skip || INSTALL_DEPS+=("$pkg")
        done
        if [ "${#INSTALL_DEPS[@]}" -gt 0 ]; then
            sudo pacman -S --needed --noconfirm "${INSTALL_DEPS[@]}"
        fi
    else
        cat "$errfile"
        rm -f "$errfile"
        exit 1
    fi
fi

rm -f "$errfile"
echo
if [ "${#SKIPPED[@]}" -gt 0 ]; then
    echo " >> NOTE: The following packages were skipped due to conflicts:"
    for p in "${SKIPPED[@]}"; do
        echo "    - $p"
    done
else
    echo " >> DONE! All required dependencies installed successfully."
fi