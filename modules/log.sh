#! /usr/bin/env bash

# version       1.0.0
# sourced by    ../load
# task          provides logging functionality

export LIBBASH__LOG_COLOR_RESET='\e[0m'
export LIBBASH__LOG_COLOR_TRACE='\e[92m'
export LIBBASH__LOG_COLOR_DEBUG='\e[36m'
export LIBBASH__LOG_COLOR_INFO='\e[34m'
export LIBBASH__LOG_COLOR_WARN='\e[93m'
export LIBBASH__LOG_COLOR_ERROR='\e[91m'

if [[ ! -v __LIBBASH__IS_LOADED_LOG ]]; then
  export __LIBBASH__IS_LOADED_LOG=1
  readonly __LIBBASH__IS_LOADED_LOG
fi

# ### The Logging Functions
#
# `log` uses five different log levels and behaves as you would
# expect from a log function: you provide the log level as the
# first argument and the message in the consecutive ones. The
# default log level is 'info'. The global log level is defined
# in the 
#
# #### Log Level
#
# The provided log level, as well as the environment variable
# `LOG_LEVEL`, Can be one of
#
#   meaning - what to log
#   -------------------------------------------------
#   trace   - log trace information
#   debug   - log debug information
#   info    - log informational output
#   warn    - log warnings
#   error   - log critical errors and aborts
#
# where a higher level includes the level below. The
# default log level is 'info' (2).
#
# #### Return Codes
#
# This function is infallible. Hence, it always returns with
# return code 0, even when issues appeared.
#
# #### Arguments
#
# $1 :: log level
# $2 :: message (strictly speaking optional, no default / empty string)
function log() {
  function __log_generic() {
    local LOG_LEVEL=${1:?This is a bug in libbash: log level message format must be provided to __log_generic}
    local COLOR="LIBBASH__LOG_COLOR_${LOG_LEVEL^^}"
    shift 1

    # shellcheck disable=SC2059
    printf "%s ${!COLOR}%-5s${LIBBASH__LOG_COLOR_RESET} %s: %s\n" \
      "$(date +"%Y-%m-%dT%H:%M:%S.%6N%:z" || :)" "${LOG_LEVEL^^}" "${SCRIPT:-$(basename "${0}")}" "${*}"
  }

  [[ -z ${1+set} ]] && { log 'warn' "Log called without log level" ; __libbash__show_call_stack ; return 0 ; }
  [[ -z ${2+set} ]] && { log 'warn' "Log called without message" ; __libbash__show_call_stack ; return 0 ; }

  declare -A LOG_LEVEL_MAPPING=(["error"]=0 ["warn"]=1 ["info"]=2 ["debug"]=3 ["trace"]=4)
  local MESSAGE_LOG_LEVEL="${1}"
  shift 1

  if [[ -z ${LOG_LEVEL_MAPPING[${LOG_LEVEL:=info}]} ]]; then
    local OLD_LOG_LEVEL=${LOG_LEVEL}
    export LOG_LEVEL='debug'
    log 'warn' "Log level '${OLD_LOG_LEVEL}' unknown - resetting to log level '${LOG_LEVEL}'"
  fi

  if [[ -z ${LOG_LEVEL_MAPPING[${MESSAGE_LOG_LEVEL}]} ]]; then
    log 'warn' "Provided log level '${MESSAGE_LOG_LEVEL}' unknown"
    __libbash__show_call_stack
    return 0
  fi

  [[ ${LOG_LEVEL_MAPPING[${LOG_LEVEL}]} -lt ${LOG_LEVEL_MAPPING[${MESSAGE_LOG_LEVEL}]} ]] && return 0

  if [[ ${LOG_LEVEL_MAPPING[${MESSAGE_LOG_LEVEL}]} -lt 2 ]]; then
    __log_generic "${MESSAGE_LOG_LEVEL}" "${*}" >&2
  else
    __log_generic "${MESSAGE_LOG_LEVEL}" "${*}"
  fi

  return 0
}
export -f log
