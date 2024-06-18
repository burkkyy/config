# My default editor
export EDITOR='nvim'

# Add user created scripts to path
[ -d ~/.local/bin ] && export PATH=$PATH:$HOME/.local/bin

# Create new env variable called config that will store the path to userspace config files
[ -d ~/.config ] && export config='~/.config' # & export CONFIG_PATH='~/.config/nyx/config'

# Setting correct config paths, add at your discretion
#export CARGO_HOME='~/.config/cargo'
#export GNUPGHOME='~/.config/gnupg'
#export __GL_SHADER_DISK_CACHE_PATH='~/.config/nv'

