#!/bin/bash

# Omarchy ARM64 Limine Installation
# Complete Limine 9.5.3 setup with kernel versioning for ARM64 systems

set -e

install_limine_arm64() {
    echo "🔧 Installing Limine 9.5.3 bootloader for ARM64..."

    # Install required packages for ARM64 Limine setup
    echo "📦 Installing required packages..."
    sudo pacman -S --needed --noconfirm base-devel git plymouth inotify-tools jq

    # Install limine-mkinitcpio-hook for btrfs-overlayfs support
    echo "🔧 Installing limine-mkinitcpio-hook..."
    (echo "1"; echo "N"; echo "N"; echo "N") | yay -S --noconfirm limine-mkinitcpio-hook || {
        echo "Note: Trying fallback installation method..."
        yay -S --answerdiff None --answerclean None --removemake --noconfirm limine-mkinitcpio-hook
    }

    # Configure mkinitcpio hooks for snapshot booting
    echo "⚙️  Configuring mkinitcpio hooks..."
    sudo tee /etc/mkinitcpio.conf.d/omarchy_hooks.conf <<'EOF'
HOOKS=(base udev plymouth keyboard autodetect modconf kms keymap consolefont block encrypt filesystems fsck btrfs-overlayfs)
EOF

    # Regenerate initramfs
    echo "🔄 Regenerating initramfs..."
    printf "n\n" | sudo mkinitcpio -P

    # Determine EFI configuration location
    if [[ -f /boot/EFI/BOOT/limine.conf ]]; then
        EFI_DIR="/boot/EFI/BOOT"
        LIMINE_CONFIG="$EFI_DIR/limine.conf"
        echo "Using existing EFI BOOT directory"
    elif [[ -f /boot/EFI/limine/limine.conf ]]; then
        EFI_DIR="/boot/EFI/limine"
        LIMINE_CONFIG="$EFI_DIR/limine.conf"
        echo "Using existing EFI limine directory"
    else
        # Default to BOOT directory for Parallels compatibility
        EFI_DIR="/boot/EFI/BOOT"
        LIMINE_CONFIG="$EFI_DIR/limine.conf"
        echo "Creating new EFI BOOT directory"
    fi

    # Create EFI directory structure
    sudo mkdir -p "$EFI_DIR"

    # Download Limine 9.5.3 binary (avoid broken newer versions)
    echo "📥 Downloading Limine 9.5.3 binary..."
    cd /tmp
    rm -rf limine-arm64 2>/dev/null || true
    git clone --depth 1 --branch v9.5.3-binary https://github.com/limine-bootloader/limine.git limine-arm64
    cd limine-arm64

    # Verify ARM64 EFI file exists
    if [[ ! -f "BOOTAA64.EFI" ]]; then
        echo "❌ ERROR: BOOTAA64.EFI not found in Limine 9.5.3 binary repository!"
        exit 1
    fi

    # Create backup if bootloader already exists
    if [[ -f "$EFI_DIR/BOOTAA64.EFI" ]]; then
        echo "📋 Backing up existing bootloader..."
        sudo cp "$EFI_DIR/BOOTAA64.EFI" "$EFI_DIR/BOOTAA64.EFI.backup.$(date +%s)"
    fi

    # Install Limine 9.5.3 bootloader
    echo "⚡ Installing Limine 9.5.3 BOOTAA64.EFI..."
    sudo install -m 0644 BOOTAA64.EFI "$EFI_DIR/BOOTAA64.EFI"

    # Get root filesystem UUID for configuration
    ROOT_UUID=$(blkid | grep 'TYPE="btrfs"' | grep -oP 'UUID="\K[^"]+' | head -1)
    if [[ -z "$ROOT_UUID" ]]; then
        echo "❌ ERROR: Could not find Btrfs root UUID!"
        exit 1
    fi

    # Create initial Limine configuration (will be enhanced by omarchy-limine-update)
    echo "📝 Creating initial Limine configuration..."
    sudo tee "$LIMINE_CONFIG" <<EOF
### Omarchy Limine Configuration with Kernel Versioning
### This will be enhanced automatically by omarchy-limine-update
timeout: 5
default_entry: 2
interface_branding: Omarchy Bootloader
interface_branding_color: 2
hash_mismatch_panic: no

# Tokyo Night theme
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
    kernel_cmdline: root=UUID=$ROOT_UUID rw rootfstype=btrfs quiet splash
EOF

    echo "🔑 Root UUID: $ROOT_UUID"

    # Create or update EFI boot entry
    echo "⚙️  Configuring EFI boot entry..."
    DISK="/dev/sda"
    ESP_NUM="2"
    LIMINE_LABEL="Limine"

    # Check if Limine boot entry already exists
    EXISTING_ENTRY=$(sudo efibootmgr -v | awk '/^Boot[0-9A-Fa-f]{4}/ && (/Limine/ || /\\\\EFI\\\\BOOT\\\\BOOTAA64.EFI/){gsub("^Boot","",$1);gsub("\\*","",$1);print $1;exit}' || true)

    if [[ -z "$EXISTING_ENTRY" ]]; then
        echo "➕ Creating new Limine boot entry..."
        sudo efibootmgr -c -d "$DISK" -p "$ESP_NUM" -L "$LIMINE_LABEL" -l '\EFI\BOOT\BOOTAA64.EFI'

        # Find the newly created entry
        NEW_ENTRY=$(sudo efibootmgr -v | awk '/^Boot[0-9A-Fa-f]{4}/ && (/Limine/ || /\\\\EFI\\\\BOOT\\\\BOOTAA64.EFI/){gsub("^Boot","",$1);gsub("\\*","",$1);print $1;exit}' || true)
        echo "✅ Created Limine boot entry: Boot$NEW_ENTRY"
    else
        echo "✅ Found existing Limine boot entry: Boot$EXISTING_ENTRY"
    fi

    # Set conservative boot order (keep GRUB as default initially)
    echo "📋 Setting up boot order (GRUB remains default for safety)..."
    LIMINE_NUM=$(sudo efibootmgr | grep "Limine" | cut -c5-8 || true)
    if [[ -n "$LIMINE_NUM" ]]; then
        # Keep GRUB first, Limine second for safety
        sudo efibootmgr --bootorder 0005,${LIMINE_NUM},0002,0003,0000,0004 2>/dev/null || true
        echo "✅ Boot order configured (GRUB default, Limine available)"
    fi

    # Verify installation
    if [[ -f "$EFI_DIR/BOOTAA64.EFI" && -f "$LIMINE_CONFIG" ]]; then
        echo "✅ Limine 9.5.3 installation completed successfully!"
        echo "   Bootloader: $EFI_DIR/BOOTAA64.EFI"
        echo "   Config: $LIMINE_CONFIG"
        return 0
    else
        echo "❌ Limine installation verification failed!"
        return 1
    fi
}

# Only run if called directly (not sourced)
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    install_limine_arm64
fi
