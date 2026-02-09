#
# ~/.xinitrc
#

xrandr --output DP-2 --auto --mode 1920x1080 --rate 144.00
xrandr --output HDMI-0 --auto --mode 1920x1080 --rate 100.00 --right-of DP-2

xrdb -load ~/.Xresources
xmodmap ~/.Xmodmap

# feh --no-feh --bg-fill /home/caleb/pictures/wallpapers/85942af486eb79118467/low-poly-texture-19.png

dunst &
xcompmgr -n &
dwmbar_loop &
exec dwm
