#!/usr/bin/env bash

function run {
  if ! pgrep -f "$1" >/dev/null ;
  then
    shift
    "$@" &
  fi
}

run picom picom -b
run nm-applet nm-applet --no-agent
run Telegram Telegram
run zen-browser zen-browser
autorandr --change --default default &
# blank the screen but never power the output off: DPMS power-off makes the
# amdgpu driver emit a spurious HOTPLUG uevent, X drops the output and the
# autorandr udev hook fires while the monitor's EDID is unreadable
xset s 600 -dpms
run xmbwave xmbwave
