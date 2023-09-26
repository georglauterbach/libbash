#! /usr/bin/env bash

# version       0.7.0
# sourced by    ../load
# task          provides logging functionality

LIBBASH__LOG_COLOR_RESET='\e[0m'
LIBBASH__LOG_COLOR_TRA='\e[92m'
LIBBASH__LOG_COLOR_DEB='\e[36m'
LIBBASH__LOG_COLOR_INF='\e[34m'
LIBBASH__LOG_COLOR_WAR='\e[93m'
LIBBASH__LOG_COLOR_ERR='\e[91m'

if [[ -z ${__LIBBASH_IS_LOADED_LOG+set} ]]
then
  export __LIBBASH_IS_LOADED_LOG=true
  readonly __LIBBASH_IS_LOADED_LOG
fi

# ### The Logging Functions
#
# `log` is used for logging. It uses five different log levels
#
# `err` | `war` | `inf` | `deb` | `tra`
#
# and behaves as you would expect from a log function: you provide
# the log level as the first argument and the message in the con-
# secutive ones. The default log level is 'inf'.
#
# #### Arguments
#
# $1 :: log level
# $2 :: message (strictly speaking optional, no default / empty string)
function log() {
  function __log_generic() {
    local LOG_LEVEL_ABBREVIATION=${1:?Log level abbreviation must be provided to __log_generic}
    local LOG_LEVEL=${2:?Log level message format must be provided to __log_generic}
    shift 2

    local COLOR="LIBBASH__LOG_COLOR_${LOG_LEVEL_ABBREVIATION^^}"
    local LOG_STRING="${LIBBASH__LOG_COLOR_RESET}[  ${!COLOR}"
    LOG_STRING+="${LOG_LEVEL}${LIBBASH__LOG_COLOR_RESET}  ]"
    LOG_STRING+=" %30s | ${!COLOR}%s${LIBBASH__LOG_COLOR_RESET}\n"

    # shellcheck disable=SC2059
    printf "${LOG_STRING}" "${SCRIPT:-${0}}" "${*}"
  }

  # Log Level
  #
  # Can be one of
  #
  #   value => meaning - what to log
  #   -------------------------------------------------
  #   tra   => trace   - log trace information
  #   deb   => debug   - log debug information
  #   inf   => info    - log informational output
  #   war   => warning - log warnings
  #   err   => error   - log critical errors and aborts
  #
  # where a higher level includes the level below. The
  # default log level is 'inf' (2).
  local LOG_LEVEL_AS_INTEGER=2 MESSAGE_LOG_LEVEL="${1:-}"
  shift 1

  case "${LOG_LEVEL:-inf}" in
    ( 'err' | 'error' ) LOG_LEVEL_AS_INTEGER=0 ;;
    ( 'war' | 'warn'  ) LOG_LEVEL_AS_INTEGER=1 ;;
    ( 'inf' | 'info'  ) LOG_LEVEL_AS_INTEGER=2 ;;
    ( 'deb' | 'debug' ) LOG_LEVEL_AS_INTEGER=3 ;;
    ( 'tra' | 'trace' ) LOG_LEVEL_AS_INTEGER=4 ;;
    ( * )
      libbash__exit_with_error_and_callstack "Log level '${LOG_LEVEL}' unknown"
      return 1
      ;;
  esac

  case "${MESSAGE_LOG_LEVEL}" in
    ( 'tra' | 'trace' )
      [[ ${LOG_LEVEL_AS_INTEGER} -lt 4 ]] && return 0
      __log_generic 'tra' 'TRACE' "${*}"
      ;;

    ( 'deb' | 'debug' )
      [[ ${LOG_LEVEL_AS_INTEGER} -lt 3 ]] && return 0
      __log_generic 'deb' 'DEBUG' "${*}"
      ;;

    ( 'inf' | 'info' )
      [[ "${LOG_LEVEL_AS_INTEGER}" -lt 2 ]] && return 0
      __log_generic 'inf' 'INFO ' "${*}"
      ;;

    ( 'war' | 'warning' )
      [[ "${LOG_LEVEL_AS_INTEGER}" -lt 1 ]] && return 0
      __log_generic 'war' 'WARN ' "${*}"
      ;;

    ( 'err' | 'error' )
      __log_generic 'err' 'ERROR' "${*}"
      ;;

    ( * )
      printf "Provided log level '%s' unknown" "${MESSAGE_LOG_LEVEL}" >&2
      return 0
      ;;
  esac

  return 0
}
export -f log
