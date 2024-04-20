#! /usr/bin/env bash

# version       0.8.2
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
# `log` is used for logging. It uses five different log levels
#
# `error` | `warn` | `info` | `debug` | `trace`
#
# and behaves as you would expect from a log function: you provide
# the log level as the first argument and the message in the con-
# secutive ones. The default log level is 'info'.
#
# #### Arguments
#
# $1 :: log level
# $2 :: message (strictly speaking optional, no default / empty string)
function log() {
  function __log_generic() {
    local LOG_LEVEL=${1:?Log level message format must be provided to __log_generic}
    local COLOR="LIBBASH__LOG_COLOR_${LOG_LEVEL^^}"
    shift 1

    # shellcheck disable=SC2059
    printf "%s  ${!COLOR}%-5s${LIBBASH__LOG_COLOR_RESET}  %s  ${!COLOR}--${LIBBASH__LOG_COLOR_RESET}  %s\n" \
      "$(date --iso-8601='seconds')" "${LOG_LEVEL^^}" "${SCRIPT:-${0}}" "${*}"
  }

  # Log Level
  #
  # Can be one of
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
  local LOG_LEVEL_AS_INTEGER=2 MESSAGE_LOG_LEVEL="${1:-}"
  shift 1

  case "${LOG_LEVEL:-info}"
  in
    ( 'error' ) LOG_LEVEL_AS_INTEGER=0 ;;
    ( 'warn'  ) LOG_LEVEL_AS_INTEGER=1 ;;
    ( 'info'  ) LOG_LEVEL_AS_INTEGER=2 ;;
    ( 'debug' ) LOG_LEVEL_AS_INTEGER=3 ;;
    ( 'trace' ) LOG_LEVEL_AS_INTEGER=4 ;;
    ( * )
      local OLD_LOG_LEVEL=${LOG_LEVEL}
      LOG_LEVEL='info'
      log 'error' "Log level '${OLD_LOG_LEVEL}' unknown - resetting to default log level ('${LOG_LEVEL}')"
      ;;
  esac

  case "${MESSAGE_LOG_LEVEL}"
  in
    ( 'trace' )
      [[ ${LOG_LEVEL_AS_INTEGER} -lt 4 ]] && return 0
      __log_generic 'trace' "${*}"
      ;;

    ( 'debug' )
      [[ ${LOG_LEVEL_AS_INTEGER} -lt 3 ]] && return 0
      __log_generic 'debug' "${*}"
      ;;

    ( 'info' )
      [[ "${LOG_LEVEL_AS_INTEGER}" -lt 2 ]] && return 0
      __log_generic 'info' "${*}"
      ;;

    ( 'warn' )
      [[ "${LOG_LEVEL_AS_INTEGER}" -lt 1 ]] && return 0
      __log_generic 'warn' "${*}" >&2
      ;;

    ( 'error' )
      __log_generic 'error' "${*}" >&2
      ;;

    ( * )
      log 'error' "Provided log level '${MESSAGE_LOG_LEVEL}' unknown"
      return 0
      ;;
  esac

  return 0
}
export -f log
