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
  [[ ${2} == \\ ]] && return 1
  [[ ${#2} -eq 0 ]] && return 2
  [[ ${#2} -ge 2 ]] && return 3

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
