load 'bats_support/load'
load 'bats_assert/load'

BATS_TEST_FILE='10-sourcing         ::'

function setup_file
{
  cd "${ROOT_DIRECTORY}"
  LOG_LEVEL='inf'
}

@test "${BATS_TEST_FILE} sourcing succeeds from repository root" {
  source src/init.sh
  assert_success
}

@test "${BATS_TEST_FILE} sourcing succeeds from 'scripts/' directory" {
  (
    cd "${ROOT_DIRECTORY}/scripts/"
    source ../src/init.sh
    assert_success
  )
}

@test "${BATS_TEST_FILE} sourcing succeeds from 'src/' directory" {
  (
    cd "${ROOT_DIRECTORY}/src/"
    source init.sh
    assert_success
  )
}

@test "${BATS_TEST_FILE} sourcing with parameters succeeds from repository root" {
  source src/init.sh 'log' 'cri'
  assert_success
}

@test "${BATS_TEST_FILE} sourcing with parameters succeeds from 'scripts/' directory" {
  (
    cd "${ROOT_DIRECTORY}/scripts/"
    run source ../src/init.sh 'log' 'cri'
    assert_success
  )
}

@test "${BATS_TEST_FILE} sourcing with parameters succeeds from 'src/' directory" {
  (
    cd "${ROOT_DIRECTORY}/src/"
    run source init.sh 'log' 'cri'
    assert_success
  )
}

@test "${BATS_TEST_FILE} sourcing an unknown module results in an error" {
  run source src/init.sh 'somethingOdd'
  assert_failure 1
}

function teardown_file
{
  :
}
