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
echo "- Download Omarchy scripts from ARM fork repository"
echo "- Install systemd services for automatic snapshot detection"
echo "- Download and install Limine 9.5.3 bootloader"
echo "- Configure Limine with hierarchical snapshot menu"
echo "- Set up automatic snapshot synchronization"
echo "- Create global symlinks for easy command access"
echo ""
echo "Prerequisites:"
echo "- Fresh Arch Linux ARM64 on Parallels"
echo "- Btrfs filesystem with /root subvolume"
echo "- Internet connection for downloading repositories"
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
echo "=== System Update ==="
echo "Updating package repositories and system packages..."
sudo pacman -Syu --noconfirm

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
echo "🎯🎯🎯 PARALLELS SNAPSHOT POINT 🎯🎯🎯"
echo ""
echo "*** HIGHLY RECOMMENDED: Create a Parallels snapshot now! ***"
echo ""
echo "This allows you to easily:"
echo "- Test different Limine versions"
echo "- Revert if bootloader installation fails"
echo "- Return to this working state if needed"
echo ""
echo "From Parallels: Actions → Take Snapshot..."
echo ""
read -p "Press Enter after taking snapshot to continue with Limine installation..."


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

echo ""
echo "=== Boot Order Configuration ==="
echo "Choose how you want to configure Limine bootloader:"
echo "1. Test mode - Boot Limine once for testing (keeps GRUB as default)"
echo "2. Default mode - Make Limine the permanent default bootloader"
echo ""

while true; do
    read -p "Enter your choice (1 for test, 2 for default): " BOOT_CHOICE
    case $BOOT_CHOICE in
        1)
            echo "Setting up Limine for testing (next boot only)..."
            LIMINE_NUM=$(sudo efibootmgr | grep "Limine" | cut -c5-8)
            sudo efibootmgr --bootnext $LIMINE_NUM
            BOOT_MODE="test"
            break
            ;;
        2)
            echo "Making Limine the permanent default bootloader..."
            LIMINE_NUM=$(sudo efibootmgr | grep "Limine" | cut -c5-8)
            sudo efibootmgr --bootorder ${LIMINE_NUM},0005,0002,0003,0000,0004
            BOOT_MODE="default"
            break
            ;;
        *)
            echo "Invalid choice. Please enter 1 or 2."
            ;;
    esac
done


echo ""
echo "=== Step 7: Installing Omarchy Snapshot Automation ==="
echo "Installing automatic snapshot detection and menu updates..."

# Create the bin directory structure
OMARCHY_BIN="$HOME/.local/share/omarchy/bin"
mkdir -p "$OMARCHY_BIN"

# Download Omarchy scripts from the ARM fork repository (vm-testing branch)
echo "Downloading Omarchy scripts from ARM fork repository..."
cd /tmp || { echo "ERROR: Failed to change to /tmp directory"; exit 1; }
rm -rf omarchy-tmp 2>/dev/null || true

if ! git clone --depth 1 --branch vm-testing https://github.com/jondkinney/armarchy.git omarchy-tmp; then
    echo "ERROR: Failed to clone Omarchy repository. Check internet connection."
    exit 1
fi

if [[ ! -f "omarchy-tmp/bin/omarchy-limine-update" ]] || [[ ! -f "omarchy-tmp/bin/omarchy-limine-snapshot-hook" ]]; then
    echo "ERROR: Required Omarchy scripts not found in repository"
    exit 1
fi

cp omarchy-tmp/bin/omarchy-limine-update "$OMARCHY_BIN/" &&
cp omarchy-tmp/bin/omarchy-limine-snapshot-hook "$OMARCHY_BIN/" &&
chmod +x "$OMARCHY_BIN/omarchy-limine-update" &&
chmod +x "$OMARCHY_BIN/omarchy-limine-snapshot-hook" ||
{ echo "ERROR: Failed to install Omarchy scripts"; exit 1; }

# Make scripts globally accessible
if ! sudo ln -sf "$OMARCHY_BIN/omarchy-limine-update" /usr/local/bin/; then
    echo "ERROR: Failed to create global symlink for omarchy-limine-update"
    exit 1
fi

if ! sudo ln -sf "$OMARCHY_BIN/omarchy-limine-snapshot-hook" /usr/local/bin/; then
    echo "ERROR: Failed to create global symlink for omarchy-limine-snapshot-hook"
    exit 1
fi

echo "✅ Omarchy scripts downloaded and installed to $OMARCHY_BIN"
echo "✅ Global symlinks created in /usr/local/bin/"

# Install systemd service files
echo "Installing systemd services..."
if [[ ! -f "/tmp/omarchy-tmp/install/systemd/omarchy-limine-snapshot.service" ]] || [[ ! -f "/tmp/omarchy-tmp/install/systemd/omarchy-limine-snapshot.path" ]]; then
    echo "ERROR: Required systemd service files not found in repository"
    exit 1
fi

sudo cp /tmp/omarchy-tmp/install/systemd/omarchy-limine-snapshot.service /etc/systemd/system/ &&
sudo cp /tmp/omarchy-tmp/install/systemd/omarchy-limine-snapshot.path /etc/systemd/system/ &&
sudo chmod 644 /etc/systemd/system/omarchy-limine-snapshot.* ||
{ echo "ERROR: Failed to install systemd service files"; exit 1; }

# Install inotify-tools for directory monitoring
echo "Installing inotify-tools..."
if ! sudo pacman -S --needed --noconfirm inotify-tools; then
    echo "ERROR: Failed to install inotify-tools"
    exit 1
fi

# Reload systemd and enable services
echo "Enabling and starting systemd services..."
sudo systemctl daemon-reload || { echo "ERROR: Failed to reload systemd"; exit 1; }
sudo systemctl enable --now omarchy-limine-snapshot.path || { echo "ERROR: Failed to enable omarchy-limine-snapshot.path"; exit 1; }
sudo systemctl enable omarchy-limine-snapshot.service || { echo "ERROR: Failed to enable omarchy-limine-snapshot.service"; exit 1; }

echo "✅ Automatic snapshot services installed and enabled"
echo "   Monitoring: /.snapshots for changes"

echo ""
echo "=== Generating Enhanced Limine Configuration ==="
if command -v omarchy-limine-update &> /dev/null; then
    sudo omarchy-limine-update
    echo "✅ Hierarchical snapshot menu generated"
else
    echo "⚠️  omarchy-limine-update not available - using basic configuration"
fi

echo ""
echo "=== Verifying Installation ==="
ls -la "$EFI_DIR/BOOTAA64.EFI" "$EFI_DIR/limine.conf"

# Verify systemd services are active
echo ""
echo "=== Verifying Services ==="
if systemctl is-active --quiet omarchy-limine-snapshot.path; then
    echo "✅ omarchy-limine-snapshot.path service is active"
else
    echo "⚠️  omarchy-limine-snapshot.path service is not active"
fi

if systemctl is-enabled --quiet omarchy-limine-snapshot.service; then
    echo "✅ omarchy-limine-snapshot.service is enabled"
else
    echo "⚠️  omarchy-limine-snapshot.service is not enabled"
fi

# Verify global commands are accessible
echo ""
echo "=== Verifying Global Commands ==="
if command -v omarchy-limine-update &> /dev/null; then
    echo "✅ omarchy-limine-update is globally accessible"
else
    echo "⚠️  omarchy-limine-update is not globally accessible"
fi

if command -v omarchy-limine-snapshot-hook &> /dev/null; then
    echo "✅ omarchy-limine-snapshot-hook is globally accessible"
else
    echo "⚠️  omarchy-limine-snapshot-hook is not globally accessible"
fi
echo ""
echo "=== Final Limine Configuration with Hierarchical Menu ==="
cat "$EFI_DIR/limine.conf"


echo ""
echo "==============================================="
echo "✅ Installation Complete!"
echo "==============================================="
echo ""
if [[ "$BOOT_MODE" == "test" ]]; then
    echo "🧪 TESTING MODE CONFIGURED:"
    echo "Limine is set for next boot only (testing mode)!"
    echo ""
    echo "Next steps:"
    echo "1. Reboot to test Limine:"
    echo "   sudo reboot"
    echo ""
    echo "   You should see:"
    echo "   - Limine bootloader with Tokyo Night theme"
    echo "   - 'Omarchy Bootloader' branding"
    echo "   - Hierarchical menu: /+Omarchy → //Snapshots"
    echo ""
    echo "2. If Limine boots successfully and you want to make it permanent:"
    echo "   LIMINE_NUM=\$(sudo efibootmgr | grep 'Limine' | cut -c5-8)"
    echo "   sudo efibootmgr --bootorder \$LIMINE_NUM,0005,0002,0003,0000,0004"
    echo ""
    echo "3. If Limine fails to boot properly:"
    echo "   - System will automatically boot back to GRUB on next restart"
    echo "   - Or reset VM from Parallels (hard reboot)"
else
    echo "🚀 READY TO BOOT:"
    echo "Limine is now configured as the default bootloader!"
    echo ""
    echo "Next steps:"
    echo "1. Reboot to use Limine:"
    echo "   sudo reboot"
    echo ""
    echo "   You will see:"
    echo "   - Limine bootloader with Tokyo Night theme"
    echo "   - 'Omarchy Bootloader' branding"
    echo "   - Hierarchical menu: /+Omarchy → //Snapshots"
    echo ""
    echo "2. If you need to boot back to GRUB temporarily:"
    echo "   - During boot, access UEFI/BIOS boot menu"
    echo "   - Select GRUB from the boot options"
    echo ""
    echo "3. To change boot order later if needed:"
    echo "   sudo efibootmgr --bootorder [entry_numbers]"
fi
echo ""
echo "Features installed:"
echo "✅ Snapper for Btrfs snapshots (limit: 5 snapshots)"
echo "✅ Limine 9.5.3 bootloader with Tokyo Night theme"
echo "✅ Hierarchical snapshot menu (/+Omarchy → //Snapshots → ///Snapshot X)"
echo "✅ Automatic snapshot detection and menu updates"
echo "✅ Plymouth boot splash screen"
echo "✅ Global command accessibility (omarchy-* commands in PATH)"
echo "✅ Systemd services for real-time snapshot monitoring"
echo "✅ inotify-tools for efficient directory watching"
echo "✅ Latest 5 snapshots shown (newest first)"
echo "✅ ARM fork repository integration (vm-testing branch)"
echo ""
echo "Automatic services running:"
echo "- omarchy-limine-snapshot.path (monitors /.snapshots for changes)"
echo "- omarchy-limine-snapshot.service (updates menu when triggered)"
echo ""
echo "Commands available:"
echo "- sudo snapper -c root create --description 'Description' (creates snapshot + auto-updates menu)"
echo "- sudo omarchy-limine-update (manual menu update)"
echo "- sudo systemctl status omarchy-limine-snapshot.service (check service status)"
echo "- sudo journalctl -u omarchy-limine-snapshot.service -f (monitor automatic updates)"
echo "- sudo efibootmgr (manage boot entries)"
echo ""
echo "Verify services are running:"
echo "  sudo systemctl status omarchy-limine-snapshot.path --no-pager"
echo ""
echo "Test automatic updates:"
echo "  sudo snapper -c root create --description 'Test auto-update'"
echo "  cat /boot/EFI/BOOT/limine.conf | grep -A10 '//Snapshots'"
