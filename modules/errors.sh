#! /bin/bash

# version       0.3.0
# sourced by    ../load
# task          provides error handlers

# `set -u` is not performed here due to `BP_PIPESTATUS` etc.
set -eEo pipefail
shopt -s inherit_errexit

trap '__log_unexpected_error "${FUNCNAME[0]:-}" "${BASH_COMMAND:-}" "${LINENO:-}" "${?:-}"' ERR

# ### Log the `ERR` Event
#
# This function is called when an unhandled `ERR` signal is thrown.
# It prints information about the error (where it originated, etc.)
# and also calls `__show_call_stack` to possibly print a call stack
# if `__show_call_stack` deems it useful.
#
# #### Special
# 
# Underscored functions are not unset at the end of the sourcing
# process, but they should only be used by `libbash` modules, not
# by applications / other libraries using `libbash`.
function __log_unexpected_error
{
  local MESSAGE='unexpected error occured { '
  MESSAGE+="script: ${SCRIPT:-${0}}"
  MESSAGE+=" | function = ${1:-none global}"
  MESSAGE+=" | command = ${2:-?}"
  MESSAGE+=" | line = ${3:-?}"
  MESSAGE+=" | exit code = ${4:-?}"
  MESSAGE+=" }"

  notify 'err' "${MESSAGE}"
  __show_call_stack
  return 0
}

# ### Exit Without Error
#
# Just a wrapper around `exit 0`.
function exit_success { exit 0 ; }

# ### Exit With Error
#
# Just a wrapper around `exit 1`.
function exit_failure { exit 1 ; }

# ### Exit with Error and More Information
#
# This function exits with exit code 1 but also
# prints information about the call stack.
function exit_failure_and_show_callstack
{
  __show_call_stack
  exit_failure
}
