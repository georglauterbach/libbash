#! /bin/bash

# version       0.5.0
# sourced by    ../load
# task          provides logging functionality

# ### The Logging Functions
#
# `notify` is used for logging. It uses five different log levels
#
# - `err`
# - `war`
# - `inf`
# - `deb`
# - `tra`
#
# and behaves as you would expect from a log function.
function notify
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
  local LOG_LEVEL_AS_INTEGER=2 LOG_LEVEL_AS_INTEGER_STRING="${1:-}"
  shift 1

  case "${LOG_LEVEL:-inf}" in
    ( 'err'* ) LOG_LEVEL_AS_INTEGER=0 ;;
    ( 'war'* ) LOG_LEVEL_AS_INTEGER=1 ;;
    ( 'inf'* ) LOG_LEVEL_AS_INTEGER=2 ;;
    ( 'deb'* ) LOG_LEVEL_AS_INTEGER=3 ;;
    ( 'tra'* ) LOG_LEVEL_AS_INTEGER=4 ;;
    ( *      ) LOG_LEVEL_AS_INTEGER=2 ;;
  esac

  case "${LOG_LEVEL_AS_INTEGER_STRING}" in
    ( 'tra' )
      [[ ${LOG_LEVEL_AS_INTEGER} -lt 4 ]] && return 0
      __log_trace "${*}"
      ;;

    ( 'deb' )
      [[ ${LOG_LEVEL_AS_INTEGER} -lt 3 ]] && return 0
      __log_debug "${*}"
      ;;

    ( 'inf' )
      [[ "${LOG_LEVEL_AS_INTEGER}" -lt 2 ]] && return 0
      __log_info "${*}"
      ;;

    ( 'war' )
      [[ "${LOG_LEVEL_AS_INTEGER}" -lt 1 ]] && return 0
      __log_warning "${*}"
      ;;

    ( 'err' )
      __log_error "${*}"
      ;;

    ( * )
      [[ "${LOG_LEVEL_AS_INTEGER}" -lt 1 ]] && return 0
      __log_warning "${*}"
      ;;
  esac

  return 0
}
