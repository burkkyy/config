#!/bin/bash

CONFIG_REPO_DIR=~/config
CONFIG_JSON_FILE=~/config/config.json
CONFIG_FILE=~/config/config.sh
CONFIG_TARGET_FILE=~/.local/bin/config

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
  [ ! -e $CONFIG_JSON_FILE ] && {
    pfatal "$CONFIG_JSON_FILE does not exist"
    exit 1
  }
}

sync_repo() {
  if [ -d "$CONFIG_REPO_DIR/.git" ]; then
      cd "$CONFIG_REPO_DIR" || pfatal "Failed to change to $CONFIG_REPO_DIR"
      git pull origin main 1>/dev/null 2>&1 || pwarning "Failed to pull latest changes (continuing anyway)"
      cd - >/dev/null || pfatal "Failed to return from $CONFIG_REPO_DIR"
      pupdate "synced git repo"
  else
      pwarning "$CONFIG_REPO_DIR is not a Git repository; skipping pull"
  fi
}

sync_config_script() {
  mkdir -p ~/.local/bin

  [ ! -e "$CONFIG_TARGET_FILE" ] && {
    pwarning "created symbolic link $CONFIG_FILE to $CONFIG_TARGET_FILE"
    ln -s "$CONFIG_FILE" "$CONFIG_TARGET_FILE" || {
      pfatal "failed to make symbolic link $CONFIG_FILE to $CONFIG_TARGET_FILE"
      exit 1;
    }
  }

  pupdate "synced config script"
}

init() {
  ensure_package_manager
  fpacman requirements.txt
  ensure_aur_helper
  ensure_config_json
  sync

  pinfo "init complete"
  pinfo "You dont have to run this command again, instead use 'config sync'"
}

sync() {
  [ ! -d "$CONFIG_REPO_DIR" ] && pfatal "$CONFIG_REPO_DIR does not exist"
  [ ! -f "$CONFIG_FILE" ] && pfatal "$CONFIG_FILE not found in $CONFIG_REPO_DIR"

  sync_repo
  sync_config_script
}

install_package_group() {
  [ -z "$1" ] && {
    pfatal "No package group specified";
    exit 1;
  }

  if ! jq -e --arg g "$1" '.["known-package-groups"] | index($g)' "$CONFIG_JSON_FILE" >/dev/null; then
    pfatal "Unknown package group: $1"
    exit 1
  fi

  jq -r --arg g "$1" '.["package-groups"][$g][]' "$CONFIG_JSON_FILE" | yay -Sy --needed --noconfirm - || {
    pfatal "failed to install package group";
    exit 1;
  };

  pupdate "installed package group '$1'"
}

packages_command() {
  [ -z "$1" ] && {
    pinfo "list of package groups:";
    jq -r '."known-package-groups"' "$CONFIG_JSON_FILE";
    return 0;
  }

  install_package_group "$1"
}

usage() {
  echo "Usage: $0 [OPTIONS]"
  echo
  echo "Manages some system configurations."
  echo
  echo "Options:"
  echo "  init              Run this once to install this config, then use sync"
  echo "  sync              Syncs config data in $CONFIG_REPO_DIR to rest of system"
  echo "  packages <group>  Installs packages in a group from $CONFIG_JSON_FILE"
  echo "  -h, --help        Shows this help message and exit"
}

# pinfo text
# pupdate text
# psuccess text
# pwarning text
# perror text
# pfatal text

main() {
  [ $# -eq 0 ] && {
    usage
    exit 0
  }

  for arg in "$@"; do
    case "$arg" in
      init)
        init
        exit 0
      ;;
      sync)
        sync
        exit 0
      ;;
      packages)
        shift
        packages_command "$1"
        exit 0
      ;;
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
