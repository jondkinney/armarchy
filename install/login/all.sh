run_logged $OMARCHY_INSTALL/login/plymouth.sh

# Limine Snapper isn't supported on ARM at this time
if [[ "$arch" != "aarch64" || "$arch" != "arm64" ]]; then
  run_logged $OMARCHY_INSTALL/login/limine-snapper.sh
fi

run_logged $OMARCHY_INSTALL/login/enable-mkinitcpio.sh
run_logged $OMARCHY_INSTALL/login/alt-bootloaders.sh
