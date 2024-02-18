bats_require_minimum_version '1.10.0'

load 'bats_support/load'
load 'bats_assert/load'

BATS_TEST_NAME_PREFIX='10-sourcing         :: '

function setup_file() {
  cd "${ROOT_DIRECTORY}" || exit 1
  LOG_LEVEL='inf'
}

@test "sourcing succeeds from repository root" {
  run bash -c 'source load'
  assert_success
}

@test "sourcing succeeds from 'tests/' directory" {
  (
    cd "${ROOT_DIRECTORY}/tests/"
    # shellcheck source=load
    run bash -c 'source ../load'
    assert_success
  )
}

@test "sourcing succeeds from 'modules/' directory" {
  (
    cd "${ROOT_DIRECTORY}/modules/" || exit 1
    # shellcheck source=load
    run bash -c ' source ../load'
    assert_success
  )
}

@test "sourcing with parameters succeeds from repository root" {
  run bash -c 'source load "log" "cri"'
  assert_success
}

@test "sourcing with parameters succeeds from 'tests/' directory" {
  (
    cd "${ROOT_DIRECTORY}/tests/" || exit 1
    run source ../load 'log' 'cri'
    assert_success
  )
}

@test "sourcing with parameters succeeds from 'modules/' directory" {
  (
    cd "${ROOT_DIRECTORY}/modules/"
    run source ../load 'log' 'cri'
    assert_success
  )
}

@test "sourcing with parameters succeeds from '.github/workflows' directory" {
  (
    cd "${ROOT_DIRECTORY}/.github/workflows/"
    run source ../../load 'log' 'cri'
    assert_success
  )
}

@test "sourcing a module more than once results in an error" {
  run source load 'log' 'log'
  assert_failure 3
}

@test "sourcing an unknown module results in an error" {
  run source load 'somethingOdd'
  assert_failure 4
}

@test "sourcing a module twice results in an error" {
  run source load 'log' 'log'
  assert_failure
}

@test "internal helper functions work correctly" {
  source load

  run __libbash__show_call_stack
  assert_success

  function testshow_call_stack_1 {
    __libbash__show_call_stack
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

  run __libbash__exit_with_error_and_callstack 'namd'
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
