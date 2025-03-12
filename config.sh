#!/bin/bash

CONFIG_FILE="./config.json"

PINFO_COLOR="1;34"
PUPDATE_COLOR="1;32"
PWARNING_COLOR="1;33"
PERROR_COLOR="1;31"
PFATAL_COLOR="1;31"

PINFO_PREFIX="-"
PUPDATE_PREFIX="+"
PWARNING_PREFIX="!"
PERROR_PREFIX="!"
PFATAL_PREFIX="[!]"

pinfo()    { printf "\033[${PINFO_COLOR}m%s\033[0m %s\n" "$PINFO_PREFIX" "$1"; }
pupdate()  { printf "\033[${PUPDATE_COLOR}m%s\033[0m %s\n" "$PUPDATE_PREFIX" "$1"; }
pwarning() { printf "\033[${PWARNING_COLOR}m%s\033[0m %s\n" "$PWARNING_PREFIX" "$1"; }
perror()   { printf "\033[${PERROR_COLOR}m%s\033[0m %s\n" "$PERROR_PREFIX" "$1"; }
pfatal()   { printf "\033[${PFATAL_COLOR}m%s\033[0m %s\n" "$PFATAL_PREFIX" "$1"; }

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

#
# Packages to install specificed in $1
# 
# assumes all pacakges in $1 are not AUR
#
fpacman() {
  [ ! -e $1 ] && {
    pfatal "failed to open package file";
    exit 1;
  }

  sudo pacman -Sy --needed --noconfirm - < $1 1>/dev/null 2>&1 || {
    pfatal "failed to install pacakges in $1";
    exit 1;
  }
}

ensure_required() {
  fpacman requirements.txt
}

ensure_package_manager(){
  if command -v pacman >/dev/null 2>&1; then
    return 0
  fi

  pfatal "missing pacman"
  exit 1
}

ensure_aur_helper() {
  if command -v yay >/dev/null 2>&1; then
    return 0
  fi

  install_yay
}

ensure_config_json() {
  [ ! -e $CONFIG_FILE ] && {
    pfatal "config.json does not exist"
    exit 1
  }
}

init() {
  ensure_package_manager
  sudo pacman -Sy 1>/dev/null

  ensure_required
  ensure_aur_helper
  ensure_config_json
}

usage() {
  echo "Usage: $0 [OPTIONS]"
  echo
  echo "Manages some system configurations."
  echo
  echo "Options:"
  echo "  -h, --help        Show this help message and exit"
}

# pinfo text
# pupdate text
# psuccess text
# pwarning text
# perror text
# pfatal text

main() {
  init

  [ $# -eq 0 ] && {
    usage
    exit 0
  }
}

main
