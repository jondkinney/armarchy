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

$PKG_MANAGER -Syy --noconfirm --needed \
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
  python-terminaltexteffects \
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
  yay \
  zoxide

# Install additional packages for x86_64, non-ARM systems. Many of these are
# not available or not stable on ARM when installed via AUR. So we will
# install ARM compatible versions in the next section.
if [ -z "$OMARCHY_ARM" ]; then
  $PKG_MANAGER -S --noconfirm --needed \
    1password-beta \
    1password-cli \
    asdcontrol-git \
    localsend \
    obs-studio \
    obsidian \
    omarchy-chromium \
    pinta \
    qt5-wayland \
    signal-desktop \
    spotify \
    ttf-ia-writer \
    ttf-jetbrains-mono-nerd \
    typora \
    tzupdate \
    ufw-docker \
    walker-bin \
    wl-screenrec \
    yaru-icon-theme
fi

if [ -n "$OMARCHY_ARM" ]; then
  source $OMARCHY_INSTALL/arm_install_scripts/walker-prebuilt.sh
  source $OMARCHY_INSTALL/arm_install_scripts/asdcontrol-prebuilt.sh
  source $OMARCHY_INSTALL/arm_install_scripts/obsidian-appimage.sh
  source $OMARCHY_INSTALL/arm_install_scripts/omarchy-chromium-arm64.sh
fi
