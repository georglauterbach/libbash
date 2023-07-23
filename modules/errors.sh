#! /bin/bash

# version       0.3.1
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
# and also calls `__libbash__show_call_stack` to possibly print a
# call stack if `__libbash__show_call_stack` deems it useful.
#
# #### Special
#
# Underscored functions are not unset at the end of the sourcing
# process, but they should only be used by `libbash` modules, not
# by applications / other libraries using `libbash`.
function __log_unexpected_error() {
  local MESSAGE="unexpected error occured: script = ${SCRIPT:-${0}} | "
  MESSAGE+="function = ${1:-none} | command = ${2:-?} | line = ${3:-?} | exit code = ${4:-?}"

  log 'err' "${MESSAGE}"
  __libbash__show_call_stack
  return 0
}
