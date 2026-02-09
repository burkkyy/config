# Alias definitions

# helper funcs
_git(){
  [ $# -eq 0 ] && {
    git status && git branch
  } || {
    git "$@"
  }
}

# Default aliases
alias ls='ls --color=auto'
alias grep='grep --color=auto'
#alias nyx='nyx -c ~/.config/nyx/config/'

# Ease of use aliases
alias '..'='cd ../'
alias '...'='cd ../..'
alias google='google-chrome-stable'

# special aliases
alias 'ff'='nvim $(fzf)'
alias ts='date +%Y%m%d%H%M%S'

# git aliases
alias gs='git status'
alias ga='git add'

# Single letter aliases
alias d='du_color'
alias g=_git
alias l='ls -alh'
alias n='neofetch --config ~/.config/neofetch.conf'
alias p='pacman'
alias r='ranger'
alias t='tmux'
alias v='nvim'

# Load in any secret aliases if there may be
[ -f ~/aliases.sh.secret ] && . ~/aliases.sh.secret
