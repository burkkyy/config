#!/bin/bash

<<comment
@file install.sh
@author Caleb Burke
@date Feb 19th, 2024
comment

#
# Handy pretty printing functions.
#
info(){ echo -e "\e[1;34m[-]\e[0m $1"; }
update(){ echo -e "\e[0;32m[*]\e[0m $1"; }
success(){ echo -e "\e[1;32m[+]\e[0m $1"; }
warning(){ echo -e "\e[1;33m[!]\e[0m $1"; }
error(){ echo -e "\e[1;31m[!]\e[0m $1"; }

# info "info"
# update "update"
# success "succ"
# warning "warn"
# error "err"

#
# Yes or no function. Defaulting to yes.
# Usage: yon "Enter Prompt" && echo "yes" || echo "no"
#
Yon(){
  read -p $'\e[0;35m[?]\e[0m '"$* (Y/n): " -e res
  res=${res,,}
  case $res in
    [Nn]*) return 1 ;;
    '' | *) return 0 ;;
  esac
}

#
# Yes or no function. 
# NOTE: Defaulting to no.
# Usage: yon "Enter Prompt" && echo "yes" || echo "no"
#
yoN(){
  read -p $'\e[0;35m[?]\e[0m '"$* (y/N): " -e res
  res=${res,,}
  case $res in
    [Yy]*) return 0 ;;
    '' | *) return 1 ;;
  esac
}

# Installs packges based on a txt list in packages-lists/
# Usage: 
# To install packages from packages-lists/dev.txt:
# install_bundle dev true
# $1 (string) - bundle name
# $2 (boolean) - If print out packages to install
install_bundle(){
  BUNDLE_NAME=$1
  BUNDLE_PATH="package-lists/$1.txt"

  [ "$2" == "true" ] && {
    info "Packages in '$BUNDLE_NAME':";
    cat $BUNDLE_PATH;
  }

  sudo pacman -S --needed --noconfirm - < $BUNDLE_PATH && {
    success "'$BUNDLE_NAME' package bundle installed.";
  } || {
    error "Some error occurred while installing $BUNDLE_NAME. Aborting."; 
    exit 1;
  }
}

#
# Installs packges based on a txt list in packages-lists/
# Usage: 
# To install packages from packages-lists/dev.txt:
# install_bundle dev true
# $1 (string) - bundle name
# $2 (boolean) - If print out packages to install
install_aur_bundle(){
  BUNDLE_NAME=$1
  BUNDLE_PATH="package-lists/$1.aur.txt"
  
  which yay 1>/dev/null 2>&1
  [ $? -ne 0 ] && {
    error "'yay' required to install packages from AUR. Aborting.";
    exit 1;
  }

  [ "$2" == "true" ] && {
    info "Packages in '$BUNDLE_NAME':";
    cat $BUNDLE_PATH;
  }

  yay -S --needed --noconfirm - < $BUNDLE_PATH && {
    success "'$BUNDLE_NAME' package bundle installed.";
  } || { 
    error "Some error occurred while installing $BUNDLE_NAME. Aborting."; 
    exit 1;
  }
}

install_yay(){
  # Check if yay is already built
  which yay 1>/dev/null 2>&1
  [ $? -eq 0 ] && {
    info "yay is already installed. Return..."
    return
  }

  WORK_DIR=$(pwd)
  
  sudo pacman -S --needed --noconfirm git base-devel # yay dependencies
  TMP_YAY_BUILD_DIR=$(mktemp -d)
  git clone https://aur.archlinux.org/yay.git "$TMP_YAY_BUILD_DIR/yay"
  
  update "Moving out of $WORK_DIR, into $TMP_YAY_BUILD_DIR/yay..."
  cd "$TMP_YAY_BUILD_DIR/yay"
  
  update "Building yay..."
  makepkg -si
  
  update "Returning to $WORK_DIR"
  cd "$WORK_DIR"

  update "Removing $TMP_YAY_BUILD_DIR"
  rm -rf $TMP_YAY_BUILD_DIR
}

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
# Install essential bundle
#
step_3_install_essential(){
  install_bundle essentials true
}

#
# Install yay (Arch AUR helper)
#
step_4_install_yay(){
  # Check if yay is already installed
  which yay 1>/dev/null 2>&1
  [ $? -eq 0 ] && {
    info "'yay' is already installed. Skipping."
  } || {
    yoN "Install 'yay' as AUR package manager?" && install_yay
  }
}

#
# Install usefull bundle
#
step_5_install_useful(){
  install_aur_bundle useful true
}

#
# Install nvchad test editor (Favorite text editor)
#
step_6_install_nvchad(){
  install_nvchad
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

step_all(){
  step_1_update_system
  step_2_install_config
  step_3_install_essential
  step_4_install_yay
  step_5_install_useful
  step_6_install_nvchad
  step_7_install_suckless
  step_8_install_user_scripts
  step_9_install_bachrc
  step_10_install_xinitrc
  step_11_install_local_share
}

show_help() {
    echo "Usage: $0 [OPTIONS]"
    echo
    echo "Install dotfiles and configurations."
    echo
    echo "Options:"
    echo "  config            Install general configuration files"
    echo "  essential         Install packages from package-lists/essential.txt"
    echo "  yay               Builds and installs yay AUR helper"
    echo "  useful            Install packages from package-lists/useful.aur.txt"
    echo "  nvchad            Install nvchad text editor"
    echo "  suckless          Builds and installs suckless software"
    echo "  scripts           Copies user scripts from dotfiles/.local/bin to ~/.local/bin"
    echo "  bash              Install user scripts for bash and replaces ~/.bashrc with dotfiles/.bashrc"
    echo "  xinitrc           Replaces ~/.xinitrc with dotfiles/.xinitrc"
    echo "  all               Install all above"
    echo "  local             Install stuff for .local "
    echo "  soft              Runs a soft install. Essential, yay, useful, scripts, bashrc, xinitrc."
    echo "  -h, --help        Show this help message and exit"
}

main() {
  [ $# -eq 0 ] && {
    error "No arguments provided."
    show_help
    exit 0
  }

  for arg in "$@"; do
    case "$arg" in
      config)
        step_2_install_config
      ;;
      essential)
	      step_3_install_essential
      ;;
      yay)
	      step_4_install_yay
      ;;
      useful)
	      step_5_install_useful
      ;;
      nvchad)
	      step_6_install_nvchad
      ;;
      suckless)
	      step_7_install_suckless
      ;;
      scripts)
	      step_8_install_user_scripts
      ;;
      bash)
	      install_bash
      ;;
      xinitrc)
	      step_10_install_xinitrc
      ;;
      local)
        step_8_install_user_scripts
        step_11_install_local_share
      ;;
      all)
	      step_all
      ;;
      soft)
	      step_1_update_system
	      step_2_install_config
	      step_3_install_essential
	      step_4_install_yay
	      step_8_install_user_scripts
	      step_9_install_bashrc
	      step_10_install_xinitrc
      ;;
      -h|--help)
        show_help
	      exit 0
      ;;
      *)
        error "Unknown argument: $arg"
	      show_help
	      exit 1
      ;;
    esac
  done
}

main "$@"

# Reset sudo auth timestamp
#which sudo >/dev/null 2>&1
#[ $? -eq 0 ] && sudo -k
