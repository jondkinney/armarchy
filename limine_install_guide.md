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

## Step 4: Create Custom Sync Script for ARM64

We'll create a custom script since the Java-based tools don't work with ARM64 Limine v9 syntax:

```bash
sudo tee /usr/local/bin/limine-snapshot-sync-arm <<EOF
#!/bin/bash

LIMINE_CONF="$EFI_DIR/limine.conf"
UUID=\$(blkid | grep 'TYPE="btrfs"' | grep -oP 'UUID="\K[^"]+' | head -1)

# Remove old snapshot entries (everything after the fallback entry)
sed -i '/^\/Snapshot/,\$d' "\$LIMINE_CONF"

# Add snapshot entries using simple parsing
snapper -c root list | tail -n +3 | while read -r line; do
    # Extract snapshot number (first field)
    num=\$(echo "\$line" | awk '{print \$1}')

    # Extract description (everything after the last │)
    desc=\$(echo "\$line" | sed 's/.*│ \([^│]*\) │\$/\1/' | xargs)

    if [[ \$num != "0" && -n \$num && \$num =~ ^[0-9]+\$ ]]; then
        # Clean description or use default
        [[ -z "\$desc" || "\$desc" == " " || "\$desc" == "-" ]] && desc="System snapshot"

        cat >> "\$LIMINE_CONF" <<ENTRY

/Snapshot \$num - \$desc
    protocol: linux
    path: boot():/Image
    module_path: boot():/initramfs-linux.img
    cmdline: root=UUID=\$UUID rw rootfstype=btrfs rootflags=subvol=root/.snapshots/\$num/snapshot
ENTRY
    fi
done

echo "Synchronized snapshots to Limine boot menu"
EOF

sudo chmod +x /usr/local/bin/limine-snapshot-sync-arm
```

## Step 5: Set Up Automatic Snapshot Sync Service for ARM64

Create a watcher service that monitors for snapshot changes and automatically syncs them to Limine:

```bash
# Create ARM64 watcher script that monitors snapshot directory
sudo tee /usr/local/bin/limine-snapshot-sync-arm-watcher <<'EOF'
#!/bin/bash

WATCH_DIR="/.snapshots"
SYNC_CMD="/usr/local/bin/limine-snapshot-sync-arm"

# Check if script is run with root privileges
if ((EUID != 0)); then
    echo -e "\033[91m limine-snapshot-sync-arm-watcher must be run with root privileges.\033[0m" >&2
    exit 1
fi

# Check if root filesystem is Btrfs
fstype=$(findmnt --mountpoint / -no FSTYPE)
if [[ "$fstype" != "btrfs" ]]; then
    echo -e "\033[91m Root filesystem is not Btrfs. Watcher stopped.\033[0m" >&2
    exit 0
fi

# Check if we're in a read-only snapshot
if [[ $(btrfs property get / ro 2>/dev/null) == *true ]]; then
    echo -e "\033[91m You are in a read-only Btrfs snapshot. Watcher stopped.\033[0m" >&2
    exit 0
fi

# Check if we're booted from a snapshot
cmdline=$(</proc/cmdline)
if [[ $cmdline =~ rootflags.*subvol=.*?/([0-9]+)/snapshot ]]; then
    echo -e "\033[91m You are booted from a snapshot. Watcher stopped.\033[0m" >&2
    exit 0
fi

# Initial sync if snapshots directory exists
if [[ -d "$WATCH_DIR" ]]; then
    echo "Running initial snapshot sync..."
    $SYNC_CMD
fi

# Monitor directory for creation/deletion events
echo "Monitoring $WATCH_DIR for snapshot changes..."
inotifywait -q -m -e create -e delete --format '%e|%f' "${WATCH_DIR}" | while IFS='|' read -r event snapID; do
    echo "[EVENT] $event -> $snapID"
    # Run sync in background to avoid blocking
    $SYNC_CMD &
done
EOF

sudo chmod +x /usr/local/bin/limine-snapshot-sync-arm-watcher

# Install inotify-tools for directory monitoring
sudo pacman -S --needed --noconfirm inotify-tools

# Create systemd service for automatic syncing
sudo tee /etc/systemd/system/limine-snapshot-sync-arm.service <<'EOF'
[Unit]
Description=Limine ARM64 Snapshot Sync Service
After=multi-user.target

[Service]
Type=simple
User=root
ExecStart=/usr/local/bin/limine-snapshot-sync-arm-watcher
Restart=on-failure
RestartSec=10s

# Security hardening
CapabilityBoundingSet=CAP_SYS_ADMIN
LockPersonality=yes
ProtectControlGroups=yes
ProtectClock=yes
ProtectHome=yes
ProtectHostname=yes
ProtectKernelLogs=yes
ProtectKernelModules=yes
ProtectKernelTunables=yes
ReadWritePaths=/tmp /boot/EFI/BOOT
RemoveIPC=yes
RestrictAddressFamilies=AF_UNIX AF_INET AF_INET6
RestrictNamespaces=yes
RestrictSUIDSGID=yes
NoNewPrivileges=yes
SystemCallArchitectures=native
SystemCallFilter=@system-service @mount

[Install]
WantedBy=multi-user.target
EOF

# Create override for any existing limine-snapper-sync service (if installed by Omarchy)
sudo mkdir -p /etc/systemd/system/limine-snapper-sync.service.d
sudo tee /etc/systemd/system/limine-snapper-sync.service.d/arm64-override.conf <<'EOF'
# Override to use ARM64 sync script instead of Java-based tool
[Service]
ExecStart=
ExecStart=/usr/local/bin/limine-snapshot-sync-arm-watcher
EOF

# Enable and start the service
sudo systemctl daemon-reload
sudo systemctl enable --now limine-snapshot-sync-arm.service

# Verify service is running
sudo systemctl status limine-snapshot-sync-arm.service --no-pager
```

## Step 6: Create Test Snapshots

Note: We'll test the sync script after Limine is installed

```bash
sudo snapper -c root create --description "Initial setup"
```

Show the last snapshot in the list

```
sudo snapper -c root list
```

## Step 7: Install Plymouth and Set Up mkinitcpio Hooks

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

## Step 8: Install and Configure Limine

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

#### Create Tokyo Night themed config with working ARM64 syntax

```bash
sudo tee "$EFI_DIR/limine.conf" <<EOF
# $EFI_DIR/limine.conf (Limine v9 syntax)
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
    path: boot():/Image
    module_path: boot():/initramfs-linux.img
    cmdline: root=UUID=YOUR_ROOT_UUID_HERE rw rootfstype=btrfs
EOF
```

#### Replace placeholder with actual UUID

```bash
ROOT_UUID=$(blkid | grep 'TYPE="btrfs"' | grep -oP 'UUID="\K[^"]+' | head -1)
if [[ -z "$ROOT_UUID" ]]; then
    echo "ERROR: Could not find Btrfs root UUID!"
    exit 1
fi
sudo sed -i "s/YOUR_ROOT_UUID_HERE/$ROOT_UUID/g" "$EFI_DIR/limine.conf"
```

Show your Root UUID

```bash
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

Preview the final `limine.conf`

```bash
cat "$EFI_DIR/limine.conf"
```

## Test Limine (One-Time Boot\*)

> \*Set Limine for the next boot only

```bash
LIMINE_NUM=$(sudo efibootmgr | grep "Limine" | cut -c5-8)
sudo efibootmgr --bootnext $LIMINE_NUM
```
