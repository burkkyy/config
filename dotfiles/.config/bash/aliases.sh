# Alias definitions

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

# git aliases
alias gs='git status -s'

# Single letter aliases
alias d='du_color'
alias g='git'
alias l='ls -alh'
alias n='neofetch --config ~/.config/neofetch.conf'
alias p='pacman'
alias r='ranger'
alias t='tree -L 2'
alias v='nvim'

# Accessing config
#alias gitconfig="v ~/.gitconfig"
#alias aliasconfig="v ~/.config/bash/aliases"
# TODO: Make config its own command

# Load in any secert aliases if there may be
[ -f ~/aliases.sh.secert ] && . ~/aliases.sh.secert

