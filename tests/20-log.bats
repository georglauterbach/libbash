load 'bats_support/load'
load 'bats_assert/load'

BATS_TEST_FILE='20-log              ::'

function setup_file
{
  cd "${ROOT_DIRECTORY}" || exit 1
  export LOG_LEVEL='tra'
  export TEST_STRING='jfk FJHAE aea728 djKJ  k/('
}

@test "${BATS_TEST_FILE} logs are sourced and 'notify' is a function" {
  source src/init.sh log
  assert_success
  [[ $(type -t notify) == 'function' ]]
  assert_success
}

@test "${BATS_TEST_FILE} checking log output for trace messages" {
  source src/init.sh log
  assert_success
  run notify 'tra' "${TEST_STRING}"
  assert_success
  assert_output --partial "${TEST_STRING}"
  assert_output --regexp '.*[  TRACE  ].*'
}

@test "${BATS_TEST_FILE} checking log output for debug messages" {
  source src/init.sh log
  assert_success
  run notify 'deb' "${TEST_STRING}"
  assert_success
  assert_output --partial "${TEST_STRING}"
  assert_output --regexp '.*[  DEBUG  ].*'
}

@test "${BATS_TEST_FILE} checking log output for info messages" {
  source src/init.sh log
  assert_success
  run notify 'inf' "${TEST_STRING}"
  assert_success
  assert_output --partial "${TEST_STRING}"
  assert_output --regexp '.*[   INF   ].*'
}

@test "${BATS_TEST_FILE} checking log output for warning messages" {
  source src/init.sh log
  assert_success
  run notify 'war' "${TEST_STRING}"
  assert_success
  assert_output --partial "${TEST_STRING}"
  assert_output --regexp '.*[ WARNING ].*'
}

@test "${BATS_TEST_FILE} checking log output for error messages" {
  source src/init.sh log
  assert_success
  run notify 'err' "${TEST_STRING}"
  assert_success
  assert_output --partial "${TEST_STRING}"
  assert_output --regexp '.*[  ERROR  ].*'
}

@test "${BATS_TEST_FILE} checking trace messages on log level 'tra'" {
  export LOG_LEVEL='tra'
  source src/init.sh log
  assert_success
  run notify 'tra' "${TEST_STRING}"
  assert_success
  assert_output --partial "${TEST_STRING}"
  assert_output --regexp '.*[  TRACE  ].*'
}

@test "${BATS_TEST_FILE} checking debug messages on log level 'deb'" {
  export LOG_LEVEL='deb'
  source src/init.sh log
  assert_success
  run notify 'deb' "${TEST_STRING}"
  assert_success
  assert_output --partial "${TEST_STRING}"
  assert_output --regexp '.*[  DEBUG  ].*'
}

@test "${BATS_TEST_FILE} checking info messages on log level 'inf'" {
  export LOG_LEVEL='inf'
  source src/init.sh log
  assert_success
  run notify 'inf' "${TEST_STRING}"
  assert_success
  assert_output --partial "${TEST_STRING}"
  assert_output --regexp '.*[   INF   ].*'
}

@test "${BATS_TEST_FILE} checking warning messages on log level 'war'" {
  export LOG_LEVEL='war'
  source src/init.sh log
  assert_success
  run notify 'war' "${TEST_STRING}"
  assert_success
  assert_output --partial "${TEST_STRING}"
  assert_output --regexp '.*[ WARNING ].*'
}

@test "${BATS_TEST_FILE} checking error messages on log level 'error'" {
  export LOG_LEVEL='err'
  source src/init.sh log
  assert_success
  run notify 'err' "${TEST_STRING}"
  assert_success
  assert_output --partial "${TEST_STRING}"
  assert_output --regexp '.*[  ERROR  ].*'
}

@test "${BATS_TEST_FILE} checking trace messages on log level 'deb'" {
  export LOG_LEVEL='deb'
  source src/init.sh log
  assert_success
  run notify 'tra' "${TEST_STRING}"
  assert_success
  refute_output --partial "${TEST_STRING}"
  refute_output --regexp '.*[  TRACE  ].*'
}


@test "${BATS_TEST_FILE} checking debug messages on log level 'inf'" {
  export LOG_LEVEL='inf'
  source src/init.sh log
  assert_success
  run notify 'deb' "${TEST_STRING}"
  assert_success
  refute_output --partial "${TEST_STRING}"
  refute_output --regexp '.*[  DEBUG  ].*'
}


@test "${BATS_TEST_FILE} checking info messages on log level 'war'" {
  export LOG_LEVEL='war'
  source src/init.sh log
  assert_success
  run notify 'inf' "${TEST_STRING}"
  assert_success
  refute_output --partial "${TEST_STRING}"
  refute_output --regexp '.*[   INF   ].*'
}


@test "${BATS_TEST_FILE} checking warning messages on log level 'err'" {
  export LOG_LEVEL='err'
  source src/init.sh log
  assert_success
  run notify 'war' "${TEST_STRING}"
  assert_success
  refute_output --partial "${TEST_STRING}"
  refute_output --regexp '.*[ WARNING ].*'
}

function teardown_file
{
  :
}
