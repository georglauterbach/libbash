#! /bin/bash

# version       0.2.0
# sourced by    init.sh
# task          provides container-runtime-related functions

function setup_container_runtime
{
  command -v 'docker' &>/dev/null && export CRI='docker' && return 0
  command -v 'podman' &>/dev/null && export CRI='podman' && return 0

  notify 'err' \
    'Could not identify Container Runtime.' \
    "Is 'docker' or 'podman' in \${PATH}?"
  return 1
}
