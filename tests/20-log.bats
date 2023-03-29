load 'bats_support/load'
load 'bats_assert/load'

BATS_TEST_FILE='20-log              ::'

function setup_file {
  cd "${ROOT_DIRECTORY}" || exit 1
  export LOG_LEVEL='tra'
  export TEST_STRING='jfk FJHAE aea728 djKJ  k/('
}

@test "${BATS_TEST_FILE} logs are sourced and 'log' is a function" {
  source load log
  assert_success
  [[ $(type -t log) == 'function' ]]
  assert_success
}

@test "${BATS_TEST_FILE} checking log output for trace messages" {
  source load log
  assert_success
  run log 'tra' "${TEST_STRING}"
  assert_success
  assert_output --partial "${TEST_STRING}"
  assert_output --regexp '.*\[  .*TRACE.*  \].*'
}

@test "${BATS_TEST_FILE} checking log output for debug messages" {
  source load log
  assert_success
  run log 'deb' "${TEST_STRING}"
  assert_success
  assert_output --partial "${TEST_STRING}"
  assert_output --regexp '.*\[  .*DEBUG.*  \].*'
}

@test "${BATS_TEST_FILE} checking log output for info messages" {
  source load log
  assert_success
  run log 'inf' "${TEST_STRING}"
  assert_success
  assert_output --partial "${TEST_STRING}"
  assert_output --regexp '.*\[   .*INF.*   \].*'
}

@test "${BATS_TEST_FILE} checking log output for warning messages" {
  source load log
  assert_success
  run log 'war' "${TEST_STRING}"
  assert_success
  assert_output --partial "${TEST_STRING}"
  assert_output --regexp '\[\ .*WARNING.* \].*'
}

@test "${BATS_TEST_FILE} checking log output for error messages" {
  source load log
  assert_success
  run log 'err' "${TEST_STRING}"
  assert_success
  assert_output --partial "${TEST_STRING}"
  assert_output --regexp '.*\[  .*ERROR.*  \].*'
}

@test "${BATS_TEST_FILE} checking trace messages on log level 'tra'" {
  export LOG_LEVEL='tra'
  source load log
  assert_success
  run log 'tra' "${TEST_STRING}"
  assert_success
  assert_output --partial "${TEST_STRING}"
  assert_output --regexp '.*\[  .*TRACE.*  \].*'
}

@test "${BATS_TEST_FILE} checking debug messages on log level 'deb'" {
  export LOG_LEVEL='deb'
  source load log
  assert_success
  run log 'deb' "${TEST_STRING}"
  assert_success
  assert_output --partial "${TEST_STRING}"
  assert_output --regexp '.*\[  .*DEBUG.*  \].*'
}

@test "${BATS_TEST_FILE} checking info messages on log level 'inf'" {
  export LOG_LEVEL='inf'
  source load log
  assert_success
  run log 'inf' "${TEST_STRING}"
  assert_success
  assert_output --partial "${TEST_STRING}"
  assert_output --regexp '.*\[   .*INF.*   \].*'
}

@test "${BATS_TEST_FILE} checking warning messages on log level 'war'" {
  export LOG_LEVEL='war'
  source load log
  assert_success
  run log 'war' "${TEST_STRING}"
  assert_success
  assert_output --partial "${TEST_STRING}"
  assert_output --regexp '.*\[ .*WARNING.* \].*'
}

@test "${BATS_TEST_FILE} checking error messages on log level 'error'" {
  export LOG_LEVEL='err'
  source load log
  assert_success
  run log 'err' "${TEST_STRING}"
  assert_success
  assert_output --partial "${TEST_STRING}"
  assert_output --regexp '.*\[  .*ERROR.*  \].*'
}

@test "${BATS_TEST_FILE} checking trace messages on log level 'deb'" {
  export LOG_LEVEL='deb'
  source load log
  assert_success
  run log 'tra' "${TEST_STRING}"
  assert_success
  refute_output --partial "${TEST_STRING}"
  refute_output --regexp '.*\[  .*TRACE.*  \].*'
}


@test "${BATS_TEST_FILE} checking debug messages on log level 'inf'" {
  export LOG_LEVEL='inf'
  source load log
  assert_success
  run log 'deb' "${TEST_STRING}"
  assert_success
  refute_output --partial "${TEST_STRING}"
  refute_output --regexp '.*\[  .*DEBUG.*  \].*'
}


@test "${BATS_TEST_FILE} checking info messages on log level 'war'" {
  export LOG_LEVEL='war'
  source load log
  assert_success
  run log 'inf' "${TEST_STRING}"
  assert_success
  refute_output --partial "${TEST_STRING}"
  refute_output --regexp '.*\[   .*INF.*   \].*'
}


@test "${BATS_TEST_FILE} checking warning messages on log level 'err'" {
  export LOG_LEVEL='err'
  source load log
  assert_success
  run log 'war' "${TEST_STRING}"
  assert_success
  refute_output --partial "${TEST_STRING}"
  refute_output --regexp '.*\[ .*WARNING.* \].*'
}

function teardown_file {
  :
}
