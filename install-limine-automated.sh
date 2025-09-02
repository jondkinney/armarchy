#!/bin/bash

# Limine + Btrfs Snapshots Automated Installation Script
# For Arch Linux ARM64 on Parallels Desktop

set -e  # Exit on any error

echo "==============================================="
echo "Limine + Btrfs Snapshots Automated Installer"
echo "==============================================="
echo ""
echo "This script will:"
echo "- Install development tools and yay AUR helper"
echo "- Install and configure Snapper for Btrfs snapshots"
echo "- Install Plymouth and configure boot hooks"
echo "- Download and install Limine 9.5.3 bootloader"
echo "- Configure Limine with hierarchical snapshot menu"
echo "- Set up automatic snapshot synchronization"
echo ""
echo "Prerequisites:"
echo "- Fresh Arch Linux ARM64 on Parallels"
echo "- Btrfs filesystem with /root subvolume"
echo ""
read -p "Press Enter to continue or Ctrl+C to cancel..."

echo ""
echo "=== Caching sudo password for script duration ==="
# Cache sudo password for the duration of the script
sudo -v

# Keep sudo alive in background (refresh every 30 seconds, more aggressive)
# Using -v to update timestamp instead of -n true which might fail
(while true; do sudo -v; sleep 30; kill -0 "$$" 2>/dev/null || exit; done) &
SUDO_REFRESH_PID=$!

# Function to clean up background sudo refresh on exit
cleanup() {
    kill $SUDO_REFRESH_PID 2>/dev/null || true
}
trap cleanup EXIT

echo ""
echo "=== Ensuring EFI Directory Exists ==="
# Ensure EFI directory exists
ESP="/boot"
EFI_DIR="$ESP/EFI/BOOT"
sudo mkdir -p "$EFI_DIR"


echo ""
echo "=== Step 1: Installing Development Tools ==="
sudo pacman -S --needed --noconfirm base-devel git


echo ""
echo "=== Installing yay AUR helper ==="
if ! command -v yay &> /dev/null; then
    cd /tmp
    rm -rf yay 2>/dev/null || true
    git clone https://aur.archlinux.org/yay.git
    cd yay
    makepkg -si --noconfirm
else
    echo "yay is already installed, skipping..."
fi


echo ""
echo "=== Step 2: Installing Snapshot Tools ==="
sudo pacman -S --needed --noconfirm snapper


echo ""
echo "=== Installing limine-mkinitcpio-hook (handling prompts automatically) ==="
# Use expect-like approach with yes and specific answers
# This handles yay's interactive prompts more reliably
(echo "1"; echo "N"; echo "N"; echo "N") | yay -S --noconfirm limine-mkinitcpio-hook || {
    echo "Note: If limine-mkinitcpio-hook installation had issues, trying manual approach..."
    # Fallback: Install with minimal interaction
    yay -S --answerdiff None --answerclean None --removemake --noconfirm limine-mkinitcpio-hook
}


echo ""
echo "=== Step 3: Configuring Snapper ==="
if ! sudo snapper -c root list &>/dev/null; then
    sudo snapper -c root create-config /
else
    echo "Snapper config for root already exists, skipping creation..."
fi
sudo sed -i 's/^TIMELINE_CREATE="yes"/TIMELINE_CREATE="no"/' /etc/snapper/configs/root
sudo sed -i 's/^NUMBER_LIMIT="50"/NUMBER_LIMIT="5"/' /etc/snapper/configs/root
sudo sed -i 's/^NUMBER_LIMIT_IMPORTANT="10"/NUMBER_LIMIT_IMPORTANT="5"/' /etc/snapper/configs/root


echo ""
echo "=== Step 4: Creating Test Snapshots ==="
sudo snapper -c root create --description "Initial setup"
sudo snapper -c root list


echo ""
echo "=== Step 5: Installing Plymouth and Configuring Hooks ==="
sudo pacman -S --needed --noconfirm plymouth

sudo tee /etc/mkinitcpio.conf.d/omarchy_hooks.conf <<'EOF'
HOOKS=(base udev plymouth keyboard autodetect modconf kms keymap consolefont block encrypt filesystems fsck btrfs-overlayfs)
EOF

echo ""
echo "=== Regenerating initramfs (answering 'n' to limine-mkinitcpio prompt) ==="
printf "n\n" | sudo mkinitcpio -P

echo ""
echo "🎯 PARALLELS SNAPSHOT RECOMMENDED 🎯"
echo "This is a good point to create a Parallels snapshot before installing the bootloader!"
echo ""
read -p "Press Enter to continue with Limine installation..."


echo ""
echo "=== Step 6: Downloading and Installing Limine 9.5.3 ==="
cd /tmp
rm -rf limine 2>/dev/null || true
git clone --depth 1 --branch v9.5.3-binary https://github.com/limine-bootloader/limine.git
cd limine

# Verify the EFI file exists
if [[ ! -f "BOOTAA64.EFI" ]]; then
    echo "ERROR: BOOTAA64.EFI not found in repository!"
    exit 1
fi

ls -la BOOTAA64.EFI


echo ""
echo "=== Creating Limine Configuration ==="

# Create basic initial config that omarchy-limine-update will enhance
ROOT_UUID=$(blkid | grep 'TYPE="btrfs"' | grep -oP 'UUID="\K[^"]+' | head -1)
if [[ -z "$ROOT_UUID" ]]; then
    echo "ERROR: Could not find Btrfs root UUID!"
    exit 1
fi

sudo tee "$EFI_DIR/limine.conf" <<EOF
# Basic Limine configuration (will be enhanced by omarchy-limine-update)
timeout: 12
interface_branding: Omarchy Bootloader
interface_branding_color: 2
hash_mismatch_panic: no

term_background: 1a1b26
backdrop: 1a1b26
term_palette: 15161e;f7768e;9ece6a;e0af68;7aa2f7;bb9af7;7dcfff;a9b1d6
term_palette_bright: 414868;f7768e;9ece6a;e0af68;7aa2f7;bb9af7;7dcfff;c0caf5
term_foreground: c0caf5
term_foreground_bright: c0caf5
term_background_bright: 24283b

/Arch Linux ARM (Parallels)
    protocol: linux
    kernel_path: boot():/Image
    module_path: boot():/initramfs-linux.img
    kernel_cmdline: root=UUID=$ROOT_UUID rw rootfstype=btrfs
EOF

echo "Using root UUID: $ROOT_UUID"


echo ""
echo "=== Installing Limine Bootloader ==="

# Create backup directory
BACKUP_DIR="${EFI_DIR}.bak"
if [[ ! -d "$BACKUP_DIR" ]]; then
    echo "Creating backup: $EFI_DIR → $BACKUP_DIR"
    sudo mkdir -p "$BACKUP_DIR"
    if compgen -G "$EFI_DIR/*" >/dev/null 2>&1; then
        sudo cp -a "$EFI_DIR/." "$BACKUP_DIR/"
    fi
fi

# Install Limine bootloader
TMPDIR="/tmp/limine"
echo "Installing $TMPDIR/BOOTAA64.EFI → $EFI_DIR/BOOTAA64.EFI"
sudo install -m 0644 "$TMPDIR/BOOTAA64.EFI" "$EFI_DIR/BOOTAA64.EFI"

echo ""
echo "=== Creating EFI Boot Entry ==="
DISK="/dev/sda"
ESP_NUM="2"
LIMINE_LABEL="Limine"

# Check if Limine boot entry already exists
ENTRY=$(sudo efibootmgr -v | awk '/^Boot[0-9A-Fa-f]{4}/ && (/Limine/ || /\\\\EFI\\\\BOOT\\\\BOOTAA64.EFI/){gsub("^Boot","",$1);gsub("\\*","",$1);print $1;exit}')

if [[ -z "$ENTRY" ]]; then
    echo "Creating new Limine boot entry..."
    sudo efibootmgr -c -d "$DISK" -p "$ESP_NUM" -L "$LIMINE_LABEL" -l '\EFI\BOOT\BOOTAA64.EFI'

    # Find the newly created entry
    ENTRY=$(sudo efibootmgr -v | awk '/^Boot[0-9A-Fa-f]{4}/ && (/Limine/ || /\\\\EFI\\\\BOOT\\\\BOOTAA64.EFI/){gsub("^Boot","",$1);gsub("\\*","",$1);print $1;exit}')
else
    echo "Found existing Limine boot entry: Boot$ENTRY"
fi

echo "Limine boot entry: Boot$ENTRY"

# Set boot order (keeping GRUB as default for safety)
LIMINE_NUM=$(sudo efibootmgr | grep "Limine" | cut -c5-8)
sudo efibootmgr --bootorder 0005,${LIMINE_NUM},0002,0003,0000,0004


echo ""
echo "=== Generating Hierarchical Snapshot Menu ==="
# Run Omarchy's Limine update to create the hierarchical snapshot menu
omarchy-limine-update

echo ""
echo "=== Verifying Installation ==="
ls -la "$EFI_DIR/BOOTAA64.EFI" "$EFI_DIR/limine.conf"
echo ""
echo "=== Final Limine Configuration with Hierarchical Menu ==="
cat "$EFI_DIR/limine.conf"


echo ""
echo "==============================================="
echo "✅ Installation Complete!"
echo "==============================================="
echo ""
echo "Setting Limine for next boot only (for testing):"
sudo efibootmgr --bootnext $LIMINE_NUM
echo ""
echo "Next steps:"
echo "1. Test Limine by rebooting:"
echo "   sudo reboot"
echo ""
echo "2. If testing is successful, make Limine permanent:"
echo "   sudo efibootmgr --bootorder $LIMINE_NUM,0005,0002,0003,0000,0004"
echo ""
echo "Features installed:"
echo "✅ Snapper for Btrfs snapshots"
echo "✅ Omarchy hierarchical snapshot menu system"
echo "✅ Automatic snapshot sync service (monitors /.snapshots)"
echo "✅ Plymouth boot splash"
echo "✅ Limine 9.5.3 bootloader with Tokyo Night theme"
echo "✅ Tree-like bootloader menu with snapshot organization"
echo ""
echo "Commands available:"
echo "- sudo snapper -c root create --description 'Description'"
echo "- sudo omarchy-limine-update (manual menu update)"
echo "- sudo systemctl status omarchy-limine-snapshot.service"
echo "- sudo journalctl -u omarchy-limine-snapshot.service -f"
echo "- sudo efibootmgr (to manage boot entries)"
