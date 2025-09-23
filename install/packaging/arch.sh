#!/bin/bash

# Architecture-specific package installation

# Check if running on ARM architecture
if [ -n "$OMARCHY_ARM" ]; then
  echo "Installing ARM-specific packages..."

  # Install any ARM-specific packages from the packages file using yay
  if [ -s "$OMARCHY_INSTALL/omarchy-arm.packages" ]; then
    mapfile -t packages < <(grep -v '^#' "$OMARCHY_INSTALL/omarchy-arm.packages" | grep -v '^$')
    if [ ${#packages[@]} -gt 0 ]; then
      yay -S --noconfirm --needed "${packages[@]}"
    fi
  fi

  # Run ARM-specific installation scripts
  echo "Running ARM-specific installation scripts..."
  source $OMARCHY_INSTALL/arm_install_scripts/walker-prebuilt.sh
  source $OMARCHY_INSTALL/arm_install_scripts/asdcontrol-prebuilt.sh
  source $OMARCHY_INSTALL/arm_install_scripts/obsidian-appimage.sh
  source $OMARCHY_INSTALL/arm_install_scripts/omarchy-chromium-arm64.sh
  source $OMARCHY_INSTALL/arm_install_scripts/omarchy-lazyvim.sh

  # Install Limine bootloader for ARM64 but not asahi-alarm (which uses U-Boot)
  if grep -qi "asahi" /etc/os-release 2>/dev/null ||
    uname -r | grep -qi "asahi" ||
    pacman -Q linux-asahi &>/dev/null ||
    pacman -Q asahi-scripts &>/dev/null; then

    echo "Skipping Limine installation on Asahi systems (uses U-Boot)"
  else
    source $OMARCHY_INSTALL/arm_install_scripts/limine-install-arm64.sh
    install_limine_arm64
  fi

  # Post-install tasks for ARM packages
  # Update icon cache for yaru-icon-theme (needed on ARM)
  if [ -d "/usr/share/icons/Yaru" ]; then
    echo "Updating Yaru icon cache for ARM..."
    sudo gtk-update-icon-cache /usr/share/icons/Yaru
  fi
else
  echo "Installing x86_64-specific packages..."

  # Install x86-specific packages using pacman with omarchy mirror
  mapfile -t packages < <(grep -v '^#' "$OMARCHY_INSTALL/omarchy-x86.packages" | grep -v '^$')
  if [ ${#packages[@]} -gt 0 ]; then
    sudo pacman -S --noconfirm --needed "${packages[@]}"
  fi
fi
