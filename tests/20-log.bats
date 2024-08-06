bats_require_minimum_version '1.10.0'

load 'bats_support/load'
load 'bats_assert/load'

BATS_TEST_NAME_PREFIX='20-log              :: '

function setup_file() {
  export LOG_LEVEL='trace'
  export TEST_STRING='jfk FJHAE aea728 djKJ  k/('
}

function setup() { source load log ; }

@test "module is sourced and 'log' is a function" {
  run bash -c 'source load "log"'
  assert_success

  source load log
  [[ $(type -t log) == 'function' ]]
  assert_success
}

@test "module is correctly sourced with other modules" {
  run bash -c 'source load "log" "errors" "utils"'
  assert_success
}

@test "checking log output for trace messages" {
  run log 'trace' "${TEST_STRING}"
  assert_success
  assert_line --partial "${TEST_STRING}"
  assert_line --regexp 'TRACE.*'
}

@test "checking log output for debug messages" {
  run log 'debug' "${TEST_STRING}"
  assert_success
  assert_line --partial "${TEST_STRING}"
  assert_line --regexp 'DEBUG.*'
}

@test "checking log output for info messages" {
  run log 'info' "${TEST_STRING}"
  assert_success
  assert_line --partial "${TEST_STRING}"
  assert_line --regexp 'INFO.*'
}

@test "checking log output for warning messages" {
  run log 'warn' "${TEST_STRING}"
  assert_success
  assert_line --partial "${TEST_STRING}"
  assert_line --regexp 'WARN.*'
}

@test "checking log output for error messages" {
  run log 'error' "${TEST_STRING}"
  assert_success
  assert_line --partial "${TEST_STRING}"
  assert_line --regexp 'ERROR.*'
}

@test "checking trace messages on log level 'trace'" {
  export LOG_LEVEL='trace'
  run log 'trace' "${TEST_STRING}"
  assert_success
  assert_line --partial "${TEST_STRING}"
  assert_line --regexp 'TRACE.*'
}

@test "checking debug messages on log level 'debug'" {
  export LOG_LEVEL='debug'
  run log 'debug' "${TEST_STRING}"
  assert_success
  assert_line --partial "${TEST_STRING}"
  assert_line --regexp 'DEBUG.*'
}

@test "checking info messages on log level 'info'" {
  export LOG_LEVEL='info'
  run log 'info' "${TEST_STRING}"
  assert_success
  assert_line --partial "${TEST_STRING}"
  assert_line --regexp 'INFO.*'
}

@test "checking warning messages on log level 'warn'" {
  export LOG_LEVEL='warn'
  run log 'warn' "${TEST_STRING}"
  assert_success
  assert_line --partial "${TEST_STRING}"
  assert_line --regexp 'WARN.*'
}

@test "checking error messages on log level 'error'" {
  export LOG_LEVEL='error'
  run log 'error' "${TEST_STRING}"
  assert_success
  assert_line --partial "${TEST_STRING}"
  assert_line --regexp 'ERROR.*'
}

@test "checking trace messages on log level 'debug'" {
  export LOG_LEVEL='debug'
  run log 'trace' "${TEST_STRING}"
  assert_success
  refute_output --partial "${TEST_STRING}"
  refute_output --regexp 'TRACE.*'
}

@test "checking debug messages on log level 'info'" {
  export LOG_LEVEL='info'
  run log 'debug' "${TEST_STRING}"
  assert_success
  refute_output --partial "${TEST_STRING}"
  refute_output --regexp 'DEBUG.*'
}

@test "checking info messages on log level 'warn'" {
  export LOG_LEVEL='warn'
  run log 'info' "${TEST_STRING}"
  assert_success
  refute_output --partial "${TEST_STRING}"
  refute_output --regexp 'INFO.*'
}

@test "checking warning messages on log level 'error'" {
  export LOG_LEVEL='error'
  run log 'warn' "${TEST_STRING}"
  assert_success
  refute_output --partial "${TEST_STRING}"
  refute_output --regexp 'WARN.*'
}

@test "checking wrong 'LOG_LEVEL' prints a warning and resets the log level" {
  export LOG_LEVEL='invalid'
  run log 'warn' "${TEST_STRING}"
  assert_success
  assert_line --partial "Log level 'invalid' unknown - resetting to log level 'debug'"
}

@test "checking wrong supplied log level arguments prints a warning" {
  export LOG_LEVEL='warn'
  run log 'invalid' "${TEST_STRING}"
  assert_success
  assert_line --partial "Provided log level 'invalid' unknown"
}
