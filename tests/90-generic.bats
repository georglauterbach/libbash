load 'bats_support/load'
load 'bats_assert/load'

BATS_TEST_FILE='90-generic          ::'

function setup_file
{
  cd "${ROOT_DIRECTORY}" || exit 1
}

@test "${BATS_TEST_FILE} 'cri.sh' makes the correct decision" {
  source load 'log' 'cri'
  assert_success

  local DOCKER_IS_IN_PATH PODMAN_IS_IN_PATH
  DOCKER_IS_IN_PATH="$(command -v docker || :)"
  PODMAN_IS_IN_PATH="$(command -v podman || :)"

  if [[ -n ${DOCKER_IS_IN_PATH} ]]
  then
    setup_container_runtime
    assert_success
    [[ ${CRI} == 'docker' ]]
    assert_success
  elif [[ -n ${PODMAN_IS_IN_PATH} ]]
  then
    setup_container_runtime
    assert_success
    [[ ${CRI} == 'podman' ]]
    assert_success
  else
    setup_container_runtime
    assert_failure
    assert_output --partial 'Could not identify Container Runtime.'
  fi

}

function teardown_file
{
  :
}
