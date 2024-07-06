# Turn off this random display I dont understand why exists 
#
# Laptop config
#
# xrandr --output DP-3 --off
# TODO: Investigate what this display is
# Change xorg-server screen resolution
# xrandr --output eDP-1 --mode 2560x1440

#
# Set the wallpaper
#
# feh --no-fehbg --bg-center '/home/caleb/Pictures/nord.png'

#
# Background processes for dwm
# TODO: Fix / refactor dwmbar_loop
#
dwmbar_loop &
xcompmgr -c & # For transparent windows

exec dwm
