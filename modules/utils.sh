#! /usr/bin/env bash

# version       0.1.1
# sourced by    ../load
# task          provides error handlers

# ### Split a String with a Delimiter Into an Array
#
# This tasks is required a lot but cumbersome (and not easy to remember)
# and not easy to perform correctly.
#
# #### Arguments
#
# $1 :: array name (this array is created)
# $2 :: string to split
# $3 :: delimiter (optional, default=:)
#
# #### Attention
#
# Backslash (`\`) does not work as a delimiter because the escaping logic
# is simple and just removes baskslashes.
#
# #### References
#
# StackOverflow: https://stackoverflow.com/a/45201229
function split_into_array() {
  local ARRAY_NAME=${1:?Array name is required}
  local STRING_TO_SPLIT=${2:?String to split is required}
  local DELIMITER=${3:-:}
  local UNESCAPED_DELIMITER=${DELIMITER//\\/}

  STRING_TO_SPLIT=${STRING_TO_SPLIT#"${UNESCAPED_DELIMITER}"} # remove prefix
  STRING_TO_SPLIT=${STRING_TO_SPLIT%"${UNESCAPED_DELIMITER}"} # remove suffix

  readarray \
    -t -d '' \
    "${ARRAY_NAME}" \
    < <(awk "{ gsub(/${DELIMITER}/,\"\0\"); print; }" <<< "${STRING_TO_SPLIT}${UNESCAPED_DELIMITER}")
  unset "${ARRAY_NAME}[-1]"
}

# ### Check If a Line Is a Comment or Blank
#
# Checks if the provided first argument starts with
# a comment or whether the line is blank.
#
# #### Arguments
#
# $1 :: line to be checked
# $2 :: comment symbol (optional, default=#)
function line_is_comment_or_blank() {
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
function escape() {
  [[ ${2} =~ .*\\.* ]] && {
    log 'error' \
      "Escape character is not allowed to be or contain a backslash"\
      "(use 'escape_backslash')"
    return 1
  }

  parameter_is_not_empty "${1}" || {
    log 'error' 'No string to be escaped provided'
    return 1
  }

  parameter_is_not_empty "${2}" || {
    log 'error' 'No escape character(s) provided'
    return 1
  }

  [[ ${#2} -ge 2 ]] && {
    log 'error' 'More than two parameters provided'
    return 1
  }

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
function escape_backslash() {
  # shellcheck disable=SC1003
  printf '%s' "${1//'\'/'\\'}"
}

# ### Exit Without Error
#
# Just a wrapper around `exit 0`.
function exit_success() { exit 0 ; }

# ### Exit With Error
#
# Just a wrapper around `exit 1`. Another exit
# code can be supplied as well.
#
# #### Arguments
#
# $1 :: exit code (optional, default=1)
# $2 :: message (optional, default='' (no output is printed))
function exit_failure() {
  local CODE=${1:-1}
  shift 1

  if [[ ! ${CODE} =~ ^[0-9]+$ ]]; then
    log 'error' "'exit_failure' was called with non-number exit code"
    __libbash__show_call_stack
    exit 1
  fi

  if [[ ${CODE} -eq 0 ]] || [[ ${CODE} -ge 127 ]]; then
    log 'error' "'exit_failure' was called with exit code 0 or >127"
    __libbash__show_call_stack
    exit 1
  fi

  parameter_is_not_empty "${1}" && log 'error' "${1}"
  exit "${CODE}"
}

# ### Exit Without Error
#
# Just a wrapper around `return 0`. This should only be
# used at the very end of a function is it relies on Bash
# settings the return code of the last command as the exit
# code of the function.
function return_success() { return 0 ; }

# ### Exit With Error
#
# Just a wrapper around `return 1`. This should only be
# used at the very end of a function is it relies on Bash
# setting the return code of the last command as the exit
# code of the function.
#
# #### Arguments
#
# $1 :: message (optional, default='')
function return_failure() {
  if [[ ! ${1:-1} =~ ^[0-9]+$ ]]; then
    log 'error' "'return_failure' was called with non-number exit code"
    __libbash__show_call_stack
    exit 1
  fi

  if [[ ${1:-1} -eq 0 ]] || [[ ${1:-1} -ge 128 ]]; then
    log 'error' "'return_failure' was called with exit code 0 or >127"
    __libbash__show_call_stack
    exit 1
  fi

  parameter_is_not_empty "${*}" && log 'error' "${*}"
  return "${1:-1}"
}

# ### Exit with Error and Show the Callstack
#
# This function exits with exit code 1 but also
# prints information about the call stack. Another
# exit code can be supplied as well.
#
# #### Arguments
#
# Same as `exit_failure`.
function exit_failure_show_callstack() {
  parameter_is_not_empty "${2:-}" && log 'error' "${2}"
  __libbash__show_call_stack
  exit_failure "${1:-}"
}

# ### Check if Variable is Set
#
# This function checks if an environment variable is set.
#
# #### Arguments
#
# $1 :: the variable's name
function var_is_set() {
  [[ -v ${1:-__UNSET__} ]]
}

# ### Check if Variable is Set and Not Empty
#
# This function checks if an environment variable is set
# and not empty.
#
# #### Arguments
#
# $1 :: the variable's name
function var_is_set_and_not_empty() {
  var_is_set "${1}" && [[ -n ${!1:-} ]]
}

# ### Tell Whether a Parameter to a Function is Set and Not Empty
#
# This function returns true if the variable given in $1
# is not null and not empty.
#
# #### Arguments
#
# $1 :: the parameter you want to check
#
# #### Example
#
# ```bash
# function my_echo() {
#   parameter_is_not_empty "${1}"
#   echo "${1}"
# }
# ```
function parameter_is_not_empty() {
  [[ -n ${1:-} ]]
}

# ### Ask a Question
#
# This function states a question and returns the result
# in a variable name given to this function.
#
# #### Arguments
#
# $1 :: question
# $2 :: variable name to store the result in
function ask_question() {
  parameter_is_not_empty "${1}" || {
    log 'error' 'No question provided'
    return 1
  }

  parameter_is_not_empty "${2}" || {
    log 'error' 'No variable to store result in provided'
    return 1
  }

  local QUESTION=${1}
  local -n VARIABLE_TO_STORE_ANSWER_IN=${2}

  # shellcheck disable=SC2034
  read -r -p "${QUESTION} " VARIABLE_TO_STORE_ANSWER_IN
}

# ### Ask a Question - Special Case
#
# This functionis for the special case where the question
# is a yes-or-no question (binary). It will state the question
# and it can be given a default answer. It will return true or
# false depending on the default and the user input.
#
# #### Arguments
#
# $1 :: question
# $2 :: default (optional, default=no)
function ask_yes_no_question() {
  parameter_is_not_empty "${1}" || {
    log 'error' 'No question provided'
    return 1
  }

  local ANSWER DEFAULT_STRING
  local DEFAULT=${2:-no} YES_REGEXP='^(y|yes)$'
  DEFAULT=${DEFAULT,,}

  if [[ ${DEFAULT} =~ ${YES_REGEXP} ]]; then
    DEFAULT_STRING=' [Y/n]'
  else
    DEFAULT_STRING=' [y/N]'
  fi

  ask_question "${1}${DEFAULT_STRING}" ANSWER

  if [[ ${DEFAULT} =~ ${YES_REGEXP} ]] && [[ -z ${ANSWER} ]]; then
    return 0
  elif [[ ${DEFAULT} =~ ^(n|N|no|No)$ ]] && [[ -z ${ANSWER} ]]; then
    return 1
  fi

  [[ ${ANSWER,,} =~ ${YES_REGEXP} ]]
}

# ### Is a Program in ${PATH}?
#
# This function returns with exit code 0 (success) if
# the argument given is in ${PATH}, otherwise exit code
# 1 (failure) is returned.
#
# #### Arguments
#
# $1 :: executable to check
function is_in_path() {
  parameter_is_not_empty "${1}" || {
    log 'error' 'No name for an executable provided'
    return 1
  }

  command -v "${1}" &>/dev/null
}

# ### Is a Program Not in ${PATH}?
#
# This function returns with exit code 1 (failure) if
# the argument given is not in ${PATH}, otherwise exit
# code 0 (success) is returned.
#
# #### Arguments
#
# $1 :: executable to check
function is_not_in_path() {
  ! is_in_path "${1}"
}

# ### Check Whether a Directory is Empty
#
# This function checks whether a directory
# contains files or other directories, and
# returns false if so.
#
# #### Arguments
#
# $1 :: directory to check
function dir_is_empty() {
  parameter_is_not_empty "${1}" || {
    log 'error' 'No name for an executable provided'
    return 1
  }

  [[ -n $(find "${1}" -maxdepth 0 -empty) ]]
}

# ### Check Whether a Directory is Not Empty
#
# This function checks whether a directory
# contains files or other directories, and
# returns true if so.
#
# #### Arguments
#
# $1 :: directory to check
function dir_is_not_empty() {
  ! dir_is_empty "${1}"
}
