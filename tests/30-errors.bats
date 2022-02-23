load 'bats_support/load'
load 'bats_assert/load'

BATS_TEST_FILE='20-errors           ::'

function setup_file
{
  cd "${ROOT_DIRECTORY}"
  export LOG_LEVEL='tra'
}

@test "${BATS_TEST_FILE} checking 'error.sh'" {
  source src/init.sh 'errors' 'log'
  [[ ${?} -eq 0 ]]
}

function teardown_file
{
  :
}
