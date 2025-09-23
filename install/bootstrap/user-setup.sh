existing_users=$(awk -F: '$3 >= 1000 && $1 != "nobody" {print $1}' /etc/passwd)

if [[ $EUID -eq 0 ]]; then
  # Install gum for user interaction (needed in bootstrap mode when helpers aren't sourced)
  if ! command -v gum &>/dev/null; then
    pacman -S --needed --noconfirm gum || {
      echo "Error: Failed to install the 'gum' package"
      exit 1
    }
  fi

  if [ -n "$existing_users" ]; then
    echo "Found existing users:"
    echo "$existing_users" | tr ' ' '\n' | sed 's/^/  - /'

    # Convert existing users to an array for gum
    readarray -t user_array <<< "$existing_users"

    # Loop until we get valid input
    while true; do
      # Force TTY allocation for gum when running from piped script
      if gum confirm "Use an existing user account?" < /dev/tty; then
        # Pass user array to gum choose
        username=$(gum choose --header "Select user:" "${user_array[@]}" < /dev/tty)
        exit_code=$?

        # Check for Ctrl+C (exit code 130) and exit cleanly
        if [ $exit_code -eq 130 ]; then
          echo "Installation cancelled."
          exit 130
        fi

        # Check if user cancelled with ESC or nothing was selected
        if [ $exit_code -ne 0 ] || [ -z "$username" ]; then
          echo "No user selected. Please try again."
          continue
        fi
      else
        username=$(gum input --placeholder "Enter new username for Omarchy" < /dev/tty)
        exit_code=$?

        if [ $exit_code -eq 130 ]; then
          echo "Installation cancelled."
          exit 130
        fi

        if [ -z "$username" ]; then
          echo "No username entered. Please try again."
          continue
        fi
      fi
      break
    done
  else
    # Loop until we get valid input for new user
    while true; do
      username=$(gum input --placeholder "Enter username for Omarchy" < /dev/tty)
      exit_code=$?

      if [ $exit_code -eq 130 ]; then
        echo "Installation cancelled."
        exit 130
      fi

      if [ -z "$username" ]; then
        echo "No username entered. Please try again."
        continue
      fi
      break
    done
  fi

  # Create user if doesn't exist
  if ! id "$username" &>/dev/null; then
    echo "Creating user $username and setting password..."
    useradd -m "$username"

    while true; do
      password=$(gum input --password --placeholder "Enter password for $username" < /dev/tty)
      exit_code=$?

      if [ $exit_code -eq 130 ]; then
        echo "Installation cancelled."
        exit 130
      fi

      if [ -z "$password" ]; then
        echo "No password supplied. Please try again."
        continue
      fi

      password_confirm=$(gum input --password --placeholder "Confirm password" < /dev/tty)
      exit_code=$?

      if [ $exit_code -eq 130 ]; then
        echo "Installation cancelled."
        exit 130
      fi

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
  else
    echo "Using existing user $username"
    # Ensure user is in wheel group even if they already exist
    usermod -aG wheel "$username"
  fi

  # Collect user details for git configuration
  echo
  user_fullname=$(gum input --placeholder "Enter your full name (for git config)" < /dev/tty)
  exit_code=$?

  if [ $exit_code -eq 130 ]; then
    echo "Installation cancelled."
    exit 130
  fi

  user_email=$(gum input --placeholder "Enter your email address (for git config)" < /dev/tty)
  exit_code=$?

  if [ $exit_code -eq 130 ]; then
    echo "Installation cancelled."
    exit 130
  fi

  # Enable sudo for wheel group
  echo "Configuring sudo access..."

  if ! command -v sudo &>/dev/null; then
    pacman -S --needed --noconfirm sudo && echo "Installed 'sudo' package..." || {
      echo "Error: Failed to install the 'sudo' package"
      exit 1
    }
  fi

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

  # Temporarily allow passwordless sudo for the installation
  echo "$username ALL=(ALL:ALL) NOPASSWD: ALL" > /etc/sudoers.d/omarchy-temp
  echo "Enabled temporary passwordless sudo for installation"

  # Re-run the boot script as the new user to continue installation
  # Pass repo/ref and user details to continue installation as the new user
  # Use printf %q to safely escape variables containing special characters
  escaped_fullname=$(printf '%q' "${user_fullname}")
  escaped_email=$(printf '%q' "${user_email}")

  # Build install command with sudo cleanup at the end
  install_cmd="export \
    HOME=/home/$username \
    USER=$username \
    LOGNAME=$username \
    OMARCHY_REPO='${OMARCHY_REPO}' \
    OMARCHY_REF='${OMARCHY_REF}' \
    OMARCHY_USER_NAME=${escaped_fullname} \
    OMARCHY_USER_EMAIL=${escaped_email}; \
    cd /home/$username; \
    curl -fsSL https://raw.githubusercontent.com/${OMARCHY_REPO}/${OMARCHY_REF}/boot.sh | bash; \
    install_result=\$?; \
    sudo rm -f /etc/sudoers.d/omarchy-temp 2>/dev/null && echo 'Removed temporary passwordless sudo'; \
    exit \$install_result"

  # Ensure runuser is available for better terminal handling
  if ! command -v runuser &>/dev/null; then
    pacman -S --needed --noconfirm util-linux && echo "Installed util-linux for runuser..."
  fi

  # Use runuser for better terminal handling
  echo "Starting Omarchy installation as user $username..."
  runuser -u $username -- bash -c "$install_cmd"

  # Exit after su completes to prevent further execution as root
  exit 0
fi

echo "No non-root users detected on this system. Initial setup must be run as root to create a non-root user."
echo "Please run this script as root."
exit 1
