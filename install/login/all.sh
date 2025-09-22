run_logged $OMARCHY_INSTALL/login/plymouth.sh

# Limine Snapper isn't supported on ARM at this time
if [ -z "$OMARCHY_ARM" ]; then
  run_logged $OMARCHY_INSTALL/login/limine-snapper.sh
fi

run_logged $OMARCHY_INSTALL/login/enable-mkinitcpio.sh
run_logged $OMARCHY_INSTALL/login/alt-bootloaders.sh
