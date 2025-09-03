#!/bin/bash

# Install default / required ARM-specific packages after repository configuration

# Only run on ARM systems (aarch64)
if [[ "$OMARCHY_ARM" == "true" ]] && [[ "$(uname -m)" == "aarch64" ]]; then
  # Widevine is what allow for playing back DRM/protected content in browsers.
  # It's only available for ARM64 via the asahi-alarm repo. The
  # omarchy-chromium microfork includes a widevine hook for x86_64 and ARM64,
  # but this package is still necessary on ARM64 systems to provide the actual
  # widevine libraries. Without it, playback of DRM content (e.g. Netflix,
  # Disney+, Spotify, etc) will not work.
  echo "Detected ARM64 system - Installing widevine..."
  sudo pacman -S --needed --noconfirm asahi-alarm/widevine

  # More packages below, as needed.
fi
