#
# ~/.xinitrc
#

# Turn off this random display I dont understand why exists 
# xrandr --output DP-3 --off # TODO: Investigate what this display is
# xrandr --output eDP-1 --mode 2560x1440

# feh --no-fehbg --bg-center '/home/caleb/Pictures/nord.png'

xrandr --output DP-2 --mode 1920x1080 --rate 144.00

# TODO: Fix / refactor dwmbar_loop
dwmbar_loop &

# xcompmgr -c & # For transparent windows

exec dwm
