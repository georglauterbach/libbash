#! /usr/bin/env bash

# version       1.0.0
# sourced by    ../load
# task          provides error handlers

# `set -u` is not performed here due to `BP_PIPESTATUS` etc.
set -E -o pipefail
shopt -s inherit_errexit

# Call `log_unexpected_error` with additional information
# when the ERR trap is triggered.
trap 'log_unexpected_error "${FUNCNAME[0]:-}" "${BASH_COMMAND:-}" "${LINENO:-}" "${?:-}"' ERR

# ### Remove Newlines from a String
#
# This function removes newlines from a given string,
# replacing them with " ".
#
# #### Arguments
#
# $1 :: The string to escape (optional, default=unkown)
#
# #### Return Codes
#
# This function is infallible. Hence, it always returns with
# return code 0.
function remove_newlines() {
  local STRING=${1:-unknown}
  echo "${STRING//$'\n'/ }"
}

# ### Expand a String
#
# This function expands a given string
#
# #### Arguments
#
# $1 :: The string to expand (optional, default=unkown)
#
# #### Attention
#
# This function uses `eval` to escape the string in the end.
# While considerable effort has been put into proper escaping,
# no one can guarantee that all pitfalls and escape hatches
# have been eliminated that could lead to arbitrary code execution
# with the `eval` at the end.
#
# Of special importance is the replacement '//\$\(/\\$\(', which
# replaces all '$(' with '\$('.
#
# #### References
#
# StackOverflow
#   - https://stackoverflow.com/a/20316582
function apply_shell_expansion() {
  local DELIMITER="__apply_shell_expansion_delimiter__"
  local STRING_TO_ESCAPE=${1:-unknown}
  STRING_TO_ESCAPE=$(remove_newlines "${STRING_TO_ESCAPE}")
  STRING_TO_ESCAPE=${STRING_TO_ESCAPE//\$\(/\\$\(}

  eval "cat <<${DELIMITER}"$'\n'"${STRING_TO_ESCAPE}"$'\n'"${DELIMITER}"
}

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
# #### Attention
#
# Underscored functions are not unset at the end of the sourcing
# process, but they should only be used by `libbash` modules, not
# by applications / other libraries using `libbash`.
#
# Please also not the "Attention" section of `apply_shell_expansion`.
#
# #### Arguments
#
# $1 :: Name of the function the error happened in
# $2 :: The command that caused the error
# $3 :: The line number in which $2 was executed
# $4 :: The return code of $2
function log_unexpected_error() {
  # shellcheck disable=SC2155
  local MESSAGE="unexpected error occured:
  script:     ${SCRIPT:-${0}}
  function:   ${1:-error did not happen inside a function}
  command:
    plain:    $(remove_newlines "${2:-unknown}")
    expanded: $(apply_shell_expansion "${2:-unknown}")
  line:       ${3:-unknown}
  exit code:  ${4:-unknown}"

  __libbash__show_error "${MESSAGE}"
  __libbash__show_call_stack --internal
  return 0
}
export -f log_unexpected_error

trap 'log_unexpected_error "${FUNCNAME[0]:-}" "${BASH_COMMAND:-}" "${LINENO:-}" "${?:-}"' ERR
