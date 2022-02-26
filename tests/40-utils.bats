load 'bats_support/load'
load 'bats_assert/load'

BATS_TEST_FILE='40-utils            ::'

function setup_file
{
  cd "${ROOT_DIRECTORY}" || exit 1
  export LOG_LEVEL='tra'
}

@test "${BATS_TEST_FILE} 'utils' is correctly sourced" {
  ( source load 'errors' ; )
  assert_success
}

@test "${BATS_TEST_FILE} 'utils.sh' is correctly sourced with other modules" {
  ( source load 'errors' 'log' 'utils' )
  assert_success
  ( source load 'utils' 'errors' 'log' )
  assert_success
}

@test "${BATS_TEST_FILE} 'line_is_comment_or_blank' works correctly" {
  source load 'utils'
  assert_success

  run line_is_comment_or_blank ' '
  assert_success

  run line_is_comment_or_blank '# '
  assert_success

  run line_is_comment_or_blank ' #    '
  assert_success

  run line_is_comment_or_blank ' # ' '//'
  assert_failure

  run line_is_comment_or_blank ' //' '//'
  assert_success

  run line_is_comment_or_blank '//  ' '//'
  assert_success

  run line_is_comment_or_blank ' dnawdjka'
  assert_failure

  run line_is_comment_or_blank 'dnawdjka'
  assert_failure

  run line_is_comment_or_blank 'd#nawdjka'
  assert_failure
}

@test "${BATS_TEST_FILE} 'escape' works correctly" {
  source load 'utils'
  assert_success

  set -E
  shopt -s inherit_errexit

  run escape 'abc.bca' '.'
  assert_output 'abc\.bca'

  run escape 'abc.b.ca' '.'
  assert_output 'abc\.b\.ca'

  run escape 'abcbca' '.'
  assert_output 'abcbca'

  run escape
  assert_failure 1

  # shellcheck disable=SC1003
  run escape 'a' '\\'
  assert_failure 2

  run escape 'a'
  assert_failure 3

  run escape 'a' 'ab'
  assert_failure 4
}

@test "${BATS_TEST_FILE} 'escape_backslash' works correctly" {
  source load 'utils'
  assert_success

  # shellcheck disable=SC1003
  run escape_backslash '\'
  # shellcheck disable=SC1003
  assert_output '\\'

  # shellcheck disable=SC1003
  run escape_backslash '\\'
  # shellcheck disable=SC1003
  assert_output '\\\\'

  # shellcheck disable=SC1003
  run escape_backslash '\ \\'
  # shellcheck disable=SC1003
  assert_output '\\ \\\\'
}

@test "${BATS_TEST_FILE} exit wrappers work correctly" {
  source load 'utils'
  assert_success

  run exit_success
  assert_success

  run exit_failure 1
  assert_failure 1

  run exit_failure 2
  assert_failure 2

  run exit_failure 0
  assert_failure 1
  assert_output --partial "'exit_failure' was called with exit code 0 or >127"

  run exit_failure a
  assert_failure 1
  assert_output --partial "'exit_failure' was called with non-number exit code"

  function test_exit_failure_and_show_callstack
  {
    exit_failure_and_show_callstack
  }

  run test_exit_failure_and_show_callstack
  assert_failure 1
  assert_output --partial 'call stack (most recent call first):'
  assert_output --partial 'exit_failure_and_show_callstack'
}

function teardown_file
{
  :
}
