load 'bats_support/load'
load 'bats_assert/load'

BATS_TEST_FILE='20-errors           ::'

function setup_file
{
  cd "${ROOT_DIRECTORY}" || exit 1
  export LOG_LEVEL='tra'
}

@test "${BATS_TEST_FILE} checking 'error.sh' is sourced correctly" {
  source src/init.sh 'errors' 'log'
  # shellcheck disable=SC2181
  [[ ${?} -eq 0 ]]
}

function teardown_file
{
  :
}
