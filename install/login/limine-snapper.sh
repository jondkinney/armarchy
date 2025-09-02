#!/bin/bash

# Note: limine-snapper-sync package is x86_64 only, but we have a custom
# implementation for ARM64 systems that provides the same hierarchical menu

if command -v limine &>/dev/null; then
  sudo tee /etc/mkinitcpio.conf.d/omarchy_hooks.conf <<EOF >/dev/null
HOOKS=(base udev plymouth keyboard autodetect microcode modconf kms keymap consolefont block encrypt filesystems fsck btrfs-overlayfs)
EOF

  # Check for EFI mode and determine config location
  if [[ -f /boot/EFI/BOOT/limine.conf ]]; then
    EFI=true
    limine_config="/boot/EFI/BOOT/limine.conf"
  elif [[ -f /boot/EFI/limine/limine.conf ]]; then
    EFI=true
    limine_config="/boot/EFI/limine/limine.conf"
  else
    limine_config="/boot/limine/limine.conf"
  fi

  # Try new syntax first, then old syntax
  CMDLINE=$(grep "^[[:space:]]*kernel_cmdline:" "$limine_config" | head -1 | sed 's/^[[:space:]]*kernel_cmdline:[[:space:]]*//' || \
           grep "^[[:space:]]*cmdline:" "$limine_config" | head -1 | sed 's/^[[:space:]]*cmdline:[[:space:]]*//')

  sudo tee /etc/default/limine <<EOF >/dev/null
TARGET_OS_NAME="Omarchy"

ESP_PATH="/boot"

KERNEL_CMDLINE[default]="$CMDLINE"
KERNEL_CMDLINE[default]+="quiet splash"

ENABLE_UKI=yes

ENABLE_LIMINE_FALLBACK=yes

# Find and add other bootloaders
FIND_BOOTLOADERS=yes

BOOT_ORDER="*, *fallback, Snapshots"

MAX_SNAPSHOT_ENTRIES=5

SNAPSHOT_FORMAT_CHOICE=5
EOF

  # UKI and EFI fallback are EFI only
  if [[ -z $EFI ]]; then
    sudo sed -i '/^ENABLE_UKI=/d; /^ENABLE_LIMINE_FALLBACK=/d' /etc/default/limine
  fi

  # We overwrite the correct config file (the one Limine actually reads)
  sudo tee "$limine_config" <<EOF >/dev/null
### Read more at config document: https://github.com/limine-bootloader/limine/blob/trunk/CONFIG.md
#timeout: 3
default_entry: 2
interface_branding: Omarchy Bootloader
interface_branding_color: 2
hash_mismatch_panic: no

term_background: 1a1b26
backdrop: 1a1b26

# Terminal colors (Tokyo Night palette)
term_palette: 15161e;f7768e;9ece6a;e0af68;7aa2f7;bb9af7;7dcfff;a9b1d6
term_palette_bright: 414868;f7768e;9ece6a;e0af68;7aa2f7;bb9af7;7dcfff;c0caf5

# Text colors
term_foreground: c0caf5
term_foreground_bright: c0caf5
term_background_bright: 24283b
 
EOF

  # Install limine-snapper-sync only on x86_64
  if [ -z "$OMARCHY_ARM" ]; then
    sudo pacman -S --noconfirm --needed limine-snapper-sync limine-mkinitcpio-hook
    sudo limine-update
  else
    # Use our custom implementation for ARM64
    sudo $OMARCHY_PATH/bin/omarchy-limine-update
  fi

  # Match Snapper configs if not installing from the ISO
  if [ -z "${OMARCHY_CHROOT_INSTALL:-}" ]; then
    if ! sudo snapper list-configs 2>/dev/null | grep -q "root"; then
      sudo snapper -c root create-config /
    fi

    # Only create home config if /home is a separate btrfs subvolume
    if sudo btrfs subvolume show /home &>/dev/null && ! sudo snapper list-configs 2>/dev/null | grep -q "home"; then
      sudo snapper -c home create-config /home
    fi
  fi

  # Tweak default Snapper configs - only modify configs that exist
  for config in root home; do
    if sudo snapper list-configs 2>/dev/null | grep -q "$config"; then
      sudo sed -i 's/^TIMELINE_CREATE="yes"/TIMELINE_CREATE="no"/' /etc/snapper/configs/$config
      sudo sed -i 's/^NUMBER_LIMIT="50"/NUMBER_LIMIT="5"/' /etc/snapper/configs/$config
      sudo sed -i 's/^NUMBER_LIMIT_IMPORTANT="10"/NUMBER_LIMIT_IMPORTANT="5"/' /etc/snapper/configs/$config
    fi
  done

  if [ -z "$OMARCHY_ARM" ]; then
    chrootable_systemctl_enable limine-snapper-sync.service
  else
    # Install our custom service for ARM64 (but don't enable yet - will be enabled after first boot)
    sudo cp $OMARCHY_PATH/install/systemd/omarchy-limine-snapshot.* /etc/systemd/system/
    echo "Limine snapshot service installed but not enabled - will be activated after first successful boot"
  fi
fi

# Add UKI entry to UEFI machines to skip bootloader showing on normal boot
if [ -n "$EFI" ] && efibootmgr &>/dev/null && ! efibootmgr | grep -q Omarchy &&
  ! cat /sys/class/dmi/id/bios_vendor 2>/dev/null | grep -qi "American Megatrends"; then
  sudo efibootmgr --create \
    --disk "$(findmnt -n -o SOURCE /boot | sed 's/p\?[0-9]*$//')" \
    --part "$(findmnt -n -o SOURCE /boot | grep -o 'p\?[0-9]*$' | sed 's/^p//')" \
    --label "Omarchy" \
    --loader "\\EFI\\Linux\\$(cat /etc/machine-id)_linux.efi"
fi
