# Limine + Btrfs Snapshots on Parallels ARM64

## Prerequisites

- Fresh Arch Linux ARM64 on Parallels Desktop
- Btrfs filesystem with `/root` subvolume

#### Prepare EFI Directory

Ensure the EFI directory structure exists. Run the following:

```bash
ESP="/boot"
EFI_DIR="$ESP/EFI/BOOT"
sudo mkdir -p "$EFI_DIR"
```

## Step 1: Install Development Tools

#### Install base requirements

```bash
sudo pacman -S --needed base-devel git
```

#### Install yay AUR helper (skip if already installed)

```bash
if ! command -v yay &> /dev/null; then
    cd /tmp
    rm -rf yay 2>/dev/null || true
    git clone https://aur.archlinux.org/yay.git
    cd yay
    makepkg -si --noconfirm
else
    echo "yay is already installed, skipping..."
fi
```

## Step 2: Install Snapshot Tools

```bash
sudo pacman -S --needed --noconfirm snapper
```

#### Install `limine-mkinitcpio-hook` for the `btrfs-overlayfs` hook\*

> \*needed for snapshot booting

This handles yay's interactive prompts automatically

```bash
(echo "1"; echo "N"; echo "N"; echo "N") | yay -S --noconfirm limine-mkinitcpio-hook || {
    echo "Note: If limine-mkinitcpio-hook installation had issues, trying manual approach..."
    # Fallback: Install with minimal interaction
    yay -S --answerdiff None --answerclean None --removemake --noconfirm limine-mkinitcpio-hook
}
```

## Step 3: Configure Snapper

#### Create Snapper config (skip if already exists)

```bash
if ! sudo snapper -c root list &>/dev/null; then
    sudo snapper -c root create-config /
    echo "Snapper config created"
else
    echo "Snapper config for root already exists, skipping creation..."
fi
```

#### Configure settings (Omarchy defaults)

```bash
sudo sed -i 's/^TIMELINE_CREATE="yes"/TIMELINE_CREATE="no"/' /etc/snapper/configs/root
sudo sed -i 's/^NUMBER_LIMIT="50"/NUMBER_LIMIT="5"/' /etc/snapper/configs/root
sudo sed -i 's/^NUMBER_LIMIT_IMPORTANT="10"/NUMBER_LIMIT_IMPORTANT="5"/' /etc/snapper/configs/root
```

## Step 4: Install Automatic Snapshot System

Install the Omarchy scripts and services for automatic snapshot menu updates:

### Install Omarchy Scripts

```bash
# Create directory structure
OMARCHY_BIN="$HOME/.local/share/omarchy/bin"
mkdir -p "$OMARCHY_BIN"

# Copy scripts from Omarchy repository (adjust path as needed)
cp /path/to/omarchy/bin/omarchy-limine-update "$OMARCHY_BIN/"
cp /path/to/omarchy/bin/omarchy-limine-snapshot-hook "$OMARCHY_BIN/"
chmod +x "$OMARCHY_BIN/omarchy-limine-update"
chmod +x "$OMARCHY_BIN/omarchy-limine-snapshot-hook"
```

### Install Systemd Services

```bash
# Copy service files
sudo cp /path/to/omarchy/install/systemd/omarchy-limine-snapshot.service /etc/systemd/system/
sudo cp /path/to/omarchy/install/systemd/omarchy-limine-snapshot.path /etc/systemd/system/
sudo chmod 644 /etc/systemd/system/omarchy-limine-snapshot.*

# Enable automatic snapshot monitoring
sudo systemctl daemon-reload
sudo systemctl enable --now omarchy-limine-snapshot.path
sudo systemctl enable omarchy-limine-snapshot.service

# Verify services are running
sudo systemctl status omarchy-limine-snapshot.path --no-pager
```

## Step 5: Create Test Snapshots

```bash
sudo snapper -c root create --description "Initial setup"
```

Show the last snapshot in the list

```
sudo snapper -c root list
```

## Step 6: Install Plymouth and Set Up mkinitcpio Hooks

#### Install Plymouth for boot splash screen

```bash
sudo pacman -S --needed --noconfirm plymouth
```

#### Configure hooks with Plymouth and btrfs-overlayfs for snapshot booting

```bash
sudo tee /etc/mkinitcpio.conf.d/omarchy_hooks.conf <<'EOF'
HOOKS=(base udev plymouth keyboard autodetect modconf kms keymap consolefont block encrypt filesystems fsck btrfs-overlayfs)
EOF
```

#### Regenerate initramfs (answering 'n' to the prompt)

```bash

printf "n\n" | sudo mkinitcpio -P
```

## 🎯 PARALLELS SNAPSHOT POINT 🎯

**Create a Parallels snapshot here!** This allows you to easily test different Limine versions or revert if something goes wrong with the following bootloader installation.

## Step 7: Install and Configure Limine

This step combines downloading Limine, creating the configuration, and installing everything:

#### Download Limine 9.5.3 binary directly

```bash
cd /tmp
rm -rf limine 2>/dev/null || true
git clone --depth 1 --branch v9.5.3-binary https://github.com/limine-bootloader/limine.git
cd limine
```

#### Verify the EFI file exists (binary tags store EFI at repo root)

```bash
if [[ ! -f "BOOTAA64.EFI" ]]; then
    echo "ERROR: BOOTAA64.EFI not found in repository!"
    exit 1
fi
ls -la BOOTAA64.EFI
```

#### Generate initial Limine configuration

```bash
# Create a basic initial config that omarchy-limine-update will enhance
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
```

#### Create backup directory if it doesn't exist

```bash
BACKUP_DIR="${EFI_DIR}.bak"
if [[ ! -d "$BACKUP_DIR" ]]; then
    echo "Creating backup: $EFI_DIR → $BACKUP_DIR"
    sudo mkdir -p "$BACKUP_DIR"
    if compgen -G "$EFI_DIR/*" >/dev/null 2>&1; then
        sudo cp -a "$EFI_DIR/." "$BACKUP_DIR/"
    fi
fi
```

#### Install Limine bootloader

```bash
TMPDIR="/tmp/limine"
echo "Installing $TMPDIR/BOOTAA64.EFI → $EFI_DIR/BOOTAA64.EFI"
sudo install -m 0644 "$TMPDIR/BOOTAA64.EFI" "$EFI_DIR/BOOTAA64.EFI"
```

#### Create or find Limine boot entry

```bash
DISK="/dev/sda"
ESP_NUM="2"
LIMINE_LABEL="Limine"
ENTRY=$(sudo efibootmgr -v | awk '/^Boot[0-9A-Fa-f]{4}/ && (/Limine/ || /\\\\EFI\\\\BOOT\\\\BOOTAA64.EFI/){gsub("^Boot","",$1);gsub("\\*","",$1);print $1;exit}')
```

#### Create the new Limine boot entry

```bash
if [[ -z "$ENTRY" ]]; then
    echo "Creating new Limine boot entry..."
    sudo efibootmgr -c -d "$DISK" -p "$ESP_NUM" -L "$LIMINE_LABEL" -l '\EFI\BOOT\BOOTAA64.EFI'

    # Find the newly created entry
    ENTRY=$(sudo efibootmgr -v | awk '/^Boot[0-9A-Fa-f]{4}/ && (/Limine/ || /\\\\EFI\\\\BOOT\\\\BOOTAA64.EFI/){gsub("^Boot","",$1);gsub("\\*","",$1);print $1;exit}')
else
    echo "Found existing Limine boot entry: Boot$ENTRY"
fi
```

#### Set boot order (keeping GRUB as default for safety)

```bash
LIMINE_NUM=$(sudo efibootmgr | grep "Limine" | cut -c5-8)
sudo efibootmgr --bootorder 0005,${LIMINE_NUM},0002,0003,0000,0004
```

#### Verify installation

```bash
ls -la "$EFI_DIR/BOOTAA64.EFI" "$EFI_DIR/limine.conf"
```

#### Generate the hierarchical menu structure

```bash
# Run Omarchy's Limine update to create the hierarchical snapshot menu
sudo omarchy-limine-update

# Preview the final limine.conf with hierarchical menu
cat "$EFI_DIR/limine.conf"
```

## Test Automatic Snapshot Updates

Verify that the automatic system is working:

```bash
# Test automatic snapshot detection and menu updates
sudo snapper -c root create --description "Test automatic updates"

# Wait a moment for the service to trigger, then check the menu
sleep 2
cat "$EFI_DIR/limine.conf" | grep -A10 "//Snapshots"

# Monitor automatic updates in real-time (optional)
sudo journalctl -u omarchy-limine-snapshot.service -f
```

You should see:
- Latest snapshot appears at the top (newest first)
- Hierarchical structure: `/+Omarchy` → `//Snapshots` → `///Snapshot X`
- Automatic updates when new snapshots are created

## Test Limine (One-Time Boot\*)

> \*Set Limine for the next boot only

```bash
LIMINE_NUM=$(sudo efibootmgr | grep "Limine" | cut -c5-8)
sudo efibootmgr --bootnext $LIMINE_NUM
```
