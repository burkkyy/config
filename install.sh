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
# Yes or no function. Defaulting to no.
# Usage: yon "Enter Prompt" && echo "yes" || echo "no"
#
yon(){
	read -p $'\e[0;35m[?]\e[0m '"$* (y/N): " -e res
	res=${res,,}
	case $res in
		[Yy]*) return 0 ;;
		'' | *) return 1 ;;
	esac
}

install_config(){
  CONFIG_DIR="$HOME/.config"
  [ -d $CONFIG_DIR ] && {
    warning "$CONFIG_DIR already exists!"
    yon "Remove $CONFIG_DIR?" && { 
      warning "Removing $CONFIG_DIR..."
      echo "REMOVE $CONFIG_DIR"
    } || {
      error "Couldn't install config. Aborting."
      exit 1
    }
  }
  echo "INSTALLING CONFIG"
}

install_essential_packages(){
  sudo pacman -S --needed --noconfirm - < package-lists/essentials.txt && {
    success "'essential' package bundle installed."
  } || { 
    error "Some error occurred while installing package-lists/essentials.txt. Aborting."; 
      exit 1; 
  } 
}

install_yay(){
  # TODO: Go path variable needs to be set
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
}

install_nvchad(){
  sudo pacman -S --needed --noconfirm - < package-lists/nvchad-prerequisites.txt
  git clone https://github.com/NvChad/NvChad ~/.config/nvim --depth 1
  success "Installed NvChad, run nvim to finalize."
}

#
# Install suckless software and utilites
#   1. dwm
#   2. st
#   3. dmenu
#
install_suckless(){
  git submodule update --init --recursive
  sudo cp -r .suckless ~/
  sudo make clean install -C ~/.suckless/dwm
  sudo make clean install -C ~/.suckless/st
  sudo make clean install -C ~/.suckless/dmenu
}

# Ensure root
# [ $(id -u) -ne 0 ] && { error "Please run as root"; exit 1; }

#
# Update current system
#
info "Updating system..."
sudo pacman -Syyuu --noconfirm || { error "Couldn't update system. Aborting."; exit 1; }
success "Updated system."

#
# Install my personal config
#
yon "Install config for '$USER'?" && { 
  install_config 
} || { 
  error "Couldn't install config. Aborting."
  exit 1
}

#
# Install helpful software
#
update "Packages in 'essential':"
cat package-lists/essentials.txt
yon "Install 'essential' packages?" && install_essential_packages
yon "(TODO) Install 'yay' as AUR package manager?" && install_yay  # Arch AUR helper
yon "(TODO) Install NvChad as text editor?" && install_nvchad  # Favorite text editor
yon "(TODO) Install suckless software?" && install_suckless

# Reset sudo auth timestamp
#which sudo >/dev/null 2>&1
#[ $? -eq 0 ] && sudo -k
