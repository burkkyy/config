#!/bin/bash

# Related:
# https://gist.github.com/xvzftube/6efabb66c8525eb6e237759ed4972e9c

WALLPAPER_DIR=~/pictures/wallpapers/

# Let user pick out wallpaper
WALLPAPER=$(sxiv -ftqro "$WALLPAPER_DIR")

[ -n "$WALLPAPER" ] && {
  feh --no-feh --bg-fill "$WALLPAPER"
} || {
  echo "No wallpaper selected. Wallpaper unchanged."
}

