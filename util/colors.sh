#!/bin/bash

# Usage:
# source colors.sh
# echo -e "Hello! ${red}red!${color_off} Not red anymore."

# https://stackoverflow.com/questions/5947742/how-to-change-the-output-color-of-echo-in-linux

# reset
color_off='\033[0m'       # text reset

# regular colors
black='\033[0;30m'        # black
red='\033[0;31m'          # red
green='\033[0;32m'        # green
yellow='\033[0;33m'       # yellow
blue='\033[0;34m'         # blue
purple='\033[0;35m'       # purple
cyan='\033[0;36m'         # cyan
white='\033[0;37m'        # white

# bold
bblack='\033[1;30m'       # black
bred='\033[1;31m'         # red
bgreen='\033[1;32m'       # green
byellow='\033[1;33m'      # yellow
bblue='\033[1;34m'        # blue
bpurple='\033[1;35m'      # purple
bcyan='\033[1;36m'        # cyan
bwhite='\033[1;37m'       # white

# underline
ublack='\033[4;30m'       # black
ured='\033[4;31m'         # red
ugreen='\033[4;32m'       # green
uyellow='\033[4;33m'      # yellow
ublue='\033[4;34m'        # blue
upurple='\033[4;35m'      # purple
ucyan='\033[4;36m'        # cyan
uwhite='\033[4;37m'       # white

# background
on_black='\033[40m'       # black
on_red='\033[41m'         # red
on_green='\033[42m'       # green
on_yellow='\033[43m'      # yellow
on_blue='\033[44m'        # blue
on_purple='\033[45m'      # purple
on_cyan='\033[46m'        # cyan
on_white='\033[47m'       # white

# high intensity
iblack='\033[0;90m'       # black
ired='\033[0;91m'         # red
igreen='\033[0;92m'       # green
iyellow='\033[0;93m'      # yellow
iblue='\033[0;94m'        # blue
ipurple='\033[0;95m'      # purple
icyan='\033[0;96m'        # cyan
iwhite='\033[0;97m'       # white

# bold high intensity
biblack='\033[1;90m'      # black
bired='\033[1;91m'        # red
bigreen='\033[1;92m'      # green
biyellow='\033[1;93m'     # yellow
biblue='\033[1;94m'       # blue
bipurple='\033[1;95m'     # purple
bicyan='\033[1;96m'       # cyan
biwhite='\033[1;97m'      # white

# high intensity backgrounds
on_iblack='\033[0;100m'   # black
on_ired='\033[0;101m'     # red
on_igreen='\033[0;102m'   # green
on_iyellow='\033[0;103m'  # yellow
on_iblue='\033[0;104m'    # blue
on_ipurple='\033[0;105m'  # purple
on_icyan='\033[0;106m'    # cyan
on_iwhite='\033[0;107m'   # white
