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

  [ $2 = true ] && {
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

  [ $2 = true ] && {
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
  sudo pacman -S --needed --noconfirm - < package-lists/nvchad-prerequisites.txt
  git clone https://github.com/NvChad/NvChad ~/.config/nvim --depth 1
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
step_1(){
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
step_2(){
  install_dotfile "$PWD/dotfiles/.config" "$HOME/.config" || {
    warning "Failed to install config!"
  }
}

#
# Install essential bundle
#
step_3(){
  install_bundle essentials true
}

#
# Install yay (Arch AUR helper)
#
step_4(){
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
step_5(){
  install_aur_bundle useful true
}

#
# Install nvchad test editor (Favorite text editor)
#
step_6(){
  yoN "(TODO) Install NvChad as text editor?" && {
    ls
    #install_bundle nvchad false true
    # clone my nvchad repo
    # git clone https://github.com/NvChad/NvChad ~/.config/nvim --depth 1
    #success "Installed NvChad. Run nvim to finalize."
  }
}

#
# Install suckless software
#
step_7(){
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
step_8(){
  USER_SCRIPTS="$PWD/dotfiles/.local/bin"
  INSTALL_PATH="$HOME/.local/bin"
  mkdir -p "$INSTALL_PATH"
  cp "$USER_SCRIPTS"/* "$INSTALL_PATH"
  success "Installed user scripts."
}

#
# Install replace .bashrc
#
step_9(){
  install_dotfile "$PWD/dotfiles/.bashrc" "$HOME/.bashrc"
}

#
# Install replace .bashrc
#
step_10(){
  install_dotfile "$PWD/dotfiles/.xinitrc" "$HOME/.xinitrc"
}

step_1
step_2
step_3
step_4
step_5
#step_6
step_7
step_8
step_9
step_10

success "Install config complete."

# Reset sudo auth timestamp
#which sudo >/dev/null 2>&1
#[ $? -eq 0 ] && sudo -k
