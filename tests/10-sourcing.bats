load 'bats_support/load'
load 'bats_assert/load'

BATS_TEST_FILE='10-sourcing         ::'

function setup_file {
  cd "${ROOT_DIRECTORY}" || exit 1
  LOG_LEVEL='inf'
}

@test "${BATS_TEST_FILE} sourcing succeeds from repository root" {
  source load
  assert_success
}

@test "${BATS_TEST_FILE} sourcing succeeds from 'tests/' directory" {
  (
    cd "${ROOT_DIRECTORY}/tests/"
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

@test "${BATS_TEST_FILE} sourcing with parameters succeeds from 'tests/' directory" {
  (
    cd "${ROOT_DIRECTORY}/tests/" || exit 1
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

@test "${BATS_TEST_FILE} sourcing with parameters succeeds from '.github/workflows' directory" {
  (
    cd "${ROOT_DIRECTORY}/.github/workflows/"
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
  bats_require_minimum_version 1.7.0

  source load
  assert_success

  libbash__show_call_stack
  assert_success

  function testshow_call_stack_1 {
    libbash__show_call_stack
  }

  function testshow_call_stack_2 {
    testshow_call_stack_1
  }

  run testshow_call_stack_2
  assert_success
  assert_output --partial 'call stack (most recent call first):'
  assert_output --partial 'testshow_call_stack'

  run __libbash__show_error 'namd'
  assert_success
  assert_output --regexp '\[  .*ERROR.*  \].*'
  assert_output --partial 'namd'

  run libbash__exit_with_error_and_callstack 'namd'
  assert_failure
  assert_output --regexp '\[  .*ERROR.*  \].*'
  assert_output --partial 'namd'

  run -127 load_module
  assert_failure

  run -127 source_files
  assert_failure

  run -127 setup_default_notify_error
  assert_failure

  run -127 libbash_main
  assert_failure

  source load 'log' 'utils'
  LOG_LEVEL='tra'
  run libbash__debug
  assert_success
  assert_output --partial 'Loaded modules: log utils'

}

function teardown_file {
  :
}
