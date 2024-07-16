#
# ~/.xinitrc
#

xrandr --output DP-2 --mode 1920x1080 --rate 144.00

dunst &
xcompmgr -n &
dwmbar_loop &
exec dwm

