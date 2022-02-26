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

@test "${BATS_TEST_FILE} sourcing a module twice results in an error" {
  run source load 'log' 'log'
  assert_failure
}

@test "${BATS_TEST_FILE} internal helper functions work correctly" {
  source load
  assert_success

  __libbash_show_call_stack
  assert_success

  function test__libbash_show_call_stack_1
  {
    __libbash_show_call_stack
  }

  function test__libbash_show_call_stack_2
  {
    test__libbash_show_call_stack_1
  }

  run test__libbash_show_call_stack_2
  assert_success
  assert_output --partial 'call stack (most recent call first):'
  assert_output --partial 'test__libbash_show_call_stack'

  run __libbash_show_error 'namd'
  assert_success
  assert_output --regexp '\[  .*ERROR.*  \].*'
  assert_output --partial 'namd'

  run __libbash_show_error_and_exit 'namd'
  assert_failure
  assert_output --regexp '\[  .*ERROR.*  \].*'
  assert_output --partial 'namd'

  run load_module
  assert_failure

  run source_files
  assert_failure

  run setup_default_notify_error
  assert_failure

  run libbash_main
  assert_failure

  source load 'log' 'utils'
  LOG_LEVEL='tra'
  run debug_libbash
  assert_success
  assert_output --partial 'Loaded modules: log utils'

}

function teardown_file
{
  :
}
