#! /bin/bash

# version       0.2.0
# sourced by    init.sh
# task          provides error handlers

set -euEo pipefail
shopt -s inherit_errexit

trap '__log_uerror "${FUNCNAME[0]:-none (global)}" "${BASH_COMMAND:-?}" "${LINENO:-?}" "${?:-?}"' ERR

function __log_uerror
{
  local MESSAGE
  MESSAGE+="script: ${SCRIPT:-${0}}"
  MESSAGE+=" | function = ${1}"
  MESSAGE+=" | command = ${2}"
  MESSAGE+=" | line = ${3}"
  MESSAGE+=" | exit code = ${4}"

  notify 'err' "${MESSAGE}" >&2
  __show_call_stack
  return 0
}
