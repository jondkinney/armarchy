#!/bin/bash

echo "Installing Omarchy Chromium for ARM64..."

# Define package details
PACKAGE_VERSION="139.0.7258.154-2"
PACKAGE_NAME="omarchy-chromium-${PACKAGE_VERSION}-aarch64.pkg.tar.zst"
DOWNLOAD_URL="https://github.com/omacom-io/omarchy-chromium/releases/download/v${PACKAGE_VERSION}/${PACKAGE_NAME}"

# Check if already installed
if pacman -Q omarchy-chromium &>/dev/null; then
    echo "Omarchy Chromium is already installed, skipping..."
    return 0
fi

# Create temp directory for download
TEMP_DIR=$(mktemp -d)
cd "$TEMP_DIR"

# Check if package file already exists in temp directory or download it
if [[ -f "$PACKAGE_NAME" ]]; then
    echo "Package ${PACKAGE_NAME} already exists, skipping download..."
else
    echo "Downloading ${PACKAGE_NAME}..."
    wget "$DOWNLOAD_URL"
fi

if [[ -f "$PACKAGE_NAME" ]]; then
    echo "Installing Omarchy Chromium package..."
    sudo pacman -U --noconfirm "$PACKAGE_NAME"
    echo "Omarchy Chromium installed successfully"
else
    echo "ERROR: Failed to download ${PACKAGE_NAME}" >&2
    exit 1
fi

# Cleanup
cd /
rm -rf "$TEMP_DIR"

echo "Omarchy Chromium ARM64 installation complete"
