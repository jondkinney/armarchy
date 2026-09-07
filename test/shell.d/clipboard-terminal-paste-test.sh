#!/bin/bash

set -euo pipefail
source "$(dirname -- "${BASH_SOURCE[0]}")/base-test.sh"
require_command lua

TMPDIR=$(mktemp -d)
trap 'rm -rf "$TMPDIR"' EXIT
mkdir "$TMPDIR/bin"
export PASTE_TEST_DIR="$TMPDIR"

cat > "$TMPDIR/bin/wl-paste" <<'STUB'
#!/bin/bash
[[ $* == "--list-types" ]] || exit 2
printf '%s\n' "${PASTE_TYPES:-}"
exit "${PASTE_STATUS:-0}"
STUB
cat > "$TMPDIR/bin/hyprctl" <<'STUB'
#!/bin/bash
[[ $1 == "eval" ]] || exit 2
printf '%s\n' "$2" > "$PASTE_TEST_DIR/dispatch.lua"
STUB
chmod +x "$TMPDIR/bin/"*

cat > "$TMPDIR/check.lua" <<'LUA'
local events = {}
hl = {
  get_active_window = function()
    if arg[3] ~= "none" then return { address = arg[3] or "0x123" } end
  end,
  dsp = { send_key_state = function(event) return event end },
  dispatch = function(event) table.insert(events, event) end,
  timer = function(callback, options)
    assert(options.timeout == 50 and options.type == "oneshot")
    callback()
  end,
}
dofile(os.getenv("PASTE_TEST_DIR") .. "/dispatch.lua")
if arg[3] then
  assert(#events == 0, "focus change must cancel paste")
else
  assert(#events == 2)
  for i, state in ipairs({ "down", "up" }) do
    assert(events[i].mods == arg[1] and events[i].key == arg[2] and events[i].state == state)
  end
end
LUA

check_paste() {
  local types=$1 mods=$2 key=$3
  PASTE_TYPES="$types" PATH="$TMPDIR/bin:$PATH" "$ROOT/bin/omarchy-clipboard-paste-terminal" 0x123
  lua "$TMPDIR/check.lua" "$mods" "$key"
}

check_paste 'text/plain;charset=utf-8' SHIFT Insert
pass "terminal text paste sends Shift+Insert down and up"
for types in 'image/png' 'image/jpeg' $'text/html\nimage/png\ntext/plain'; do
  check_paste "$types" CTRL V
done
pass "image offers, including mixed text and image, send Ctrl+V"
check_paste '' SHIFT Insert
check_paste 'application/x-image/png' SHIFT Insert
PASTE_STATUS=1 check_paste 'image/png' SHIFT Insert
pass "empty, non-image and failed offers fall back to terminal text paste"
lua "$TMPDIR/check.lua" SHIFT Insert 0x456
lua "$TMPDIR/check.lua" SHIFT Insert none
pass "changed or missing focus cancels paste"
if PATH="$TMPDIR/bin:$PATH" "$ROOT/bin/omarchy-clipboard-paste-terminal" "bad-address"; then
  fail "invalid window addresses are rejected"
fi
pass "invalid window addresses are rejected"

lua - <<'LUA'
local binds, events, commands = {}, {}, {}
local window
hl = {
  get_active_window = function() return window end,
  exec_cmd = function(cmd) table.insert(commands, cmd) end,
  dsp = { send_key_state = function(event) return event end },
  dispatch = function(event) table.insert(events, event) end,
  timer = function(callback) callback() end,
}
o = {
  bind = function(chord, description, callback) binds[chord] = callback end,
  shell_quote = function(value) return "'" .. value .. "'" end,
}
dofile(os.getenv("ROOT") .. "/default/hypr/bindings/clipboard.lua")
for _, tag in ipairs({ "terminal", "terminal*" }) do
  window = { address = "0x123", tags = { tag } }
  binds["SUPER + V"]()
  assert(commands[#commands] == "omarchy-clipboard-paste-terminal '0x123'")
  assert(#events == 0, "terminal paste must query asynchronously")
end
for _, target in ipairs({ false, { tags = {} } }) do
  window = target or nil
  events = {}
  binds["SUPER + V"]()
  assert(#events == 2 and events[1].mods == "CTRL" and events[1].key == "V")
end
window = { tags = { "terminal*" } }
events = {}
binds["SUPER + C"]()
assert(events[1].mods == "CTRL" and events[1].key == "Insert")
LUA
pass "bindings route terminal paste asynchronously and preserve GUI paste and terminal copy"
