#! /bin/bash

# version       0.1.0
# executed by   ../load
# task          perform library initialization

export SCRIPT='libbash initialization'

function __libbash_show_error
{
  printf "\e[0m[  \e[91mERROR\e[0m  ] %30s | \e[91m%s\e[0m\n" \
    "${SCRIPT:-${0}}" "${*}" >&2
}

function __libbash_show_error_and_exit
{
  __libbash_show_error "${*}"
  exit 1
}

function basic_setup
{
  export LOG_LEVEL LIBBASH_DIRECTORY SCRIPT

  LOG_LEVEL=${LOG_LEVEL:-inf}
  INIT_SCRIPT_LOCATION="${BASH_SOURCE[0]}"
  LIBBASH_DIRECTORY="$(dirname "${INIT_SCRIPT_LOCATION}")"
}

function load_module
{
  [[ -z ${1+set} ]] && __libbash_show_error_and_exit "module loading failed (no module provided)"

  if [[ -e "${LIBBASH_DIRECTORY}/${1}.sh" ]]
  then
    # shellcheck source=/dev/null
    source "${LIBBASH_DIRECTORY}/${1}.sh"
  else
    __libbash_show_error_and_exit "module '${1:-}' not found"
  fi
}

function source_files
{
  local MODULE
  for MODULE in "${@}"
  do
    [[ ${*} =~ ${MODULE} ]] && load_module "${MODULE}"
  done

  unset load_module MODULES
}

function debug
{
  notify 'deb' "Showing 'libbash' debug information"
  notify 'deb' "Call / source stack:"
  for (( INDEX=${#BASH_SOURCE[@]} - 1 ; INDEX>1 ; INDEX-- ))
  do
    printf "%45s%s\n" '' "${BASH_SOURCE[INDEX]}"
  done
}

function setup_default_notify_error
{
  function notify
  {
    if [[ ${1:-} != 'err' ]]
    then
      __libbash_show_error_and_exit "log module was not loaded but 'notify' was called"
      return 1
    fi

    __libbash_show_error "${*}"
  }
  export -f notify
}

function main
{
  basic_setup
  source_files "${@}"

  if [[ ! $(type -t notify) == 'function' ]]
  then
    setup_default_notify_error
    return 0
  fi

  [[ ${LOG_LEVEL} == 'tra' ]] && debug
  notify 'tra' "Finished 'libbash' initialization"
}

main "${@}"
unset basic_setup load_module source_files debug setup_default_notify_error main
