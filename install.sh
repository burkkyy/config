#!/bin/bash

<<comment
@file install.sh
@author Caleb Burke
@date Feb 19th, 2024
comment

# Prints info message
# Usage:
# info "message"
info(){ echo -e "\e[1;34m[-]\e[0m $1"; }

# Prints update message
# Usage:
# update "message"
update(){ echo -e "\e[1;32m[*]\e[0m $1"; }

# Prints error message
# Usage:
# error "message"
error(){ echo -e "\e[1;31m[!]\e[0m $1"; }

# Prints error message
# Usage:
# success "message"
success(){ echo -e "\e[1;32m[+]\e[0m $1"; }

# Yes or no function
# Usage:
# yon "Enter Prompt" {
#   echo "This runs if yes"
# }
yon(){
	read -p $'::: '"$* (Y/n): " -e res
	res=${res,,}
	case $res in
		'' | [Yy]*) return 0 ;;
		*) return 1 ;;
	esac
}

# Ensure root
# [ $(id -u) -ne 0 ] && { error "Please run as root"; exit 1; }

info "Updating system."
sudo pacman -Syyuu || error "Couldn't update system."
update "Updated system."

yon "Replace ~/.config?" && {
    exit
}

# Following
yon "Install some of caleb's essential software?" && {
sudo pacman -S git neovim

git submodule update --init --recursive

yon "Install NvChad?" && {
    git clone https://github.com/NvChad/NvChad ~/.config/nvim --depth 1
    update "Installed NvChad config, run nvim to finalize."
}

# See https://github.com/burkkyy/Workshop/blob/main/library/arch/useful_programs.md
sudo pacman -S vlc
sudo pacman -S filezilla
sudo pacman -S wireguard-tools

yon "Install suckless software?" && {
    sudo cp -r .suckless ~/
    sudo make clean install -C ~/.suckless/dwm
    sudo make clean install -C ~/.suckless/st
    sudo make clean install -C ~/.suckless/dmenu
}

}

# Reset sudo auth timestamp
which sudo >/dev/null 2>&1
[ $? -eq 0 ] && sudo -k

