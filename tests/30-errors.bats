bats_require_minimum_version '1.10.0'

load 'bats_support/load'
load 'bats_assert/load'

BATS_TEST_NAME_PREFIX='30-errors           :: '

function setup_file() {
  cd "${ROOT_DIRECTORY}" || exit 1
  export LOG_LEVEL='trace'
}

@test "'errors' is correctly sourced" {
  run bash -c 'source load "errors"'
  assert_success
}

@test "'errors' is correctly sourced with other modules" {
  run bash -c 'source load "errors" "log" "utils"'
  assert_success
}

@test "'errors' provoking fault triggers error" {
  run bash -c "( source load 'errors' 'log' 'utils' ; false ; )"
  assert_failure
  assert_output --partial 'unexpected error occured:'
}
