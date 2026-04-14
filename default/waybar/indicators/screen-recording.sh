#!/bin/bash

get_recorder_process_name() {
  # wf-recorder is currently only packaged for ARM in the omarchy package
  # lists. Selecting it on x86_64 VMs (the old condition did) means the
  # indicator never lights up and omarchy-cmd-screenrecord wouldn't work
  # either, since the binary isn't there. Only return wf-recorder when it
  # actually exists; otherwise fall back to gpu-screen-recorder.
  if command -v wf-recorder &>/dev/null && \
     { [[ "$(uname -m)" == "aarch64" ]] || systemd-detect-virt -q; }; then
    echo "wf-recorder"
  else
    echo "^gpu-screen-recorder"
  fi
}

process_name=$(get_recorder_process_name)

if pgrep -f "$process_name" >/dev/null; then
  echo '{"text": "󰻂", "tooltip": "Stop recording", "class": "active"}'
else
  echo '{"text": ""}'
fi
