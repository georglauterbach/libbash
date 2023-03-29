#! /bin/bash

# version       0.2.0
# sourced by    ../load
# task          provides container-runtime-related functions

# ### Checks Whether Docker or Podman is Installed
#
# Checks whether `docker` or `podman` is in `${PATH}` and
# sets the `CRI` variable accordingly. Docker is chosen
# first if both Docker and Podman are installed.
function setup_container_runtime() {
  command -v 'docker' &>/dev/null && export CRI='docker' && return 0
  command -v 'podman' &>/dev/null && export CRI='podman' && return 0

  log 'err' \
    'Could not identify Container Runtime.' \
    "Is 'docker' or 'podman' in \${PATH}?"
  return 1
}
