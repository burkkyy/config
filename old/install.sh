#!/bin/bash

install_nvchad(){
  install_bundle nvchad
  
  #
  # Check if nvchad is already installed
  # 
  [ -e ~/.config/nvim/lua ] && {
    info "NvChad already installed. Skipping."
    return
  }

  #
  # Remove old config
  #
  rm -rf ~/.config/nvim
  rm -rf ~/.local/state/nvim
  rm -rf ~/.local/share/nvim
  
  git clone https://github.com/NvChad/starter ~/.config/nvim --depth 1
  success "Installed NvChad, run nvim to finalize."
}

#
# Attempts to copy a dot file to dest
# $1 (string) - File to copy
# $2 (string) - Dest to copy to
#
install_dotfile(){
  COPY_PATH="$1"
  DEST_PATH="$2"

  [ -e $DEST_PATH ] && {
    warning "$DEST_PATH already exists!"
    yoN "Remove $DEST_PATH?" && { 
      rm -rf $DEST_PATH && {
        warning "Removed $DEST_PATH"
      } || {
        error "Failed to remove $DEST_PATH"
        return 1
      }
    } || {
      return 1
    }
  }

  cp -r $COPY_PATH $DEST_PATH && {
    success "Copied $COPY_PATH to $DEST_PATH"
  } || {
    error "Copying $COPY_PATH to $DEST_PATH failed."
  }
}

# Ensure root
# [ $(id -u) -ne 0 ] && { error "Please run as root"; exit 1; }

#
# Update system and setup config install env
#
step_1_update_system(){
  git submodule update --init --recursive
  info "Updating system..."
  sudo pacman -Syyuu --noconfirm || {
    error "Couldn't update system. Aborting.";
    exit 1; 
  }
  success "Updated system."
}

#
# Install config
#
step_2_install_config(){
  CONFIG_PATH="$PWD/dotfiles/.config"
  
  #find $CONFIG_PATH -maxdepth 1 -mindepth 1 | while read -r config; do
  #  config="${config##*/}"
  #  update "Installing $config..."
  #  install_dotfile "$CONFIG_PATH/$config" "$HOME/.config/$config"
  #done

  for config in $CONFIG_PATH/* $CONFIG_PATH/.*; do
    config="${config##*/}"
    update "Installing $config..."
    install_dotfile "$CONFIG_PATH/$config" "$HOME/.config/$config"
  done

  #install_dotfile "$PWD/dotfiles/.config" "$HOME/.config" || {
   # warning "Failed to install config!"
  #}
}

#
# Install suckless software
#
step_7_install_suckless(){
  SUCKLESS_PATH="$PWD/suckless"
  install_aur_bundle suckless false true
  
  yoN "Build suckless software?" && {
    
    update "Building 'st'..."
    sudo make clean install -C $SUCKLESS_PATH/st
    success "Finished building 'st'."

    update "Building 'dwm'..."
    sudo make clean install -C $SUCKLESS_PATH/dwm
    success "Finished building 'dwm'."
    
    update "Building 'dmenu'..."
    sudo make clean install -C $SUCKLESS_PATH/dmenu
    success "Finished building 'dmenu'."
 }
}

#
# Install user scripts
#
step_8_install_user_scripts(){
  USER_SCRIPTS="$PWD/dotfiles/.local/bin"
  INSTALL_PATH="$HOME/.local/bin"
  mkdir -p "$INSTALL_PATH"
  cp "$USER_SCRIPTS"/* "$INSTALL_PATH"
  success "Installed user scripts."
}

#
# Install replace .bashrc
#
step_9_install_bashrc(){
  install_dotfile "$PWD/dotfiles/.bashrc" "$HOME/.bashrc"
}

#
# Install replace .xinitrc
#
step_10_install_xinitrc(){
  install_dotfile "$PWD/dotfiles/.xinitrc" "$HOME/.xinitrc"
}

#
# Install user local share
#
step_11_install_local_share(){
  USER_SHARE="$PWD/dotfiles/.local/share"
  INSTALL_PATH="$HOME/.local/share"
  mkdir -p "$INSTALL_PATH"
  cp "$USER_SHARE"/* "$INSTALL_PATH"
  success "Installed user scripts."
}

install_bash(){
  step_5_install_useful
  step_9_install_bashrc
  step_8_install_user_scripts
  step_2_install_config
}

# Reset sudo auth timestamp
#which sudo >/dev/null 2>&1
#[ $? -eq 0 ] && sudo -k
