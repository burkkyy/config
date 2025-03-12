#!/bin/bash

CONFIG_FILE="~/config/config.json"

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

ensure_config_json() {
  [ ! -e $CONFIG_FILE ] && {
    pfatal "config.json does not exist"
    exit 1
  }
}

init() {
  ensure_package_manager
  fpacman requirements.txt
  ensure_aur_helper
  ensure_config_json
}

usage() {
  echo "Usage: $0 [OPTIONS]"
  echo
  echo "Manages some system configurations."
  echo
  echo "Options:"
  echo "  init              initializes config"
  echo "  -h, --help        Shows this help message and exit"
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

  for arg in "$@"; do
    case "$arg" in
      -h|--help)
        usage
        exit 0
      ;;
      *)
        perror "Unknown argument: $arg"
        usage
        exit 1
      ;;
    esac
  done
}

main "$@"
