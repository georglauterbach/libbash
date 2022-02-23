load 'bats_support/load'
load 'bats_assert/load'

# shellcheck disable=SC2154,SC2164
# shellcheck disable=SC2030,SC2031
# shellcheck disable=SC2181

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
