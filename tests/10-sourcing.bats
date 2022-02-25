load 'bats_support/load'
load 'bats_assert/load'

BATS_TEST_FILE='10-sourcing         ::'

function setup_file
{
  cd "${ROOT_DIRECTORY}" || exit 1
  LOG_LEVEL='inf'
}

@test "${BATS_TEST_FILE} sourcing succeeds from repository root" {
  source load
  assert_success
}

@test "${BATS_TEST_FILE} sourcing succeeds from 'scripts/' directory" {
  (
    cd "${ROOT_DIRECTORY}/scripts/"
    # shellcheck source=load
    source ../load
    assert_success
  )
}

@test "${BATS_TEST_FILE} sourcing succeeds from 'modules/' directory" {
  (
    cd "${ROOT_DIRECTORY}/modules/" || exit 1
    # shellcheck source=load
    source ../load
    assert_success
  )
}

@test "${BATS_TEST_FILE} sourcing with parameters succeeds from repository root" {
  source load 'log' 'cri'
  assert_success
}

@test "${BATS_TEST_FILE} sourcing with parameters succeeds from 'scripts/' directory" {
  (
    cd "${ROOT_DIRECTORY}/scripts/" || exit 1
    run source ../load 'log' 'cri'
    assert_success
  )
}

@test "${BATS_TEST_FILE} sourcing with parameters succeeds from 'modules/' directory" {
  (
    cd "${ROOT_DIRECTORY}/modules/"
    run source ../load 'log' 'cri'
    assert_success
  )
}

@test "${BATS_TEST_FILE} sourcing with parameters succeeds from '.github/linters' directory" {
  (
    cd "${ROOT_DIRECTORY}/.github/linters/"
    run source ../../load 'log' 'cri'
    assert_success
  )
}


@test "${BATS_TEST_FILE} sourcing an unknown module results in an error" {
  run source load 'somethingOdd'
  assert_failure 1
}

function teardown_file
{
  :
}
