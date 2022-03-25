#! /bin/bash

# version       0.5.1
# sourced by    ../load
# task          provides logging functionality

# ### The Logging Functions
#
# `log` is used for logging. It uses five different log levels
#
# `err` | `war` | `inf` | `deb` | `tra`
#
# and behaves as you would expect from a log function: you provide
# the log level as the first argument and the message in the con-
# secutive ones.
#
# #### Arguments
#
# $1 :: log level
# $2 :: message (strictly speaking optional, no default / empty string)
function log
{
  function __log_trace
  {
    printf "\e[0m[  \e[94mTRACE\e[0m  ] %30s | \e[94m%s\e[0m\n" \
      "${SCRIPT:-${0}}" "${*}"
  }

  function __log_debug
  {
    printf "\e[0m[  \e[94mDEBUG\e[0m  ] %30s | \e[94m%s\e[0m\n" \
      "${SCRIPT:-${0}}" "${*}"
  }

  function __log_info
  {
    printf "\e[0m[   \e[34mINF\e[0m   ] %30s | \e[34m%s\e[0m\n" \
      "${SCRIPT:-${0}}" "${*}"
  }

  function __log_warning
  {
    printf "\e[0m[ \e[93mWARNING\e[0m ] %30s | \e[93m%s\e[0m\n" \
      "${SCRIPT:-${0}}" "${*}"
  }

  function __log_error
  {
    printf "\e[0m[  \e[91mERROR\e[0m  ] %30s | \e[91m%s\e[0m\n" \
      "${SCRIPT:-${0}}" "${*}" >&2
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
  # default log level is 'warning' (2).
  local LOG_LEVEL_AS_INTEGER=2 MESSAGE_LOG_LEVEL="${1:-}"
  shift 1

  case "${LOG_LEVEL:-inf}" in
    ( 'err' | 'error' ) LOG_LEVEL_AS_INTEGER=0 ;;
    ( 'war' | 'warn'  ) LOG_LEVEL_AS_INTEGER=1 ;;
    ( 'inf' | 'info'  ) LOG_LEVEL_AS_INTEGER=2 ;;
    ( 'deb' | 'debug' ) LOG_LEVEL_AS_INTEGER=3 ;;
    ( 'tra' | 'trace' ) LOG_LEVEL_AS_INTEGER=4 ;;
    ( * )
      printf "Log level '%s' unknown\n" "${LOG_LEVEL}" >&2
      exit 1
      ;;
  esac

  case "${MESSAGE_LOG_LEVEL}" in
    ( 'tra' | 'trace' )
      [[ ${LOG_LEVEL_AS_INTEGER} -lt 4 ]] && return 0
      __log_trace "${*}"
      ;;

    ( 'deb' | 'debug' )
      [[ ${LOG_LEVEL_AS_INTEGER} -lt 3 ]] && return 0
      __log_debug "${*}"
      ;;

    ( 'inf' | 'info' )
      [[ "${LOG_LEVEL_AS_INTEGER}" -lt 2 ]] && return 0
      __log_info "${*}"
      ;;

    ( 'war' | 'warning' )
      [[ "${LOG_LEVEL_AS_INTEGER}" -lt 1 ]] && return 0
      __log_warning "${*}"
      ;;

    ( 'err' | 'error' )
      __log_error "${*}"
      ;;

    ( * )
      printf "Provided log level '%s' unknown" "${MESSAGE_LOG_LEVEL}" >&2
      return 0
      ;;
  esac

  return 0
}
