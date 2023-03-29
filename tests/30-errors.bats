load 'bats_support/load'
load 'bats_assert/load'

BATS_TEST_FILE='30-errors           ::'

function setup_file {
  cd "${ROOT_DIRECTORY}" || exit 1
  export LOG_LEVEL='tra'
}

@test "${BATS_TEST_FILE} 'errors' is correctly sourced" {
  ( source load 'utils' ; )
  assert_success
}

@test "${BATS_TEST_FILE} 'errors' is correctly sourced with other modules" {
  ( source load 'errors' 'log' 'utils' )
  assert_success
}

function teardown_file {
  :
}
