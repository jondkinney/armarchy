echo "Switch the screenshot editor from Satty to Tensaku"

omarchy-pkg-add tensaku
omarchy-pkg-drop satty

omarchy-refresh-config imv/config
