#!/bin/bash

# Install walker version 0.13.26 from AUR for ARM
# Note: yay doesn't respect version pinning with = syntax for AUR packages

echo "Installing walker 0.13.26 from source for ARM..."

# Remove any existing walker packages before installing specific version
echo "Removing any existing walker packages..."
sudo pacman -Rdd --noconfirm walker walker-bin 2>/dev/null || true
yay -Rdd --noconfirm walker walker-bin 2>/dev/null || true

# Install build dependencies
echo "Installing build dependencies..."
sudo pacman -S --needed --noconfirm go gtk4 gtk4-layer-shell gobject-introspection libvips

# Clone and build walker directly
echo "Cloning walker v0.13.26..."
cd /tmp
rm -rf walker
git clone https://github.com/abenz1267/walker
cd walker
git checkout v0.13.26

# Build walker
echo "Building walker (this may take a while)..."
cd cmd
go build -x -o walker

# Install
echo "Installing walker..."
sudo cp walker /usr/bin/

cd ~

echo "Walker 0.13.26 installed successfully"
