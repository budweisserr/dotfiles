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

# xsecurelock + xss-lock autolock
run xss-lock xss-lock -n /usr/lib/xsecurelock/dimmer -l -- env XSECURELOCK_SAVER=saver_xscreensaver xsecurelock
