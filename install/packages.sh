# Manually install yay from AUR if not already available
if ! command -v yay &>/dev/null; then
  # Install build tools
  sudo pacman -Sy --needed --noconfirm base-devel
  cd /tmp
  rm -rf yay-bin
  git clone https://aur.archlinux.org/yay-bin.git
  cd yay-bin
  makepkg -si --noconfirm
  cd -
  rm -rf yay-bin
  cd ~
fi

# Set package manager based on architecture
if [ -n "$OMARCHY_ARM" ]; then
  PKG_MANAGER="yay"
else
  PKG_MANAGER="sudo pacman"
fi

# Handle jack2 to pipewire-jack transition proactively
# pipewire-jack provides jack functionality and conflicts with jack2
# Install pipewire-jack first to prevent conflicts during main package installation
if pacman -Q jack2 &>/dev/null; then
  echo "Replacing jack2 with pipewire-jack..."
  printf "y\ny\n" | sudo pacman -S --needed pipewire-jack
else
  echo "Installing pipewire-jack to prevent jack2 conflict..."
  sudo pacman -S --noconfirm --needed pipewire-jack
fi

# Install packages (no sync, already done in repositories.sh)
$PKG_MANAGER -Syy --noconfirm --needed \
  1password-beta \
  1password-cli \
  asdcontrol-git \
  alacritty \
  avahi \
  bash-completion \
  bat \
  blueberry \
  brightnessctl \
  btop \
  cargo \
  clang \
  cups \
  cups-browsed \
  cups-filters \
  cups-pdf \
  docker \
  docker-buildx \
  docker-compose \
  dust \
  evince \
  eza \
  fastfetch \
  fcitx5 \
  fcitx5-gtk \
  fcitx5-qt \
  fd \
  ffmpegthumbnailer \
  fzf \
  gcc14 \
  github-cli \
  gnome-calculator \
  gnome-keyring \
  gnome-themes-extra \
  gum \
  gvfs-mtp \
  hypridle \
  hyprland \
  hyprland-qtutils \
  hyprlock \
  hyprpicker \
  hyprshot \
  hyprsunset \
  imagemagick \
  impala \
  imv \
  inetutils \
  jq \
  kdenlive \
  kvantum-qt5 \
  lazydocker \
  lazygit \
  less \
  libqalculate \
  libreoffice \
  llvm \
  luarocks \
  mako \
  man \
  mariadb-libs \
  mise \
  mpv \
  nautilus \
  noto-fonts \
  noto-fonts-cjk \
  noto-fonts-emoji \
  noto-fonts-extra \
  nss-mdns \
  nvim \
  pamixer \
  pipewire-alsa \
  pipewire-pulse \
  playerctl \
  plocate \
  plymouth \
  polkit-gnome \
  postgresql-libs \
  power-profiles-daemon \
  python-gobject \
  python-poetry-core \
  ripgrep \
  satty \
  slurp \
  starship \
  sushi \
  swaybg \
  swayosd \
  system-config-printer \
  tldr \
  tree-sitter-cli \
  ttf-cascadia-mono-nerd \
  ttf-jetbrains-mono \
  ufw \
  unzip \
  uwsm \
  waybar \
  wf-recorder \
  whois \
  wiremix \
  wireplumber \
  wl-clip-persist \
  wl-clipboard \
  wl-screenrec \
  woff2-font-awesome \
  xdg-desktop-portal-gtk \
  xdg-desktop-portal-hyprland \
  xmlstarlet \
  xournalpp \
  yaru-icon-theme \
  yay \
  zoxide

if [ -z "$OMARCHY_ARM" ]; then
  $PKG_MANAGER -S --noconfirm --needed \
    1password-beta \
    1password-cli \
    localsend \
    obs-studio \
    obsidian \
    pinta \
    signal-desktop \
    spotify \
    ttf-ia-writer \
    typora \
    tzupdate \
    ufw-docker \
    walker-bin \
    wl-screenrec \
    yaru-icon-theme
fi

if [ -n "$OMARCHY_ARM" ]; then
  if grep -qi "asahi" /etc/os-release 2>/dev/null ||
    uname -r | grep -qi "asahi" ||
    pacman -Q linux-asahi &>/dev/null ||
    pacman -Q asahi-scripts &>/dev/null; then

    echo "Detected Asahi Linux - Installing widevine..."

    $PKG_MANAGER -S --noconfirm --needed \
      asahi-alarm/widevine
  fi

  # Remove any existing walker packages before installing specific version
  echo "Removing any existing walker packages..."
  sudo pacman -Rdd --noconfirm walker walker-bin 2>/dev/null || true
  yay -Rdd --noconfirm walker walker-bin 2>/dev/null || true

  # Install walker version 0.13.26 from AUR for ARM (force exact version)
  echo "Installing walker 0.13.26 from AUR for ARM..."
  yay -S --noconfirm --overwrite='*' walker=0.13.26

  $PKG_MANAGER -S --noconfirm --needed \
    obsidian-appimage
fi
