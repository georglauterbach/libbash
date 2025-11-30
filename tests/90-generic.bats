# shellcheck disable=SC2030,SC2031

bats_require_minimum_version '1.10.0'

load 'bats_support/load'
load 'bats_assert/load'

# shellcheck disable=SC2034
BATS_TEST_NAME_PREFIX='90-generic          :: '

@test "'cri.sh' makes the correct decision" {
  # shellcheck source=../libbash
  source libbash 'log' 'cri'

  local DOCKER_IS_IN_PATH PODMAN_IS_IN_PATH
  DOCKER_IS_IN_PATH="$(command -v docker || :)"
  PODMAN_IS_IN_PATH="$(command -v podman || :)"

  if [[ -n ${DOCKER_IS_IN_PATH} ]]; then
    run setup_container_runtime
    assert_success
    setup_container_runtime
    [[ ${CRI} == 'docker' ]]
    assert_success
  elif [[ -n ${PODMAN_IS_IN_PATH} ]]; then
    run setup_container_runtime
    assert_success
    setup_container_runtime
    [[ ${CRI} == 'podman' ]]
    assert_success
  else
    run setup_container_runtime
    assert_failure
    assert_output --partial 'Could not identify Container Runtime.'
  fi

}
