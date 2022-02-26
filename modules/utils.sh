#! /bin/bash

# version       0.1.0
# sourced by    ../load
# task          provides error handlers

# ### Check If a Line Is a Comment or Blank
#
# Checks if the provided first argument starts with
# a comment or whether the line is blank.
#
# #### Arguments
#
# $1 :: line to be checked
# $2 :: comment symbol (optional, default=#)
function line_is_comment_or_blank
{
  local COMMENT_SYMBOL
  COMMENT_SYMBOL=${2:-#}
  grep -qE "^\s*$|^\s*${COMMENT_SYMBOL}" <<< "${1:-}"
}

# ### Escape All But Backslashes
#
# Takes a string and an escape character and
# puts backslashes in front. Does not accept
# backslashes as escape character. The escape
# character must be a single character.
#
# #### Arguments
#
# $1 :: string to be escaped
# $2 :: character that must be escaped
function escape
{
  [[ -z ${1+set} ]] && return 1
  # shellcheck disable=SC1003
  [[ ${2:-} == '\\' ]] && return 2
  [[ ${#2} -eq 0 ]] && return 3
  [[ ${#2} -ge 2 ]] && return 4

  printf '%s' "${1//${2}/\\${2}}"
}

# ### Escape Backslashes Only
#
# Takes a string and puts s backslash more
# in front of an already present backslash.
#
# #### Arguments
#
# $1 :: string to be escaped
function escape_backslash
{
  # shellcheck disable=SC1003
  printf '%s' "${1//'\'/'\\'}"
}

# ### Exit Without Error
#
# Just a wrapper around `exit 0`.
function exit_success { exit 0 ; }

# ### Exit With Error
#
# Just a wrapper around `exit 1`. Another exit
# code can be supplied as well.
#
# #### Arguments
#
# $1 :: exit code (optional, default=1)
function exit_failure
{
  if [[ ! ${1:-1} =~ ^[0-9]+$ ]]
  then
    notify 'err' "'exit_failure' was called with non-number exit code"
    __libbash_show_call_stack
    exit 1
  fi

  if [[ ${1:-1} -eq 0 ]] || [[ ${1:-1} -ge 128 ]]
  then
    notify 'err' "'exit_failure' was called with exit code 0 or >127"
    __libbash_show_call_stack
    exit 1
  fi

  exit "${1:-1}"
}

# ### Exit with Error and More Information
#
# This function exits with exit code 1 but also
# prints information about the call stack. Another
# exit code can be supplied as well.
#
# #### Arguments
#
# $1 :: exit code (optional, default=1)
function exit_failure_and_show_callstack
{
  __libbash_show_call_stack
  exit_failure "${1:-1}"
}
