# Install Omarchy on an m4 macbook pro with Parallels

Download archboot from here https://release.archboot.com/aarch64/latest/iso/

The archboot download page showing available ISO options:
![[CleanShot 2025-08-30 at 18.25.18@2x.png]]
I chose the largest one, which is an offline "local" installer.

> **Network Requirements**: Local ISOs work offline (largest), standard ISOs need internet (medium), netboot (smallest) requires _wired_ ethernet.

## Create a new VM choosing "Install from an image file"

![[CleanShot 2025-08-30 at 18.33.29@2x.png]]

## Choose your iso manually

![[CleanShot 2025-08-30 at 18.35.16@2x.png]]

Click "select a file..."
![[CleanShot 2025-08-30 at 18.37.59@2x.png]]

Browse and select the downloaded archboot ISO file
![[CleanShot 2025-08-30 at 18.38.27@2x.png]]

A warning will pop up stating "Unable to detect operating system". That's fine, click "Continue".
![[CleanShot 2025-08-30 at 18.36.03@2x.png]]

Choose "Other" from the operating system list
![[CleanShot 2025-08-30 at 18.39.05@2x 1.png]]

Name your VM, choose a location, then check "Customize settings before installation":
![[CleanShot X 2025-08-30 18.40.59.png]]

The Configuration window will appear with VM settings
![[CleanShot 2025-08-30 at 18.41.21@2x.png]]

Customize the Hardware preferences (CPU and Memory)
![[CleanShot 2025-08-30 at 18.45.21@2x.png]]

Graphics settings configuration:
![[CleanShot 2025-08-30 at 19.34.08@2x.png]]

The hard drive will only allow us to install the default 64gb capacity, but we'll grow that after we boot to the new OS
![[CleanShot 2025-08-30 at 19.40.11@2x.png]]

## Ensure CD/DVD is chosen for boot order, initially

![[CleanShot 2025-08-30 at 19.31.36@2x.png]]

I didn't enable disk encryption
![[CleanShot 2025-08-30 at 19.32.18@2x.png]]

Up to you, but I'm leaving SmartGuard off. I plan to manually take snapshots and use the built-in limine bootloader snapshot capabilities, just like "real" hardware!
![[CleanShot 2025-08-30 at 19.33.15@2x.png]]

## Since you've selected the ISO, start the machine and it'll boot to this screen

![[CleanShot 2025-08-30 at 21.12.40@2x.png]]

## Then it'll boot to the Aarch64 ISO

![[CleanShot 2025-08-30 at 21.11.53@2x.png]]

## Choose "ENTER" and set it up with your locale.

![[CleanShot 2025-08-30 at 21.34.15@2x.png]]

## Then choose "No" when prompted to use Online Mode since the mirrors are experiencing DDoS attacks as of August 2025.

![[CleanShot 2025-08-30 at 21.13.52@2x.png]]

Configure your timezone region
![[CleanShot 2025-08-30 at 21.14.31@2x.png]]

Choose the nearest city in your timezone
![[CleanShot 2025-08-30 at 21.14.54@2x.png]]

Confirm the date
![[CleanShot 2025-08-30 at 21.39.25@2x.png]]

Confirm the time
![[CleanShot 2025-08-30 at 21.39.33@2x.png]]

Launch Archboot Setup
![[CleanShot 2025-08-30 at 21.15.41@2x.png]]

Prepare Storage Device
![[CleanShot 2025-08-30 at 21.47.48@2x.png]]

Choose "Quick Setup (erases the ENTIRE storage device)"
![[CleanShot 2025-08-30 at 21.52.49@2x.png]]

Choose your storage device (there is only one option)
![[CleanShot 2025-08-30 at 21.52.55@2x.png]]

Select the PARTUUID Device Name Scheme since we have a GPT disk
![[CleanShot 2025-08-30 at 21.53.01@2x.png]]

Choose SINGLEBOOT for the EFI System Partition (ESP)
![[CleanShot 2025-08-30 at 21.53.10@2x.png]]

Accept the default of 512mb for the EFI System Partition size
![[CleanShot 2025-08-30 at 21.59.11@2x.png]]

Choose the default of 256mb for the Swap partition
![[CleanShot 2025-08-30 at 21.59.21@2x.png]]

Choose btrfs for the Filesystem type
![[CleanShot 2025-08-30 at 21.59.30@2x.png]]

Confirm Filesystem will be used for / and /home
![[CleanShot 2025-08-30 at 21.59.38@2x.png]]

Set the /home volume to 0 to nest the /home directory within the root btrfs partition
![[CleanShot 2025-08-30 at 22.00.06@2x.png]]

Confirm the full size will be used for the root partition
![[CleanShot 2025-08-30 at 22.00.45@2x.png]]

Confirm the volume /dev/sda will be COMPLETELY ERASED!
![[CleanShot 2025-08-30 at 22.00.53@2x.png]]

Filesystem created successfully
![[CleanShot 2025-08-30 at 22.00.59@2x.png]]

Quick Setup was successful
![[CleanShot 2025-08-30 at 22.13.46@2x.png]]

## Step 2 - Install Packages

Select "Install Packages" from the main menu
![[CleanShot 2025-08-30 at 22.04.14@2x.png]]

Package installation menu:
![[CleanShot 2025-08-30 at 22.04.30@2x.png]]

Package installation in progress:
![[CleanShot 2025-08-30 at 22.14.14@2x.png]]

Package selection complete:
![[CleanShot 2025-08-30 at 22.14.31@2x.png]]

Let it complete, then choose "Configure System"
![[CleanShot 2025-08-30 at 22.06.09@2x.png]]

Set a new root password
![[CleanShot 2025-08-30 at 22.06.15@2x.png]]

Confirm root password
![[CleanShot 2025-08-30 at 22.15.21@2x.png]]

Don't be a baby... neovim for the win!
![[CleanShot 2025-08-30 at 22.06.27@2x.png]]

Package installation complete
![[CleanShot 2025-08-30 at 22.15.34@2x.png]]

## MKINITCPIO Setup

MKINITCPIO configuration menu
![[CleanShot 2025-08-30 at 22.06.59@2x.png]]

MKINITCPIO generation in progress
![[CleanShot 2025-08-30 at 22.15.49@2x.png]]

When that completes you'll see this

MKINITCPIO complete, back to configuration menu

Enter User Management
![[CleanShot 2025-08-30 at 22.07.29@2x.png]]

Choose "Set the default shell"
![[CleanShot 2025-08-30 at 22.07.55@2x.png]]

Choose BASH (the Omarchy default). I highly recommend against changing to zsh or fish until you have everything fully configured how you want it. Even then all the update scripts, etc. run through Bash, so even though I'm a long time zsh user, I'm personally just going to stick with Bash and adapt my tooling accordingly. The only thing I really miss is better auto completion, but there are packages for that.
![[CleanShot 2025-08-30 at 22.08.16@2x.png]]

Shell configuration complete
![[CleanShot 2025-08-30 at 22.16.09@2x.png]]

## Create a user account

User account creation menu:
![[CleanShot 2025-08-30 at 22.08.38@2x.png]]

Enter username
![[CleanShot 2025-08-30 at 22.08.49@2x.png]]

Enable `user` as Administrator and part of the wheel group
![[CleanShot 2025-08-30 at 22.08.56@2x.png]]

Enter full name
![[CleanShot 2025-08-30 at 22.09.07@2x.png]]

Set user password
![[CleanShot 2025-08-30 at 22.09.13@2x.png]]

Confirm user password
![[CleanShot 2025-08-30 at 22.09.18@2x.png]]

New password set successfully
![[CleanShot 2025-08-30 at 22.09.24@2x.png]]

User account created successfully
![[CleanShot 2025-08-30 at 22.17.10@2x.png]]

Return to main configuration menu
![[CleanShot 2025-08-30 at 22.09.38@2x.png]]

## Return to main menu

![[CleanShot 2025-08-30 at 22.23.30@2x.png]]

## Install Bootloader

Bootloader installation menu
![[CleanShot 2025-08-30 at 22.30.44@2x.png]]

## Install the GRUB_EUFI Bootloader

![[CleanShot 2025-08-30 at 22.31.55@2x.png]]

GRUB installation complete
![[CleanShot 2025-08-30 at 22.32.27@2x.png]]

Proceed to open GRUB(2) configuration file in neovim
![[CleanShot 2025-08-30 at 22.32.35@2x.png]]

## Review GRUB_EUFI Configuration file

![[CleanShot 2025-08-30 at 22.32.46@2x.png]]

Just save and quit again `:wq`

![[CleanShot 2025-08-30 at 22.33.18@2x.png]]

GRUB configuration saved
![[CleanShot 2025-08-30 at 22.33.33@2x.png]]

Bootloader installation complete
![[CleanShot 2025-08-30 at 22.33.36@2x.png]]

Final installation summary
![[CleanShot 2025-08-30 at 22.33.57@2x.png]]

## Reboot to your new aarch64 install!

![[CleanShot 2025-08-30 at 22.34.12@2x.png]]

## Remove the ISO from the cd/dvd drive before reboot!

![[CleanShot 2025-08-31 at 00.06.32@2x.png]]

## Disconnect the ISO in 10s before the reboot happens!

![[CleanShot 2025-08-31 at 00.09.18@2x.png]]

Then you'll boot to the GRUB menu. Choose:

\*Arch Linux

...and boot your new system!
![[CleanShot 2025-08-30 at 22.36.16@2x.png]]

Arch Linux login prompt
![[CleanShot 2025-08-30 at 22.37.06@2x.png]]
For me it's "jon" and my password and I'm logged in

## Congrats! You now have aarch64 installed to a VM!

![[CleanShot 2025-08-30 at 22.37.29@2x.png]]

## Shutdown the machine so we can resize the hard drive before installing Omarchy

![[CleanShot 2025-08-30 at 22.38.06@2x.png]]

Again, not sure why, but it seems like a bug that you have to fully install `aarch64` before you can resize the Parallels Hard Drive. Typically you'd be able to do that when setting it up, which would save us some steps, but it's not that big of a deal. Let's increase the Parallels disk size now that `aarch64` is installed.

## Open Parallels Control Center and right click your VM

![[CleanShot 2025-08-30 at 22.39.49@2x.png]]

## Choose "Configure..."

![[CleanShot 2025-08-30 at 22.40.30@2x.png]]

## Set the Hard Drive size to be 128gb or larger (I chose 256gb) and click "Apply"

![[CleanShot 2025-08-30 at 22.41.36@2x.png]]

## Choose "Continue"

![[CleanShot 2025-08-30 at 22.42.06@2x.png]]

I chose 256gb for my root volume
![[CleanShot 2025-08-30 at 22.43.48@2x.png]]

Enable TRIM
![[Untitled 3.png]]

The warning says we're not on an SSD, but we are. I _think_ this is fine, but more research is needed. It's possible that if the machine doesn't _think_ it's on an SSD, even though it is, this could impact performance. Please let me know in the comments.

Confirm we want to enable TRIM
![[CleanShot 2025-08-30 at 22.46.15@2x.png]]

Press OK
![[CleanShot 2025-08-30 at 22.47.14@2x.png]]

Now you have a Parallels VM with Aarch64 and a 256GB Hard drive which is big enough for Omarchy to be installed on.

Go back to the Control Center and double click your new VM to launch it!

Parallels Control Center - ready to launch VM
![[CleanShot 2025-08-30 at 22.48.29@2x.png]]

Press Play!
![[CleanShot 2025-08-30 at 22.48.49@2x.png]]

At the GRUB bootloader, choose: `*Arch Linux`
![[CleanShot 2025-08-30 at 22.49.03@2x.png]]

Now you're back to the login, so login with the root user and the password you set for the root user so that we can install the `sudo` package to allow elevating our normal user with root permissions.

![[CleanShot 2025-08-30 at 23.00.26@2x.png]]

Install `sudo` and `openssh`

```bash
pacman -Syu sudo openssh
```

![[CleanShot 2025-08-30 at 23.20.38@2x.png]]

Confirm package installation
![[CleanShot 2025-08-30 at 23.21.19@2x.png]]

Package installation complete
![[CleanShot 2025-08-30 at 23.22.23@2x.png]]

## Instal `vi` so we can check the sudoers files

```
pacman -Syu vi
```

![[CleanShot 2025-08-30 at 23.23.53@2x.png]]

Now run `visudo` and update the sudoers configuration to look like this enabling all commands for users of the `wheel` group, which we previously setup for our user.

![[CleanShot 2025-08-30 at 23.24.52@2x.png]]

Save and quit the visudo file with `:wq`

## Set up SSH

Enable and start the SSH service

```
systemctl enable sshd
systemctl start sshd
```

![[CleanShot 2025-08-30 at 23.28.28@2x.png]]

### Check SSH is running

```
systemctl status sshd
```

![[CleanShot 2025-08-30 at 23.28.54@2x.png]]

## Find your VM's IP address

```
ip addr show
```

![[CleanShot 2025-08-30 at 23.29.31@2x.png]]

Now we can connect from our host machine over SSH in something like Ghostty or iTerm2 or Alacrity, etc. to more easily copy and paste commands!

![[CleanShot 2025-08-30 at 23.31.01@2x.png]]

Ensure that we have full compatibility by adding `export TERM=xterm-256color` to the bottom of the `~/.bashrc` file like so:

```
export TERM=xterm-256color
```

![[CleanShot 2025-08-30 at 23.35.24@2x.png]]

Write and quit with `:wq` then close the connection by typing `exit` and then re-connect and you should have the ability to type `clear` amongst other things. We're fully compatible now!

## Grow the root partition to the new 256gb size

Check the partition names with `lsblk` and `sudo fdisk -l`

Current partition layout before resize
![[CleanShot 2025-08-31 at 00.19.12@2x.png]]

## Install the `parted` disk utility

![[CleanShot 2025-08-31 at 00.21.12@2x.png]]

## Grow the partition with `parted`

```
sudo parted /dev/sda resizepart 4 100%
```

![[CleanShot 2025-08-31 at 00.21.43@2x.png]]

We can ignore the details in the "Information:" response

![[CleanShot 2025-08-31 at 00.22.15@2x.png]]

Our root partition is now 256gb. Huzzah!

![[CleanShot 2025-08-31 at 00.22.58@2x.png]]

## Finally, resize the Btrfs filesystem to use the expanded partition

After growing the partition, we need to tell the Btrfs filesystem to use the newly available space

```bash
sudo btrfs filesystem resize max /
```

This command resizes the Btrfs filesystem on the root mount point (/) to use the maximum available space on the partition.

Notice how `/dev/sda4` increases in size after this command.
![[CleanShot 2025-09-02 at 14.09.54@2x.png]]

At this point I'd recommend taking a snapshot of the system so that if any of the following steps fail, we can easily restore to this point in time.

## Take a snapshot

Shutdown the VM

```
shutdown now
```

![[CleanShot 2025-08-31 at 00.24.34@2x.png]]

When you open Parallels back up, before booting, choose "Take Snapshot..." from the "Actions" menu.

![[CleanShot 2025-08-31 at 00.25.25@2x.png]]

Name and describe your snapshot, save it, and reboot the system. From this safe point, we'll configure the default bootloader that Omarchy's ISO uses so we can take advantage of automatic snapshots the same way an ISO installed to real hardware would.

# Reconnect to continue

Reconnect to your VM over SSH (use your username and IP address)

```bash
ssh jon@10.211.55.9
```

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

> \*needed for snapshot booting - provides overlayfs support specifically for Limine

This handles yay's interactive prompts automatically and will install a newer limine version as a dependency, which we'll override later with our manually installed Limine 9.5.3 to avoid a bug in newer versions that prevent limine from properly reading our config file.

```bash
(echo "1"; echo "N"; echo "N"; echo "N") | yay -S --noconfirm limine-mkinitcpio-hook || {
    echo "Note: If limine-mkinitcpio-hook installation had issues, trying manual approach..."
    # Fallback: Install with minimal interaction
    yay -S --answerdiff None --answerclean None --removemake --noconfirm limine-mkinitcpio-hook
}
```

Note: if you get any errors here like 404, run:

```bash
sudo pacman -Syu
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
sudo sed -i 's/^TIMELINE_CREATE="yes"/TIMELINE_CREATE="no"/' /etc/snapper/configs/root &&
sudo sed -i 's/^NUMBER_LIMIT="50"/NUMBER_LIMIT="5"/' /etc/snapper/configs/root &&
sudo sed -i 's/^NUMBER_LIMIT_IMPORTANT="10"/NUMBER_LIMIT_IMPORTANT="5"/' /etc/snapper/configs/root
```

## Step 4: Install Automatic Snapshot System

### Install Omarchy Scripts

```bash
# Create directory structure
OMARCHY_BIN="$HOME/.local/share/omarchy/bin" &&
mkdir -p "$OMARCHY_BIN"

# Download Omarchy scripts from the ARM fork repository (vm-testing branch)
cd /tmp &&
rm -rf omarchy-tmp 2>/dev/null || true &&
git clone --depth 1 --branch vm-testing https://github.com/jondkinney/armarchy.git omarchy-tmp &&
cp omarchy-tmp/bin/omarchy-limine-update "$OMARCHY_BIN/" &&
cp omarchy-tmp/bin/omarchy-limine-snapshot-hook "$OMARCHY_BIN/" &&
chmod +x "$OMARCHY_BIN/omarchy-limine-update" &&
chmod +x "$OMARCHY_BIN/omarchy-limine-snapshot-hook" &&

# Make scripts globally accessible
sudo ln -sf "$OMARCHY_BIN/omarchy-limine-update" /usr/local/bin/ &&
sudo ln -sf "$OMARCHY_BIN/omarchy-limine-snapshot-hook" /usr/local/bin/ &&
echo -e '\nSuccess: omarchy-limine-update and omarchy-limine-snapshot-hook installed!\n'
```

### Install Systemd Services

sudo systemctl status omarchy-limine-snapshot.path --no-pager

```bash
sudo cp /tmp/omarchy-tmp/install/systemd/omarchy-limine-snapshot.service /etc/systemd/system/ &&
sudo cp /tmp/omarchy-tmp/install/systemd/omarchy-limine-snapshot.path /etc/systemd/system/ &&
sudo chmod 644 /etc/systemd/system/omarchy-limine-snapshot.*
```

Install inotify-tools for directory monitoring

```bash
sudo pacman -S --needed --noconfirm inotify-tools
```

Enable automatic snapshot monitoring

```bash
sudo systemctl daemon-reload &&
sudo systemctl enable --now omarchy-limine-snapshot.path &&
sudo systemctl enable omarchy-limine-snapshot.service
```

Verify services are running

```bash
sudo systemctl status omarchy-limine-snapshot.path --no-pager
```

## Step 5: Create Test Snapshots

Note: We'll test the sync script after Limine is installed

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

This step combines downloading Limine, creating the configuration, and installing everything

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

# Override the older limine version installed by limine-mkinitcpio-hook
# Our Limine 9.5.3 BOOTAA64.EFI is now the active bootloader
echo "✅ Limine 9.5.3 BOOTAA64.EFI installed, overriding older version from limine-mkinitcpio-hook"
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

Run Omarchy's Limine update to create the hierarchical snapshot menu

```bash
sudo omarchy-limine-update
```

Preview the final limine.conf with hierarchical menu

```bash
cat "$EFI_DIR/limine.conf"
```

## Test Automatic Snapshot Updates

Verify that the automatic system is working

Test automatic snapshot detection and menu updates

```bash
sudo snapper -c root create --description "Test automatic updates"
```

Wait a moment for the service to trigger, then check the menu

```bash
cat "$EFI_DIR/limine.conf" | grep -A10 "//Snapshots"
```

Monitor automatic updates in real-time (optional)

```bash
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

Reboot

```bash
sudo reboot
```

Your SSH session will disconnect. Open Parallels and you should see:

- Limine bootloader with Tokyo Night theme
- "Omarchy Bootloader" branding
- Arch Linux ARM entries
- Snapshot entries: "Initial Setup"

If Limine doesn't boot properly you can "reset" the VM and the system will automatically boot back to GRUB.

Limine bootloader with hierarchical snapshot menu
![[CleanShot 2025-09-01 at 14.45.13@2x.png]]

## Make `Limine` Permanent (After Testing)

Once you've verified Limine works correctly set it as the default bootloader

```bash
LIMINE_NUM=$(sudo efibootmgr | grep "Limine" | cut -c5-8) &&
sudo efibootmgr --bootorder ${LIMINE_NUM},0005,0002,0003,0000,0004
```

Verify `Limine (0001)` is now first in the BootOrder

You should see something similar to this:

```bash
BootCurrent: 0001
Timeout: 0 seconds
BootOrder: 0001,0005,0002,0003,0000,0004
Boot0000* UiApp FvVol(45801e53-5502-4463...
Boot0001* Limine        HD(2,GPT,d810e6b...
Boot0002* UEFI Aarch64-0 SSD ESNER7SSCGS...
Boot0003* No OS found   FvVol(45801e53-5...
Boot0004* UEFI Shell    FvVol(45801e53-5...
Boot0005* GRUB  HD(2,GPT,d810e6b2-9c8b-4...
```

## Automatic Update Snapshots

When using `omarchy-update` or `pacman -Syu`, snapshots will be created automatically and synced to the boot menu via the `omarchy-limine-snapshot-hook` service. The hierarchical menu structure (`/+Omarchy` → `//Snapshots` → `///Snapshot X`) will be maintained automatically.

## Manual Snapshot Creation (optional)

> Note: Snapshots automatically appear in boot menu via the sync service we created earlier

```bash
sudo snapper -c root create --description "Description here"
```

Check that the new snapshot was automatically added to `/boot/EFI/BOOT/limine.conf`

```bash
cat /boot/EFI/BOOT/limine.conf
```

Look for the description of the manual snapshot you created just above.

## Troubleshooting

Skip this section if your VM booted to Limine properly.

If Limine shows a black screen with an error:

> No volume contained a Limine configuration file

Check that both files exist in the same directory

```bash
ls -la /boot/EFI/BOOT/BOOTAA64.EFI /boot/EFI/BOOT/limine.conf
```

Both should be present in `/boot/EFI/BOOT/`

If `BOOTAA64.EFI` is missing run:

```bash
sudo mkdir -p /boot/EFI/BOOT &&
cd /tmp/limine &&
sudo install -m 0644 BOOTAA64.EFI /boot/EFI/BOOT/BOOTAA64.EFI
```

If `limine.conf` is missing, recreate it

> Note: the config must be in the same directory as `BOOTAA64.EFI`

```bash
sudo cp /boot/EFI/BOOT/limine.conf.bak /boot/EFI/BOOT/limine.conf
```

Verify the boot entry points to the correct path

```bash
sudo efibootmgr -v | grep Limine
```

It should show: `\EFI\BOOT\BOOTAA64.EFI`

# Configuring the `asahi-alarm` ARM mirror

> Before we can install Omarchy, we need to setup the asahi-alarm mirror, since a few package some from there on install.

⚠️⚠️⚠️ ONLY DO THIS ON M-SERIES (m1/m2) MACS RUNNING `asahi-alarm` ⚠️⚠️⚠️

## Setup the asahi-alarm mirror

Edit the `/etc/pacman.conf` file and add the \[asahi-alarm\] entry before any others.

```
sudo nvim /etc/pacman.conf
```

Add the `asahi-alarm` mirror as the first entry

```bash
[asahi-alarm]
Include = /etc/pacman.d/mirrorlist.asahi-alarm
```

Enter "insert mode" by pressing `i` (i for insert) then type in the mirror like so by hand. Press Escape when you're done typing.

![[CleanShot 2025-08-30 at 23.39.19@2x 1.png]]

Now save and quit with `:wq`

![[CleanShot 2025-08-30 at 22.20.10@2x.png]]

Before we install any packages, we need to add the `asahi-alarm` mirrorlist file with the following command:

```bash
sudo nvim /etc/pacman.d/mirrorlist.asahi-alarm
```

Then add the following in that file:

```
Server = https://github.com/asahi-alarm/asahi-alarm/releases/download/$arch
```

![[CleanShot 2025-08-30 at 23.10.55@2x.png]]

Now update the local package mirror databases

```
sudo pacman -Syu
```

![[CleanShot 2025-08-30 at 23.44.49@2x.png]]

Install widevine?

# Actually Installing Omarchy

We made it! Definitely take a snapshot in both Arch and Parallels at this point so that you have a fresh pre-Omarchy install attempt point to revert to.

## Install `wget`

```bash
sudo pacman -S wget
```

### For ARM64 installation, use the ARM fork

```bash
wget -qO- https://raw.githubusercontent.com/nilszeilon/armarchy/master/boot.sh | OMARCHY_REPO=jondkinney/armarchy OMARCHY_REF=vm-testing bash
```

Follow the prompts and good luck...
