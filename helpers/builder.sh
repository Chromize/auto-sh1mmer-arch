#!/usr/bin/env bash
set -euo pipefail

if [ -z "${1:-}" ]; then
    echo " >> FAIL: No Chromebook board specified!"
    exit 1
fi

BOARD="$(echo "$1" | tr '[:upper:]' '[:lower:]')"
BASE_URL="https://dl.cros.download/files"
REMOTE_PATH="${BOARD}/${BOARD}.zip"
DOWNLOAD_URL="${BASE_URL}/${REMOTE_PATH}"

echo " >> NOTE: This will download an existing RMA shim."
echo " >> NOTE: Board specified: \"$BOARD\""
echo " >> EXIT: Cancel now if this is wrong (3 seconds)..."
sleep 3

WORKDIR="$(pwd)/shims/${BOARD}"
mkdir -p "$WORKDIR"
cd "$WORKDIR"
echo $WORKDIR

if [ -f "${WORKDIR}/${BOARD}.bin" ]; then
    echo " >> INFO: Shim already exists, skipping download."
else
    echo " >> WORK: Checking if shim exists for board \"$BOARD\"..."

    if ! curl -sfI "$DOWNLOAD_URL" >/dev/null; then
        echo " >> FAIL: No shim found for board \"$BOARD\""
        echo " >> INFO: Check available boards at https://cros.download/shims"
        exit 1
    fi

    echo " >> WORK: Downloading shim..."
    echo
    curl -fL -o "${BOARD}.zip" "$DOWNLOAD_URL"

    echo
    echo " >> WORK: Extracting shim..."
    if ! unzip -o "${BOARD}.zip"; then
        echo " >> FAIL: Extraction failed. Please check the zip file."
        exit 1
    fi
fi

echo " >> DONE! RMA shim downloaded."