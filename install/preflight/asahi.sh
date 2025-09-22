# Prerequisites for installing Omarchy on a m-series macbook
#
# 1. Follow these instructions: https://asahi-alarm.org/ and choose the minimal installation (1)
# 2. Set up wifi and install wget
# 3. Run the omarchy install command
#   wget -qO- https://raw.githubusercontent.com/nilszeilon/armarchy/refs/heads/master/boot.sh | boot
#   and follow the prompts

# Asahi Linux ARM setup script for Omarchy
# This script automates the post-Asahi installation steps for MacBook M-series

# Check if we're on ARM architecture
arch=$(uname -m)
if [[ "$arch" == "aarch64" || "$arch" == "arm64" ]]; then

  # On ARM - check if this is initial Asahi setup (requires root)
  if [[ $EUID -eq 0 ]]; then
    set -e  # Exit on error for all operations below

    echo
    # Running as root - check for Asahi indicators
    if grep -qi "asahi" /etc/os-release 2>/dev/null ||
      uname -r | grep -qi "asahi" ||
      pacman -Q linux-asahi &>/dev/null ||
      pacman -Q asahi-scripts &>/dev/null; then

      arch_type="Asahi"
    else
      arch_type="ARM"
    fi
    echo "Detected $arch_type Linux - setting up user account and running the omarchy installer..."
    echo

    # Install gum for user interaction (needed in bootstrap mode when helpers aren't sourced)
    if ! command -v gum &>/dev/null; then
      echo "Installing gum for interactive setup..."
      pacman -S --needed --noconfirm gum || {
        echo "Error: Failed to install gum"
        exit 1
      }
    fi

    # Check if user already exists
    echo "Setting up user account..."
    existing_users=$(awk -F: '$3 >= 1000 && $1 != "nobody" {print $1}' /etc/passwd)

    if [ -n "$existing_users" ]; then
      echo "Found existing users: $existing_users"
      use_existing=$(gum confirm "Use an existing user account?" && echo "yes" || echo "no")

      if [ "$use_existing" = "yes" ]; then
        username=$(echo "$existing_users" | gum choose --header "Select user:")
      else
        username=$(gum input --placeholder "Enter new username")
      fi
    else
      username=$(gum input --placeholder "Enter username for Omarchy")
    fi

    # Create user if doesn't exist
    if ! id "$username" &>/dev/null; then
      echo "Creating user $username..."
      useradd -m "$username"

      echo "Setting password for $username..."
      while true; do
        password=$(gum input --password --placeholder "Enter password for $username")
        password_confirm=$(gum input --password --placeholder "Confirm password")

        if [ "$password" = "$password_confirm" ]; then
          echo "$username:$password" | chpasswd
          break
        else
          echo "Passwords don't match. Please try again."
        fi
      done

      # Add to wheel group for sudo access
      usermod -aG wheel "$username"
      echo "Added $username to wheel group"
    fi

    # Enable sudo for wheel group
    echo "Configuring sudo access..."
    if grep -q "^# %wheel ALL=(ALL:ALL) ALL" /etc/sudoers; then
      sed -i 's/^# %wheel ALL=(ALL:ALL) ALL/%wheel ALL=(ALL:ALL) ALL/' /etc/sudoers
      echo "Enabled sudo for wheel group"
    elif ! grep -q "^%wheel ALL=(ALL:ALL) ALL" /etc/sudoers; then
      echo "%wheel ALL=(ALL:ALL) ALL" >>/etc/sudoers
      echo "Added wheel group to sudoers"
    fi

    echo
    echo "Initial user setup complete!"
    echo "Continuing the rest of the installation as user $username..."
    echo

    # Re-run the boot script as the new user to continue installation
    REPO="${OMARCHY_REPO:-jondkinney/armarchy}"
    REF="${OMARCHY_REF:-amarchy-3-x}"
    su - $username -c "curl -s https://raw.githubusercontent.com/${REPO}/${REF}/boot.sh | OMARCHY_REPO='${REPO}' OMARCHY_REF='${REF}' bash"

      # Exit after su completes to prevent further execution as root
      exit 0
    fi
  else
    # On ARM but not root - error for initial setup
    echo "This script must be run as root for initial setup"
    echo "Please run: sudo bash $0"
    exit 1
  fi
fi
# If not on ARM at all, script continues normally (part of regular install flow)
