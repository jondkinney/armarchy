echo "Installing tobi-try for ARM..."

if command -v try &>/dev/null && [ -f /usr/local/lib/try/lib/tui.rb ]; then
  echo "tobi-try already installed, skipping"
  return 0
fi

tmp_dir="$(mktemp -d)"
echo "Downloading tobi/try from GitHub..."
curl -fsSL "https://github.com/tobi/try/archive/refs/heads/main.tar.gz" | tar -xz -C "$tmp_dir"

sudo mkdir -p /usr/local/lib/try
sudo cp -a "$tmp_dir"/try-main/try.rb /usr/local/lib/try/
sudo cp -a "$tmp_dir"/try-main/lib /usr/local/lib/try/

sudo tee /usr/local/bin/try >/dev/null <<'EOF'
#!/usr/bin/env bash
exec /usr/bin/env ruby /usr/local/lib/try/try.rb "$@"
EOF
sudo chmod 755 /usr/local/bin/try
sudo ln -sf /usr/local/bin/try /usr/bin/try

rm -rf "$tmp_dir"

echo "tobi-try installed successfully"
