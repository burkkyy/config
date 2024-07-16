#!/bin/bash

# Usage:
# source logger.sh
# info "Info log"

# TODO: send certain logs to file

source colors.sh

# log levels
_level_error=1
_level_warning=2
_level_info=3
_level_verbose=4
_level_debug=5
_level_trace=6

# log levels prefixes
_error_prefix="a"
_warning_prefix="b"
_info_prefix="c"
_verbose_prefix="d"
_debug_prefix="e"
_trace_prefix="f"

error(){ _log _level_error $1 false; }
warning(){ _log _level_warning $1 false; }
info(){ _log _level_info $1 false; }
verbose(){ _log _level_verbose $1 false; }
debug(){ _log _level_debug $1 false; }
trace(){ _log _level_trace $1 false; }

# main log func
# Usage:
#   log <log level> <log message> <save to file?>
# NOTE: $3 is not req. Defaults to true
_log(){
  # check params
  local _log_level=$1
  local _log_msg=$2
  local _is_save=$3
  # TODO: validate these params

  # prefix based on log level
  local _prefix
  case $_log_level in
    _level_error)   _prefix="$_error_prefix" ;;
    _level_warning) _prefix="$_warning_prefix" ;;
    _level_info)    _prefix="$_info_prefix" ;;
    _level_verbose) _prefix="$_verbose_prefix" ;;
    _level_debug)   _prefix="$_debug_prefix" ;;
    _level_trace)   _prefix="$_trace_prefix" ;;
    *) _prefix="AAA" ;;
  esac
  
  local _msg="${_prefix} ${_log_msg}"

  echo -e "$_msg"
}

# Testing
error "hello"
warning "hello"
info "hello"
verbose "hello"
debug "hello"
trace "hello"

