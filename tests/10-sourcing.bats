bats_require_minimum_version '1.10.0'

load 'bats_support/load'
load 'bats_assert/load'

# shellcheck disable=SC2034
BATS_TEST_NAME_PREFIX='10-sourcing         :: '

function setup_file() {
  export LOG_LEVEL='info'
}

@test "sourcing succeeds from repository root" {
  run bash -c 'source libbash'
  assert_success
}

@test "sourcing succeeds from 'tests/' directory" {
  (
    cd "tests/"
    run bash -c 'source ../libbash'
    assert_success
  )
}

@test "sourcing succeeds from '.github/' directory" {
  (
    cd ".github/" || exit 1
    run bash -c ' source ../libbash'
    assert_success
  )
}

@test "sourcing with parameters succeeds from repository root" {
  run bash -c 'source libbash "log" "cri"'
  assert_success
}

@test "sourcing with parameters succeeds from 'tests/' directory" {
  (
    cd "tests/" || exit 1
    run source ../libbash 'log' 'cri'
    assert_success
  )
}

@test "sourcing with parameters succeeds from '.github/' directory" {
  (
    cd ".github/"
    run source ../libbash 'log' 'cri'
    assert_success
  )
}

@test "sourcing with parameters succeeds from '.github/workflows' directory" {
  (
    cd ".github/workflows/"
    run source ../../libbash 'log' 'cri'
    assert_success
  )
}

@test "sourcing a module more than once results in an error" {
  run source libbash 'log' 'log'
  assert_failure 2
}

@test "sourcing an unknown module results in an error" {
  run source libbash 'somethingOdd'
  assert_failure 3
}

@test "sourcing a module twice results in an error" {
  run source libbash 'log' 'log'
  assert_failure
}

@test "internal helper functions work correctly" {
  # shellcheck source=../libbash
  source libbash

  run __libbash__show_call_stack
  assert_success

  function test_show_call_stack_1 {
    __libbash__show_call_stack
  }

  function test_show_call_stack_2 {
    test_show_call_stack_1
  }

  run test_show_call_stack_2
  assert_success
  assert_output --partial 'call stack (most recent call first):'
  assert_output --partial 'test_show_call_stack'

  run __libbash__show_error 'message'
  assert_success
  assert_line --regexp 'ERROR.*message'

  run __libbash__exit_with_error_and_callstack 'message'
  assert_failure
  assert_output --regexp 'ERROR.*message'

  run -127 __libbash__main
  assert_failure

  run -127 __libbash__run_preflight_checks
  assert_failure

  run -127 __libbash__parse_arguments
  assert_failure

  run -127 __libbash__source_files
  assert_failure

  run -127 __libbash__setup_default_notify_error
  assert_failure

  run -127 __libbash__post_init
  assert_failure

  # shellcheck source=../libbash
  source libbash 'log' 'utils'
  LOG_LEVEL='trace'
  run libbash__debug
  assert_success
  assert_output --partial 'Loaded modules: log utils'
}
