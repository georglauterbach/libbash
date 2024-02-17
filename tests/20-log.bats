bats_require_minimum_version '1.10.0'

load 'bats_support/load'
load 'bats_assert/load'

BATS_TEST_NAME_PREFIX='20-log              :: '

function setup_file() {
  cd "${ROOT_DIRECTORY}" || exit 1
  export LOG_LEVEL='tra'
  export TEST_STRING='jfk FJHAE aea728 djKJ  k/('
}

function setup() { source load log ; }

@test "logs are sourced and 'log' is a function" {
  run bash -c 'source load "log"'
  assert_success

  source load log
  [[ $(type -t log) == 'function' ]]
  assert_success
}

@test "checking log output for trace messages" {
  run log 'tra' "${TEST_STRING}"
  assert_success
  assert_line --partial "${TEST_STRING}"
  assert_line --regexp 'TRACE.*'
}

@test "checking log output for debug messages" {
  run log 'deb' "${TEST_STRING}"
  assert_success
  assert_line --partial "${TEST_STRING}"
  assert_line --regexp 'DEBUG.*'
}

@test "checking log output for info messages" {
  run log 'inf' "${TEST_STRING}"
  assert_success
  assert_line --partial "${TEST_STRING}"
  assert_line --regexp 'INFO.*'
}

@test "checking log output for warning messages" {
  run log 'war' "${TEST_STRING}"
  assert_success
  assert_line --partial "${TEST_STRING}"
  assert_line --regexp 'WARN.*'
}

@test "checking log output for error messages" {
  run log 'err' "${TEST_STRING}"
  assert_success
  assert_line --partial "${TEST_STRING}"
  assert_line --regexp 'ERROR.*'
}

@test "checking trace messages on log level 'tra'" {
  export LOG_LEVEL='tra'
  run log 'tra' "${TEST_STRING}"
  assert_success
  assert_line --partial "${TEST_STRING}"
  assert_line --regexp 'TRACE.*'
}

@test "checking debug messages on log level 'deb'" {
  export LOG_LEVEL='deb'
  run log 'deb' "${TEST_STRING}"
  assert_success
  assert_line --partial "${TEST_STRING}"
  assert_line --regexp 'DEBUG.*'
}

@test "checking info messages on log level 'inf'" {
  export LOG_LEVEL='inf'
  run log 'inf' "${TEST_STRING}"
  assert_success
  assert_line --partial "${TEST_STRING}"
  assert_line --regexp 'INFO.*'
}

@test "checking warning messages on log level 'war'" {
  export LOG_LEVEL='war'
  run log 'war' "${TEST_STRING}"
  assert_success
  assert_line --partial "${TEST_STRING}"
  assert_line --regexp 'WARN.*'
}

@test "checking error messages on log level 'error'" {
  export LOG_LEVEL='err'
  run log 'err' "${TEST_STRING}"
  assert_success
  assert_line --partial "${TEST_STRING}"
  assert_line --regexp 'ERROR.*'
}

@test "checking trace messages on log level 'deb'" {
  export LOG_LEVEL='deb'
  run log 'tra' "${TEST_STRING}"
  assert_success
  refute_output --partial "${TEST_STRING}"
  refute_output --regexp 'TRACE.*'
}


@test "checking debug messages on log level 'inf'" {
  export LOG_LEVEL='inf'
  run log 'deb' "${TEST_STRING}"
  assert_success
  refute_output --partial "${TEST_STRING}"
  refute_output --regexp 'DEBUG.*'
}


@test "checking info messages on log level 'war'" {
  export LOG_LEVEL='war'
  run log 'inf' "${TEST_STRING}"
  assert_success
  refute_output --partial "${TEST_STRING}"
  refute_output --regexp 'INFO.*'
}


@test "checking warning messages on log level 'err'" {
  export LOG_LEVEL='err'
  run log 'war' "${TEST_STRING}"
  assert_success
  refute_output --partial "${TEST_STRING}"
  refute_output --regexp 'WARN.*'
}
