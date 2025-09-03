# Install Omarchy on an m4 macbook pro with Parallels

Download archboot from here https://release.archboot.com/aarch64/latest/iso/

The archboot download page showing available ISO options:
![](install_guide/image001.png)
I chose the largest one, which is an offline "local" installer.

> **Network Requirements**: Local ISOs work offline (largest), standard ISOs need internet (medium), netboot (smallest) requires _wired_ ethernet.

## Create a new VM choosing "Install from an image file"

![](install_guide/image002.png)

## Choose your iso manually

![](install_guide/image003.png)

Click "select a file..."
![](install_guide/image004.png)

Browse and select the downloaded archboot ISO file
![](install_guide/image005.png)

A warning will pop up stating "Unable to detect operating system". That's fine, click "Continue".
![](install_guide/image006.png)

Choose "Other" from the operating system list
![](install_guide/image007.png)

Name your VM, choose a location, then check "Customize settings before installation":
![](install_guide/image008.png)

The Configuration window will appear with VM settings
![](install_guide/image009.png)

Customize the Hardware preferences (CPU and Memory)
![](install_guide/image010.png)

Graphics settings configuration:
![](install_guide/image011.png)

The hard drive will only allow us to install the default 64gb capacity, but we'll grow that after we boot to the new OS
![](install_guide/image012.png)

## Ensure CD/DVD is chosen for boot order, initially

![](install_guide/image013.png)

I didn't enable disk encryption
![](install_guide/image014.png)

Up to you, but I'm leaving SmartGuard off. I plan to manually take snapshots and use the built-in limine bootloader snapshot capabilities, just like "real" hardware!
![](install_guide/image015.png)

## Since you've selected the ISO, start the machine and it'll boot to this screen

![](install_guide/image016.png)

## Then it'll boot to the Aarch64 ISO

![](install_guide/image017.png)

## Choose "ENTER" and set it up with your locale.

![](install_guide/image018.png)

## Then choose "No" when prompted to use Online Mode since the mirrors are experiencing DDoS attacks as of August 2025.

![](install_guide/image019.png)

Configure your timezone region
![](install_guide/image020.png)

Choose the nearest city in your timezone
![](install_guide/image021.png)

Confirm the date
![](install_guide/image022.png)

Confirm the time
![](install_guide/image023.png)

Launch Archboot Setup
![](install_guide/image024.png)

Prepare Storage Device
![](install_guide/image025.png)

Choose "Quick Setup (erases the ENTIRE storage device)"
![](install_guide/image026.png)

Choose your storage device (there is only one option)
![](install_guide/image027.png)

Select the PARTUUID Device Name Scheme since we have a GPT disk
![](install_guide/image028.png)

Choose SINGLEBOOT for the EFI System Partition (ESP)
![](install_guide/image029.png)

Accept the default of 512mb for the EFI System Partition size
![](install_guide/image030.png)

Choose the default of 256mb for the Swap partition
![](install_guide/image031.png)

Choose btrfs for the Filesystem type
![](install_guide/image032.png)

Confirm Filesystem will be used for / and /home
![](install_guide/image033.png)

Set the /home volume to 0 to nest the /home directory within the root btrfs partition
![](install_guide/image034.png)

Confirm the full size will be used for the root partition
![](install_guide/image035.png)

Confirm the volume /dev/sda will be COMPLETELY ERASED!
![](install_guide/image036.png)

Filesystem created successfully
![](install_guide/image037.png)

Quick Setup was successful
![](install_guide/image038.png)

## Step 2 - Install Packages

Select "Install Packages" from the main menu
![](install_guide/image039.png)

Package installation menu:
![](install_guide/image040.png)

Package installation in progress:
![](install_guide/image041.png)

Package selection complete:
![](install_guide/image042.png)

Let it complete, then choose "Configure System"
![](install_guide/image043.png)

Set a new root password
![](install_guide/image044.png)

Confirm root password
![](install_guide/image045.png)

Don't be a baby... neovim for the win!
![](install_guide/image046.png)

Package installation complete
![](install_guide/image047.png)

## MKINITCPIO Setup

MKINITCPIO configuration menu
![](install_guide/image048.png)

MKINITCPIO generation in progress
![](install_guide/image049.png)

When that completes you'll see this

MKINITCPIO complete, back to configuration menu

Enter User Management
![](install_guide/image050.png)

Choose "Set the default shell"
![](install_guide/image051.png)

Choose BASH (the Omarchy default). I highly recommend against changing to zsh or fish until you have everything fully configured how you want it. Even then all the update scripts, etc. run through Bash, so even though I'm a long time zsh user, I'm personally just going to stick with Bash and adapt my tooling accordingly. The only thing I really miss is better auto completion, but there are packages for that.
![](install_guide/image052.png)

Shell configuration complete
![](install_guide/image053.png)

## Create a user account

User account creation menu:
![](install_guide/image054.png)

Enter username
![](install_guide/image055.png)

Enable `user` as Administrator and part of the wheel group
![](install_guide/image056.png)

Enter full name
![](install_guide/image057.png)

Set user password
![](install_guide/image058.png)

Confirm user password
![](install_guide/image059.png)

New password set successfully
![](install_guide/image060.png)

User account created successfully
![](install_guide/image061.png)

Return to main configuration menu
![](install_guide/image062.png)

## Return to main menu

![](install_guide/image063.png)

## Install Bootloader

Bootloader installation menu
![](install_guide/image064.png)

## Install the GRUB_EUFI Bootloader

![](install_guide/image065.png)

GRUB installation complete
![](install_guide/image066.png)

Proceed to open GRUB(2) configuration file in neovim
![](install_guide/image067.png)

## Review GRUB_EUFI Configuration file

![](install_guide/image068.png)

Just save and quit again `:wq`

![](install_guide/image069.png)

GRUB configuration saved
![](install_guide/image070.png)

Bootloader installation complete
![](install_guide/image071.png)

Final installation summary
![](install_guide/image072.png)

## Reboot to your new aarch64 install!

![](install_guide/image073.png)

## Remove the ISO from the cd/dvd drive before reboot!

![](install_guide/image074.png)

## Disconnect the ISO in 10s before the reboot happens!

![](install_guide/image075.png)

Then you'll boot to the GRUB menu. Choose:

\*Arch Linux

...and boot your new system!
![](install_guide/image076.png)

Arch Linux login prompt
![](install_guide/image077.png)
For me it's "jon" and my password and I'm logged in

## Congrats! You now have aarch64 installed to a VM!

![](install_guide/image078.png)

## Shutdown the machine so we can resize the hard drive before installing Omarchy

![](install_guide/image079.png)

Again, not sure why, but it seems like a bug that you have to fully install `aarch64` before you can resize the Parallels Hard Drive. Typically you'd be able to do that when setting it up, which would save us some steps, but it's not that big of a deal. Let's increase the Parallels disk size now that `aarch64` is installed.

## Open Parallels Control Center and right click your VM

![](install_guide/image080.png)

## Choose "Configure..."

![](install_guide/image081.png)

## Set the Hard Drive size to be 128gb or larger (I chose 256gb) and click "Apply"

![](install_guide/image082.png)

## Choose "Continue"

![](install_guide/image083.png)

I chose 256gb for my root volume
![](install_guide/image084.png)

Enable TRIM
![](install_guide/image085.png)

The warning says we're not on an SSD, but we are. I _think_ this is fine, but more research is needed. It's possible that if the machine doesn't _think_ it's on an SSD, even though it is, this could impact performance. Please let me know in the comments.

Confirm we want to enable TRIM
![](install_guide/image086.png)

Press OK
![](install_guide/image087.png)

Now you have a Parallels VM with Aarch64 and a 256GB Hard drive which is big enough for Omarchy to be installed on.

Go back to the Control Center and double click your new VM to launch it!

Parallels Control Center - ready to launch VM
![](install_guide/image088.png)

Press Play!
![](install_guide/image089.png)

At the GRUB bootloader, choose: `*Arch Linux`
![](install_guide/image090.png)

Now you're back to the login, so login with the root user and the password you set for the root user so that we can install the `sudo` package to allow elevating our normal user with root permissions.

![](install_guide/image091.png)

Install `sudo` and `openssh`

```bash
pacman -Syu sudo openssh
```

![](install_guide/image092.png)

Confirm package installation
![](install_guide/image093.png)

Package installation complete
![](install_guide/image094.png)

## Instal `vi` so we can check the sudoers files

```
pacman -Syu vi
```

![](install_guide/image095.png)

Now run `visudo` and update the sudoers configuration to look like this enabling all commands for users of the `wheel` group, which we previously setup for our user.

![](install_guide/image096.png)

Save and quit the visudo file with `:wq`

## Set up SSH

Enable and start the SSH service

```
systemctl enable sshd
systemctl start sshd
```

![](install_guide/image097.png)

### Check SSH is running

```
systemctl status sshd
```

![](install_guide/image098.png)

## Find your VM's IP address

```
ip addr show
```

![](install_guide/image099.png)

Now we can connect from our host machine over SSH in something like Ghostty or iTerm2 or Alacrity, etc. to more easily copy and paste commands!

![](install_guide/image100.png)

Ensure that we have full compatibility by adding `export TERM=xterm-256color` to the bottom of the `~/.bashrc` file like so:

```
export TERM=xterm-256color
```

![](install_guide/image101.png)

Write and quit with `:wq` then close the connection by typing `exit` and then re-connect and you should have the ability to type `clear` amongst other things. We're fully compatible now!

## Grow the root partition to the new 256gb size

Check the partition names with `lsblk` and `sudo fdisk -l`

Current partition layout before resize
![](install_guide/image102.png)

## Install the `parted` disk utility

![](install_guide/image103.png)

## Grow the partition with `parted`

```
sudo parted /dev/sda resizepart 4 100%
```

![](install_guide/image104.png)

We can ignore the details in the "Information:" response

![](install_guide/image105.png)

Our root partition is now 256gb. Huzzah!

![](install_guide/image106.png)

## Finally, resize the Btrfs filesystem to use the expanded partition

After growing the partition, we need to tell the Btrfs filesystem to use the newly available space

```bash
sudo btrfs filesystem resize max /
```

This command resizes the Btrfs filesystem on the root mount point (/) to use the maximum available space on the partition.

Notice how `/dev/sda4` increases in size after this command.
![](install_guide/image107.png)

At this point I'd recommend taking a snapshot of the system so that if any of the following steps fail, we can easily restore to this point in time.

## Take a snapshot

Shutdown the VM

```
shutdown now
```

![](install_guide/image108.png)

When you open Parallels back up, before booting, choose "Take Snapshot..." from the "Actions" menu.

![](install_guide/image109.png)

Name and describe your snapshot, save it, and reboot the system. From this safe point, we'll configure the default bootloader that Omarchy's ISO uses so we can take advantage of automatic snapshots the same way an ISO installed to real hardware would.

# Reconnect to continue

Reconnect to your VM over SSH (use your username and IP address)

```bash
ssh jon@10.211.55.9
```

# Limine + Btrfs Snapshots on Parallels ARM64

## ⚡ Quick Option: Automated Installation Script

**For users who prefer automation over manual configuration:**

You can skip the manual Limine installation process below by using our automated script that handles everything automatically:

```bash
# Download and run the automated Limine installation script
curl -O https://raw.githubusercontent.com/jondkinney/armarchy/vm-testing/install-limine-automated.sh
chmod +x install-limine-automated.sh
./install-limine-automated.sh
```

**What the automated script does:**

- ✅ Updates system packages
- ✅ Installs development tools and AUR helper
- ✅ Configures Snapper for Btrfs snapshots
- ✅ Downloads Omarchy scripts from ARM fork repository
- ✅ Installs Plymouth and configures boot hooks
- ✅ Downloads and installs Limine 9.5.3 bootloader
- ✅ Sets up hierarchical snapshot menu
- ✅ Configures automatic snapshot synchronization
- ✅ Creates global symlinks for command access

**The script will prompt you to choose:**

- **Test mode**: Boot Limine once for testing (keeps GRUB as default)
- **Default mode**: Make Limine the permanent default bootloader

**After running the automated script:**

- The system will be fully configured with Limine bootloader
- Skip ahead to **[📍 RESUME HERE: Post-Automated Script Installation](#-resume-here-post-automated-script-installation)**
- All manual steps (Step 0-11) are handled automatically

---

## 📋 Manual Installation (Skip if you used the automated script above)

**For users who prefer step-by-step control:**

## Prerequisites

- Fresh Arch Linux ARM64 on Parallels Desktop
- Btrfs filesystem with `/root` subvolume (no `/home` subvolume)

### Step 0: Verify System State

Confirm ESP is mounted and accessible

```bash
lsblk -f
mount | grep -E "(boot|efi)"
```

Confirm btrfs root

```bash
findmnt -t btrfs /
```

Verify we have the expected filesystem layout

```bash
sudo fdisk -l /dev/sda
```

## Step 1: Install Development Tools

Update the package repositories before installing

```bash
sudo pacman -Syu
```

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

## Step 2: Install Core Snapshot Infrastructure

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

## Step 3: Configure Filesystem Snapshots

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

## Step 4: Configure Boot Infrastructure

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

## Step 5: Prepare EFI Environment

Now that we've verified ESP access, create the EFI directory structure:

```bash
ESP="/boot"
EFI_DIR="$ESP/EFI/BOOT"
sudo mkdir -p "$EFI_DIR"
```

## Step 6: Install Automatic Snapshot System

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

## Step 7: Create and Test Initial Snapshots

Now snapshots will have proper initramfs support:

```bash
sudo snapper -c root create --description "Initial setup"
```

Show the snapshot in the list

```bash
sudo snapper -c root list
```

## 🎯 PARALLELS SNAPSHOT POINT 🎯

**Create a Parallels snapshot here!** This allows you to easily test different Limine versions or revert if something goes wrong with the following bootloader installation.

## Step 8: Install and Configure Limine Bootloader

This step combines downloading Limine, creating the configuration, and installing everything

#### Download Limine 9.5.3 binary directly

```bash
cd /tmp &&
rm -rf limine 2>/dev/null || true &&
git clone --depth 1 --branch v9.5.3-binary https://github.com/limine-bootloader/limine.git &&
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
echo "Installing $TMPDIR/BOOTAA64.EFI → $EFI_DIR/BOOTAA64.EFI" &&
sudo install -m 0644 "$TMPDIR/BOOTAA64.EFI" "$EFI_DIR/BOOTAA64.EFI" &&

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
    echo "Creating new Limine boot entry..." &&
    sudo efibootmgr -c -d "$DISK" -p "$ESP_NUM" -L "$LIMINE_LABEL" -l '\EFI\BOOT\BOOTAA64.EFI' &&

    # Find the newly created entry
    ENTRY=$(sudo efibootmgr -v | awk '/^Boot[0-9A-Fa-f]{4}/ && (/Limine/ || /\\\\EFI\\\\BOOT\\\\BOOTAA64.EFI/){gsub("^Boot","",$1);gsub("\\*","",$1);print $1;exit}')
else
    echo "Found existing Limine boot entry: Boot$ENTRY"
fi
```

#### Set boot order (keeping GRUB as default for safety)

```bash
LIMINE_NUM=$(sudo efibootmgr | grep "Limine" | cut -c5-8) &&
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

If it worked you should see the config updated with a nested snapshot entry!

```bash
### Read more at config document: https://github.com/limine-bootloader/limine/blob/trunk/CONFIG.md
timeout: 12
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

/+Omarchy
comment: Omarchy
comment: machine-id=9dc2ee64e0f546b5a4f76c909b3064aa order-priority=50
  //linux
  comment: linux
  protocol: linux
  kernel_path: boot():/Image
  module_path: boot():/initramfs-linux.img
  kernel_cmdline: root=UUID=8bb5acb2-a416-4c7c-8fcf-5cf19167807b rootflags=subvol=/root rw rootfstype=btrfs quiet splash

  //Snapshots
  comment: Select a snapshot to boot into
    ///Snapshot 1 - Initial setup
    comment: Snapshot 1
    protocol: linux
    kernel_path: boot():/Image
    module_path: boot():/initramfs-linux.img
    kernel_cmdline: root=UUID=8bb5acb2-a416-4c7c-8fcf-5cf19167807b rootflags=subvol=root/.snapshots/1/snapshot rw rootfstype=btrfs quiet splash
```

## Step 9: Test Automatic Snapshot Integration

Verify that the automatic system is working

Test automatic snapshot detection and menu updates

```bash
sudo snapper -c root create --description "Test automatic updates"
```

Wait a moment for the service to trigger, then check the menu

```bash
cat "$EFI_DIR/limine.conf" | grep -A100 "//Snapshots"
```

Monitor automatic updates in real-time (optional)

```bash
sudo journalctl -u omarchy-limine-snapshot.service -f
```

You should see:

- Latest snapshot appears at the top (newest first)
- Hierarchical structure: `/+Omarchy` → `//Snapshots` → `///Snapshot X`
- Automatic updates when new snapshots are created

## Step 10: Test Limine Boot (One-Time)

Set `limine` for the next boot only as a safety precaution. That way we can choose "reset" from the Actions menu in Parallels if we need to hard reboot the machine because our `limine` configuration didn't work and it'll boot to `GRUB`.

```bash
LIMINE_NUM=$(sudo efibootmgr | grep "Limine" | cut -c5-8)
sudo efibootmgr --bootnext $LIMINE_NUM
```

Verify `0001` is set for `BootNext` value

![](install_guide/image110.png)

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
![](install_guide/image111.png)

## Step 11: Make Limine Permanent (After Successful Testing)

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

Reboot one final time and you'll have your permanently configured bootloader with restorable snapshots!

![](install_guide/image112.png)

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

---

# 📍 RESUME HERE: Post-Automated Script Installation

**If you used the automated installation script above, resume from this point.**

**Your system now has:**

- ✅ Limine bootloader fully configured with hierarchical snapshots
- ✅ All Omarchy scripts and services installed
- ✅ Automatic snapshot monitoring active
- ✅ Boot configuration set based on your preference (test/default)

**Next: Install Parallels Tools for better VM integration**

---

## Step 12: Installing Parallels Tools

Login as root or elevate to root from your currently logged in user:

```bash
sudo su
```

Choose Actions -> Install Parallels Tools...
![](install_guide/image116.png)

Click Continue if prompted
![](install_guide/image117.png)

Mount the CD Rom

```bash
mount /dev/cdrom /mnt
```

Copy the full CD directory to home directory and rename it to `prl-tools-build`:

```bash
cp -R /mnt ~ &&
cd ~ &&
mv mnt prl-tools-build &&
cd prl-tools-build
```

Install the prerequisites to build `prl-tools-build`

```bash
pacman -S fuse2 linux-headers dkms net-tools
```

Install parallels tools

```
./install
```

This shows both an error and success. I had to install the aforementioned packages and then installation worked.
![](install_guide/image118.png)

View the `parallels-tools-install.log` with:

```bash
cat /var/log/parallels-tools-install.log
```

## Step 13: Install Omarchy (finally!)

We made it! Definitely take a snapshot in both Arch and Parallels at this point so that you have a fresh pre-Omarchy install attempt point to revert to.

### Install `wget`

```bash
sudo pacman -S wget
```

### For ARM64 installation, use the ARM fork

```bash
wget -qO- https://raw.githubusercontent.com/nilszeilon/armarchy/master/boot.sh | OMARCHY_REPO=jondkinney/armarchy OMARCHY_REF=vm-testing bash
```

Follow the prompts and good luck...

## Step 14: ARM-Specific Configuration (Automatically Handled)

### asahi-alarm Mirror and Widevine Installation

> **Good news!** ARM-specific configuration is now automatically handled during the Omarchy installation process.

**What happens automatically:**

- ✅ **asahi-alarm mirror** is automatically configured in `pacman.conf` for ARM systems
- ✅ **mirrorlist.asahi-alarm** is automatically created with the correct server
- ✅ **widevine package** is automatically installed from asahi-alarm during package installation
- ✅ **ARM-specific packages** are handled by the install scripts

**No manual configuration needed!** The Omarchy installer will:

1. Detect that you're on an ARM64 system
2. Use the ARM-specific pacman configuration that includes asahi-alarm
3. Install widevine and other ARM packages automatically during the normal install process

Simply proceed with the Omarchy installation and everything will be configured correctly for your Apple Silicon Mac.
