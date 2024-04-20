#! /usr/bin/env bash

# version       1.0.0
# sourced by    ../load
# task          provides error handlers

# `set -u` is not performed here due to `BP_PIPESTATUS` etc.
set -eE -o pipefail
shopt -s inherit_errexit

trap 'log_unexpected_error "${FUNCNAME[0]:-}" "${BASH_COMMAND:-}" "${LINENO:-}" "${?:-}"' ERR

# ### Log the Error Event
#
# This function is called when an unhandled error signal is thrown.
# It prints information about the error (where it originated, etc.)
# and also calls `__libbash__show_call_stack` to possibly print a
# call stack if `__libbash__show_call_stack` deems it useful.
#
# #### Explanations
#
# The code below has to be used in conjuction with the `ERR` trap
# above. The trap uses special variable that Bash sets to show the
# user what happened.
#
# Furthermore, the `eval echo "${2:-unknown}"` expands all variables
# in `${2}` (which contains the value of `${BASH_COMMAND}`, i.e. the command
# that was executed). This is neat because the user can see the expanded
# version of the command too.
#
#
# #### Attention
#
# Underscored functions are not unset at the end of the sourcing
# process, but they should only be used by `libbash` modules, not
# by applications / other libraries using `libbash`.
function log_unexpected_error() {
  # shellcheck disable=SC2155
  local MESSAGE="unexpected error occured:
  script:     ${SCRIPT:-${0}}
  function:   ${1:-error did not happen inside a function}
  command:
    plain:    '${2:-unknown}'
    expanded: '$(eval echo "${2:-unknown}")'
  line:       ${3:-unknown}
  exit code:  ${4:-unknown}"

  __libbash__show_error "${MESSAGE}"
  __libbash__show_call_stack --internal
  return 0
}
export -f log_unexpected_error
