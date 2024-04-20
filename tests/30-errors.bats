bats_require_minimum_version '1.10.0'

load 'bats_support/load'
load 'bats_assert/load'

BATS_TEST_NAME_PREFIX='30-errors           :: '

function setup_file() {
  export LOG_LEVEL='trace'
}

@test "'errors' is correctly sourced" {
  run bash -c 'source load "errors"'
  assert_success

  run bash -c 'source load "errors" ; trap ;'
  assert_success
  assert_output --regexp 'log_unexpected_error.*ERR'
}

@test "'errors' is correctly sourced with other modules" {
  run bash -c 'source load "errors" "log" "utils"'
  assert_success
}

@test "'errors' provoking fault triggers error" {
  run bash -c "( LOG_LEVEL=error ; source load 'errors' ; log 'warn' 'Test' ; )"
  assert_failure
  assert_output --partial "log module was not loaded but 'log' was called with log level not 'error'"

  run bash -c '( LOG_LEVEL=error ; source load "errors" "log" "utils" ; false ; )'
  assert_failure
  assert_output --partial 'unexpected error occured:'
}
