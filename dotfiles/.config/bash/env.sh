# My default editor
export EDITOR='nvim'

# Add user created scripts to path
[ -d ~/.local/bin ] && export PATH=$PATH:$HOME/.local/bin

[ ! -d ~/.config ] && {
  echo "Error ~/.config does no exist. Creating."
  mkdir ~/.config
}

export config="$HOME/.config"
export CONFIG="$HOME/.config"

export CARGO_HOME="$CONFIG/cargo"
export GNUPGHOME="$CONFIG/gnupg"
export __GL_SHADER_DISK_CACHE_PATH="$CONFIG/nv"

export ASDF_DIR="$CONFIG/.asdf"
. "$ASDF_DIR/asdf.sh"
. "$ASDF_DIR/completions/asdf.bash"
