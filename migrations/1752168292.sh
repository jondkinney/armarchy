echo "Enable battery low notifications for laptops"

if omarchy-battery-present && [[ ! -f ~/.local/share/omarchy/config/systemd/user/omarchy-battery-monitor.service ]]; then
  mkdir -p ~/.config/systemd/user

  cp ~/.local/share/omarchy/config/systemd/user/omarchy-battery-monitor.* ~/.config/systemd/user/

  systemctl --user daemon-reload
  systemctl --user enable --now omarchy-battery-monitor.timer || true
fi
