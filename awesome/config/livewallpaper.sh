#!/bin/bash
VIDEO="$HOME/.config/awesome/wallpapers/foggy-red-sky.mp4"
pkill xwinwrap
xwinwrap -fs -fdt -ni -b -nf -ov -- mpv --wid=%WID --no-audio --loop=inf --no-osc --no-osd-bar --no-input-default-bindings --hwdec=auto --profile=gpu-hq "$VIDEO"
