#
# ~/.bashrc
#

# Set the terminal transparency for st
[[ "$(cat /proc/$PPID/comm)" = "st" ]] && transset-df "0.90" --id "$WINDOWID" > /dev/null

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

# Load environment variables
[ -f ~/.config/bash/env.sh ] && . ~/.config/bash/env.sh

# Load bash aliases 
[ -f ~/.config/bash/aliases.sh ] && . ~/.config/bash/aliases.sh

# Load shell key binds
[ -f ~/.config/bash/binds.sh ] && . ~/.config/bash/binds.sh

# Set bash prompt
[ -f ~/.config/bash/prompt.sh ] && PS1="$(~/.config/bash/prompt.sh) " || PS1="[\u@\h \W]\$ "

