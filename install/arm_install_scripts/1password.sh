#!/bin/bash

# Install 1Password from AUR for ARM
echo "Installing 1Password from AUR for ARM..."

# Check if 1Password is already installed
if command -v 1password &>/dev/null; then
  echo "1Password already installed, skipping"
  return 0
fi

# Get the 1Password signing key
echo "Importing 1Password GPG signing key..."
curl -sS https://downloads.1password.com/linux/keys/1password.asc | gpg --import

# Verify the key fingerprint (3FEF9748469ADBE15DA7CA80AC2D62742012EA22)
echo "Verifying GPG key fingerprint..."
if ! gpg --list-keys --fingerprint | grep -q "3FEF 9748 469A DBE1 5DA7  CA80 AC2D 6274 2012 EA22"; then
  echo "Warning: 1Password GPG key fingerprint does not match expected value"
  echo "Expected: 3FEF 9748 469A DBE1 5DA7  CA80 AC2D 6274 2012 EA22"
  echo "Please verify the key manually before proceeding"
fi

# Clone the 1Password AUR package
echo "Cloning 1Password AUR package..."
cd /tmp
rm -rf 1password
git clone https://aur.archlinux.org/1password.git

# Install 1Password
echo "Building and installing 1Password (this may take a while)..."
cd 1password
makepkg -si --noconfirm

cd ~

echo "1Password installed successfully"

