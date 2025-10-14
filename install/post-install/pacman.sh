  # Configure pacman

  # Skip for online installs - preflight/pacman.sh already handled this
  if [[ -n ${OMARCHY_ONLINE_INSTALL:-} ]]; then
    return 0
  fi

  # Configure pacman for ARM (supports edge/stable mirrors)
  if [[ -n "$OMARCHY_ARM" ]]; then
    if [[ ${OMARCHY_MIRROR:-} == "edge" ]]; then
      sudo cp -f ~/.local/share/omarchy/default/pacman/pacman-edge.conf /etc/pacman.conf
      sudo cp -f ~/.local/share/omarchy/default/pacman/mirrorlist-edge /etc/pacman.d/mirrorlist
      sudo cp -f ~/.local/share/omarchy/default/pacman/mirrorlist.asahi-alarm /etc/pacman.d/mirrorlist.asahi-alarm
    else
      sudo cp -f ~/.local/share/omarchy/default/pacman/pacman-stable.conf /etc/pacman.conf
      sudo cp -f ~/.local/share/omarchy/default/pacman/mirrorlist-stable /etc/pacman.d/mirrorlist
    fi
    return 0
  fi

  # Configure pacman for x86 offline installs
  sudo cp -f ~/.local/share/omarchy/default/pacman/pacman.conf /etc/pacman.conf
  sudo cp -f ~/.local/share/omarchy/default/pacman/mirrorlist /etc/pacman.d/mirrorlist

  # Add T2 Mac repository if needed (x86 only)
  if lspci -nn | grep -q "106b:180[12]"; then
    cat <<EOF | sudo tee -a /etc/pacman.conf >/dev/null

  [arch-mact2]
  Server = https://github.com/NoaHimesaka1873/arch-mact2-mirror/releases/download/release
  SigLevel = Never
  EOF
  fi
