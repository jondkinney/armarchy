# Test plan: PR #1897 Copilot review fixes

This branch (`copilot-review-fixes`) addresses review comments on PR
[basecamp/omarchy#1897](https://github.com/basecamp/omarchy/pull/1897).
Each section below covers one commit in the branch. Read the commit
message for the why; this document covers the **how to verify**.

## Shared preflight

Everything below assumes an existing omarchy-arm install at
`~/.local/share/omarchy` on `amarchy-3-x`, or a fresh install done from
this branch. To pull the branch onto an existing install for testing:

```bash
cd ~/.local/share/omarchy
git fetch origin copilot-review-fixes
git checkout copilot-review-fixes
```

To return to the normal branch afterwards:

```bash
git checkout amarchy-3-x
```

---

## Commit 1 — `clipboard-sync: guard on virt detection; mkdir /etc/systemd/user`

### What it fixes
- Running `install/virtualization/clipboard-sync.sh` on bare metal used to
  install `xclip clipnotify wl-clipboard wl-clip-persist` and enable two
  user systemd services that are only useful inside VMware/Parallels.
- The script wrote to `/etc/systemd/user/` via `sudo tee` without
  ensuring the directory existed, which can fail on fresh systems.

### How to test

**A. Bare-metal skip.** On a bare-metal (non-VM) machine:

```bash
# Simulate running the install step directly, without invoking the full
# packaging flow:
export OMARCHY_PATH="$HOME/.local/share/omarchy"
export OMARCHY_INSTALL="$OMARCHY_PATH/install"
source "$OMARCHY_PATH/install/virtualization/clipboard-sync.sh"
echo "exit: $?"
# Expect: script returns 0 immediately, no pacman output, no tee lines,
# and no /etc/systemd/user/omarchy-clipboard-*.service files created.
ls /etc/systemd/user/omarchy-clipboard-* 2>/dev/null || echo "(none, correct)"
```

**B. VMware/Parallels still works.** On a VMware or Parallels VM:

```bash
# Same sourcing as above. Expect:
# - pacman installs xclip, clipnotify, wl-clipboard, wl-clip-persist
# - /etc/systemd/user/omarchy-clipboard-wl-to-x11.service exists
# - /etc/systemd/user/omarchy-clipboard-x11-to-wl.service exists
# - `systemctl --global is-enabled omarchy-clipboard-wl-to-x11.service` says enabled
ls /etc/systemd/user/omarchy-clipboard-*
```

**C. `/etc/systemd/user` missing.** Simulate a fresh system where that
directory doesn't exist yet:

```bash
sudo rm -rf /etc/systemd/user
# Re-source the script in a VMware/Parallels VM
source "$OMARCHY_PATH/install/virtualization/clipboard-sync.sh"
# Expect: the script creates /etc/systemd/user and writes the two .service
# files successfully, rather than failing on the first `tee`.
ls /etc/systemd/user/
```

---

## Commit 2 — `omarchy-reinstall-git: use existing remote instead of hardcoding`

### What it fixes
`omarchy-reinstall-git` used to hardcode `https://github.com/basecamp/omarchy.git`,
which meant running `omarchy-reinstall` on armarchy silently reset to
upstream basecamp and lost all ARM customizations.

### How to test

**A. Dry-ish run — verify the clone URL.** Without actually replacing
your install, you can check what the script would do:

```bash
REMOTE_URL=$(git -C "$OMARCHY_PATH" remote get-url origin)
BRANCH=$(git -C "$OMARCHY_PATH" rev-parse --abbrev-ref HEAD)
case "$REMOTE_URL" in
  git@github.com:*) REMOTE_URL="https://github.com/${REMOTE_URL#git@github.com:}" ;;
esac
echo "Would clone: $REMOTE_URL"
echo "Branch:      $BRANCH"
# On armarchy-arm: expect jondkinney/armarchy and amarchy-3-x (or
# copilot-review-fixes while testing).
```

**B. Full run** (only if you want to actually reinstall — be warned it
moves `$OMARCHY_PATH` to `~/.local/share/omarchy-old`):

```bash
omarchy-reinstall-git
# Expect: `~/.local/share/omarchy` is now a fresh shallow clone of your
# origin (armarchy), on your current branch.
git -C ~/.local/share/omarchy remote get-url origin
git -C ~/.local/share/omarchy rev-parse --abbrev-ref HEAD
```

**C. SSH-origin conversion.** On a machine whose origin is
`git@github.com:jondkinney/armarchy.git`, verify the printed URL in
step A shows `https://...` — the script converts SSH to HTTPS so a
recovery scenario without SSH keys still works.

---

## Commit 3 — `Install libinput quirks automatically during arm bootstrap`

### What it fixes
libinput's disable-while-typing only fires on keyboards tagged as
`AttrKeyboardIntegration=internal`. keyd's virtual keyboard defaults to
external, so Hyprland's `disable_while_typing = true` becomes a no-op
when keyd is in use. Now the quirk is installed system-wide during
arm bootstrap, and a user-facing wrapper is available for retroactive
install.

### How to test

**A. Source file ships.** After clone/pull:

```bash
ls ~/.local/share/omarchy/default/libinput/local-overrides.quirks
```

Expect the file to exist.

**B. Bootstrap step is wired in.**

```bash
grep libinput-quirks ~/.local/share/omarchy/install/packaging/arch.sh
```

Expect the line `source $OMARCHY_INSTALL/arm_install_scripts/libinput-quirks.sh`.

**C. Manual install on existing system.** Remove any leftover `/etc`
quirk first, then run the wrapper:

```bash
sudo rm -f /etc/libinput/local-overrides.quirks
omarchy-install-libinput-keyd-quirk
ls -la /etc/libinput/local-overrides.quirks
sudo libinput quirks validate && echo OK
```

**D. Check the quirk applies.** Find the keyd virtual keyboard's event
device and verify libinput sees it as internal:

```bash
for f in /sys/class/input/input*/name; do
  sudo grep -qi "keyd virtual keyboard" "$f" 2>/dev/null && {
    evt="/dev/input/$(ls "$(dirname "$f")" | grep -E '^event[0-9]+$' | head -1)"
    sudo libinput quirks list "$evt"
    break
  }
done
# Expect to see: AttrKeyboardIntegration=internal
```

**E. No-keyd host is safe.** On a machine without keyd, the quirk still
gets installed but doesn't match anything:

```bash
# After install, on a machine where `command -v keyd` is empty:
sudo libinput quirks validate && echo "quirk file valid"
# No error, no spurious matches.
```

---

## Commit 4 — `Track obsidian metadata in repo; skip runtime download`

### What it fixes
The obsidian install script used to fetch the icon from the internet
and regenerate the .desktop file on every install, leaving untracked
files in the repo working tree.

### How to test

**A. Files are tracked.**

```bash
git -C ~/.local/share/omarchy ls-files applications/obsidian.desktop applications/icons/obsidian.png
# Expect: both paths listed (tracked).
git -C ~/.local/share/omarchy status --short applications/ | grep -E 'obsidian|apple' || echo "(no untracked obsidian/apple files — correct)"
```

**B. Install script fetches only when file missing.**

```bash
# Delete the icon to simulate a corrupted repo
rm ~/.local/share/omarchy/applications/icons/obsidian.png
# Re-source just the icon section — expect it to curl + convert
source "$OMARCHY_PATH/install/arm_install_scripts/obsidian-appimage.sh"
# Then restore from git so you don't leave the repo in a weird state
git -C ~/.local/share/omarchy checkout -- applications/icons/obsidian.png
```

**C. No orphan `apple.png`.**

```bash
ls ~/.local/share/omarchy/applications/icons/apple.png 2>/dev/null || echo "(gone — correct)"
```

---

## Commit 5 — `Fixes from PR #1897 Copilot review: typos, helpers, shell compat`

### What it fixes
- Typo `omarchy-x68.packages` → `omarchy-x86.packages`
- `$arch` referenced but never set in `install/preflight/arm.sh`
- `[[ ]]` in hypridle on-timeout command (may exec under `/bin/sh`)
- `gum choose` flags placed after options array
- `PADDING_LEFT` could go negative on narrow terminals
- `run_logged` string-interpolated env vars (broke on names with `'`)
- log monitor idle loop (`sleep 0.1`) — simplified from a broken `read -t` attempt

### How to test

**A. Typo.**

```bash
grep 'x68\|x86' ~/.local/share/omarchy/install/omarchy-base-official.packages | head
# Expect: only `omarchy-x86.packages`, no `omarchy-x68.packages`.
```

**B. `$arch` is set.** Source the script in a subshell that doesn't have
`arch` defined, and confirm the echo still prints a sensible value:

```bash
env -i HOME="$HOME" USER="$USER" PATH="/usr/bin:/bin" bash -c '
  export OMARCHY_ARM=true
  export OMARCHY_PATH="$HOME/.local/share/omarchy"
  source "$OMARCHY_PATH/install/preflight/arm.sh"
'
# Expect the first line to read:
# Auto-detected ARM architecture: aarch64
# Previously it printed:
# Auto-detected ARM architecture:
```

**C. Hypridle POSIX.** Reload hypridle and let the idle timer fire,
preferably under `/bin/sh` to prove the condition works. You can at
least smoke-test the string:

```bash
grep 'on-timeout' ~/.local/share/omarchy/config/hypr/hypridle.conf
# Expect POSIX `[ ... = ... ]` syntax, not `[[ ... == ... ]]`.
# Running live:
hyprctl reload  # applies conf changes
# Let the screen idle for 2.5 min (timeout = 150s) — screensaver should
# launch. Previously, under /bin/sh, it would silently fail to check
# systemd-detect-virt and skip the screensaver launch.
```

**D. `gum choose` flag order.** Force a retry dialog by triggering an
install error scenario, or just eyeball the change:

```bash
grep 'gum choose --header' ~/.local/share/omarchy/install/helpers/errors.sh
# Expect: flags before "${options[@]}".
```

**E. `PADDING_LEFT` clamp.** Simulate a narrow terminal:

```bash
TERM_WIDTH=10 source ~/.local/share/omarchy/install/helpers/presentation.sh
echo "PADDING_LEFT=$PADDING_LEFT"
# Expect 0 (not negative). Before the fix, a negative value broke
# `printf "%*s"`.
```

**F. `run_logged` quoting safety.** Set a variable with a single quote
and confirm no syntax error leaks into the subshell:

```bash
export OMARCHY_USER_NAME="Jon O'Kinney"
source ~/.local/share/omarchy/install/helpers/logging.sh
# Create a dummy script that echoes the var
cat > /tmp/test-run-logged.sh <<'EOF'
echo "Got name: $OMARCHY_USER_NAME"
EOF
OMARCHY_INSTALL_LOG_FILE=/tmp/rl.log run_logged /tmp/test-run-logged.sh
grep "Got name" /tmp/rl.log
# Expect: "Got name: Jon O'Kinney"
# Before the fix the subshell would fail with a syntax error around the
# embedded single quote.
rm /tmp/test-run-logged.sh /tmp/rl.log
```

**G. Log monitor idle loop.** Confirm the loop uses `sleep 0.1` and
syntax-checks cleanly:

```bash
grep -n 'sleep 0.1' ~/.local/share/omarchy/install/helpers/logging.sh
bash -n ~/.local/share/omarchy/install/helpers/logging.sh && echo OK
```

During an actual install, `top` should show the monitor thread idle
between log refreshes (not pegging a CPU core).

---

## Commit 6 — `Fixes from PR #1897 Copilot review: installer + runtime`

### What it fixes
- `sync_log` uninitialized when `OMARCHY_SIMULATE_MIRROR_DOWN` set
- `glib2-devel` (not a real Arch/ALARM package) removed from vmware-tools deps
- `/etc/systemd/user` ensured before vmware-user.service write
- `efibootmgr` guarded with install fallback on minimal ARM
- boot.sh: ARM skips x86_64 omarchy mirror write; ARM mirrorlist failure
  now hard-exits instead of warning
- boot.sh: `curl | bash` for user-setup.sh replaced with download-then-verify
- waybar screen-recording indicator only picks `wf-recorder` if the
  binary is installed

### How to test

**A. `sync_log` unset guard.** Simulate the mirror-down path:

```bash
OMARCHY_ONLINE_INSTALL=true OMARCHY_SIMULATE_MIRROR_DOWN=true \
  bash -c '
    sync_log=""   # intentionally unset-like
    source ~/.local/share/omarchy/install/preflight/pacman.sh
  ' 2>&1 | tail -5
# Expect: the script fails as intended with a "mirrors down" message,
# not with a spurious "rm: missing operand" or similar from the now-
# initialized $sync_log being empty.
```

**B. vmware-tools deps & `/etc/systemd/user`.** On a VMware guest:

```bash
# Dry-check: confirm the bad package name is gone
grep glib2 ~/.local/share/omarchy/install/virtualization/vmware-tools.sh
# Expect: "glib2" but NO "glib2-devel"

# Live test: remove /etc/systemd/user, re-run the script block that
# writes vmware-user.service, verify it succeeds.
sudo rm -rf /etc/systemd/user
source ~/.local/share/omarchy/install/virtualization/vmware-tools.sh
ls /etc/systemd/user/vmware-user.service
```

**C. `efibootmgr` guard.** On a minimal ARM system without efibootmgr:

```bash
# Check that the guard is in place:
grep -n efibootmgr ~/.local/share/omarchy/install/login/limine-arm64.sh
# Expect a `command -v efibootmgr` gate followed by a pacman install.

# Live: uninstall efibootmgr, re-run the script, verify it installs
# it and proceeds.
sudo pacman -R --noconfirm efibootmgr  # (only in a test VM!)
source ~/.local/share/omarchy/install/login/limine-arm64.sh
command -v efibootmgr  # now installed
```

**D. boot.sh mirrorlist logic.** On an ARM install environment:

```bash
# Before running boot.sh, seed a distinct mirrorlist to detect writes:
echo "# test-marker" | sudo tee /etc/pacman.d/mirrorlist
# Run boot.sh in a mode that would hit the branch-selector block.
# Expect: on ARM, the test-marker stays until the ARM mirrorlist
# download succeeds, at which point it's replaced with the real
# mirrorlist. If that download fails, the script exits 1 instead of
# warning and continuing.
```

**E. boot.sh curl|bash replacement.** Point `OMARCHY_REPO` at a
nonexistent repo to force the user-setup.sh download to 404, then
confirm the root branch of boot.sh hard-fails:

```bash
sudo OMARCHY_REPO="jondkinney/nonexistent-repo-xyz" OMARCHY_REF=dev \
  bash ~/.local/share/omarchy/boot.sh
# Expect: "ERROR: Failed to download user-setup.sh ..." and exit 1,
# NOT silent success.
```

**F. waybar indicator respects installed binary.**

```bash
# On x86_64 host without wf-recorder installed:
~/.local/share/omarchy/default/waybar/indicators/screen-recording.sh
# The script is driven by pgrep; we just want to inspect the logic:
bash -x ~/.local/share/omarchy/default/waybar/indicators/screen-recording.sh
# Expect to see: process_name=^gpu-screen-recorder

# Now install wf-recorder (or fake it):
sudo install -m 755 /bin/true /usr/local/bin/wf-recorder
bash -x ~/.local/share/omarchy/default/waybar/indicators/screen-recording.sh
# On aarch64 or in a VM, process_name=wf-recorder.
# On bare-metal x86, process_name=^gpu-screen-recorder regardless.
sudo rm /usr/local/bin/wf-recorder  # cleanup
```

---

## Known Copilot review comments NOT applied

These showed up in the Copilot review but were deliberately skipped.

### `config/environment.d/fcitx.conf` — re-add `QT_IM_MODULE=fcitx`

Copilot asked for `QT_IM_MODULE=fcitx` to be re-added so fcitx input
works in Qt apps. That directly regresses the earlier armarchy commit
`4fd9b3b0 Remove QT_IM_MODULE=fcitx to fix SIGBUS crash on aarch64`.
Keeping the crash-avoidance intact; the Qt IME limitation is known and
accepted on aarch64.

If you want to re-enable Qt IME at the cost of a crash risk on aarch64,
one way to do it conditionally would be via a small systemd generator
that sets the var only when `uname -m != aarch64`. Not in scope here.

### `default/pacman/pacman.conf.arm` — raise `SigLevel` above `Never`

Copilot flagged the `SigLevel = Never` on the asahi-alarm repo as a
supply-chain risk. Agreed in principle, but empirical testing shows
pacman fails against the current asahi-alarm keyring bootstrap when
any stricter setting is used. Leaving as `Never` until the asahi-alarm
repo ships a keyring package that integrates cleanly.

### Stale Copilot comments (code already correct)

- `install/packaging/base.sh` — `packages[@]` claim was on an older
  revision; file already uses `official_packages` and `aur_packages`.
- `install/helpers/common.sh` — `with_yes` already uses a pure-bash
  loop (not `seq`).
- `install/preflight/pacman.sh` — 3 of 4 Copilot items (duplicate
  keyring calls, `-Syyuu` redundancy, `pipewire-jack` ordering) don't
  match the current file; only the `sync_log` init was real.
- `install/virtualization/vmware-tools.sh` — the repo structure DOES
  have a nested `open-vm-tools/` at the top level, so the `cd` after
  clone is correct. Also no `daemon-reexec` in the file (all calls are
  `daemon-reload`).
- `docs/omarchy-aur-install-readme.md` — the example already has a
  closing quote and a space before the package name.

No changes for any of these; noting here so a reviewer doesn't expect
to see commits for them.
