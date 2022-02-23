#! /bin/bash

# version       0.3.2
# executed by   Make or manually
# task          lints the codebase against various linters

# shellcheck source=src/init.sh
source src/init.sh 'errors' 'log' 'cri'
SCRIPT='linting'
ROOT_DIRECTORY=${ROOT_DIRECTORY:-"$(realpath "$(dirname "$(realpath -eL "${0}")")/..")"}

# shellcheck disable=SC2154

# -->                   -->                   --> START

function lint_editorconfig
{
  local VERSION IMAGE
  VERSION=latest
  IMAGE="docker.io/mstruebing/editorconfig-checker:${VERSION}"

  notify 'deb' "Running EditorConfig lint (${VERSION})"

  if "${CRI}" run \
    --rm \
    --cap-drop=ALL \
    --user=999 \
    --volume "${ROOT_DIRECTORY}:/ci:ro" \
    --workdir "/ci" \
    "${IMAGE}" ec \
      -config "/ci/.github/linters/.ecrc"
  then
    notify 'inf' 'EditorConfig lint succeeded'
    return 0
  else
    notify 'err' 'EditorConfig lint reported problems'
    return 1
  fi
}

function lint_shellcheck
{  
  declare -a ARGUMENTS
  local VERSION IMAGE FILES

  VERSION='0.8.0'
  IMAGE="docker.io/koalaman/shellcheck:v${VERSION}"
  readarray -d '' FILES < <(find  \
    "${ROOT_DIRECTORY}/scripts/"  \
    "${ROOT_DIRECTORY}/src/"      \
    "${ROOT_DIRECTORY}/tests/"    \
    -maxdepth 1                   \
    -type f                       \
    -regextype egrep              \
    -iregex ".*\.(sh|bats)"       \
    -print0)

  ARGUMENTS=(
    '--shell=bash'
    '--enable=all'
    '--severity=style'
    '--color=auto'
    '--wiki-link-count=5'
    '--check-sourced'
    '--external-sources'
    '--exclude=SC2310'
    '--exclude=SC2312'
    "--source-path=${ROOT_DIRECTORY}"
  )

  notify 'deb' "Running ShellCheck (${VERSION})"

  # shellcheck disable=SC2154
  if "${CRI}" run \
    --rm \
    --cap-drop=ALL \
    --user=999 \
    --volume "${ROOT_DIRECTORY}:${ROOT_DIRECTORY}:ro" \
    --workdir "/ci" \
    "${IMAGE}" \
      "${ARGUMENTS[@]}" \
      "${FILES[@]}"
  then
    notify 'inf' 'ShellCheck succeeded'
    return 0
  else
    notify 'err' 'ShellCheck reported problems'
    return 1
  fi
}

function usage
{
  cat << "EOM" 
LINT.SH(1)

SYNOPSIS
    ./scripts/lint.sh [ OPTION... ] < ACTION... >
    make lint

OPTIONS
    --help                     Show this help message

ACTIONS
    editorcinfig | ec          Run the EditorConfig linter
    shellcheck   | sc          Run the ShellCheck linter

EOM
}

function main
{
  setup_container_runtime || return 1
  local ERROR_OCCURRED=false

  notify 'inf' 'Starting the linting process'

  if [[ -n ${1:-} ]]
  then
    case "${1}" in
      ( '--help' )
        usage
        exit 0
        ;;

      ( 'editorconfig' | 'ec' )
        lint_editorconfig || ERROR_OCCURRED=true
        ;;

      ( 'shellcheck' | 'sc' )
        lint_shellcheck || ERROR_OCCURRED=true
        ;;

      ( * )
        notify 'err' "'${1}' is not a valid linter ('sh' or 'gsl' are valid)"
        exit 1
        ;;
    esac
  else
    lint_editorconfig || ERROR_OCCURRED=true
    lint_shellcheck || ERROR_OCCURRED=true
  fi

  if ${ERROR_OCCURRED}
  then
    notify 'err' 'Linting not successful'
    return 1
  else
    notify 'inf' 'Linting successful'
    return 0
  fi
}

main "${@}" || exit ${?}
