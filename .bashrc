#
# ~/.bashrc
#

# Set the terminal transparency for st
[[ "$(cat /proc/$PPID/comm)" = "st" ]] && transset-df "0.80" --id "$WINDOWID" > /dev/null

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

# Load in env variables
[ -f ~/.config/bash/env ] && . ~/.config/bash/env

# Load in aliases 
[ -f ~/.config/bash/aliases ] && . ~/.config/bash/aliases

# Sets bash prompt
[ -f ~/.config/bash/prompt ] && PS1="$(~/.config/bash/prompt) " || PS1="[\u@\h \W]\$ "

