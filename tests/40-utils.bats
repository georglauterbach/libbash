bats_require_minimum_version '1.10.0'

load 'bats_support/load'
load 'bats_assert/load'

BATS_TEST_NAME_PREFIX='40-utils            :: '

function setup_file() {
  cd "${ROOT_DIRECTORY}" || exit 1
  export LOG_LEVEL='tra'
}

function setup() { source load 'log' 'utils' ; }

@test "'utils' is correctly sourced" {
  run bash -c "( source load 'utils' ; )"
  assert_success
}

@test "'utils' is correctly sourced with other modules" {
  run bash -c "( source load 'errors' 'log' 'utils' ; )"
  assert_success

  run bash -c "( source load 'utils' 'errors' 'log' ; )"
  assert_success
}

@test "'split_into_array' works correctly" {
  run split_into_array
  assert_failure
  assert_output --partial 'Array name is required'

  run split_into_array FOO
  assert_failure
  assert_output --partial 'String to split is required'

  local PREFIX="export LOG_LEVEL=err ; source load 'log' 'utils' ; split_into_array FOO"
  # shellcheck disable=SC2016
  local SUFFIX='; echo "${FOO[*]}"'

  run bash -c "${PREFIX} 'a:b:c:d' ${SUFFIX}"
  assert_success
  assert_output 'a b c d'

  run bash -c "${PREFIX} 'a:b:c:d' 'x' ${SUFFIX}"
  assert_success
  assert_output 'a:b:c:d'

  run bash -c "${PREFIX} 'a:b:c:d' 'a' ${SUFFIX}"
  assert_success
  assert_output ':b:c:d'

  run bash -c "${PREFIX} 'a:b:c:d' 'b' ${SUFFIX}"
  assert_success
  assert_output 'a: :c:d'

  run bash -c "${PREFIX} 'a:b:c:d' 'd' ${SUFFIX}"
  assert_success
  assert_output 'a:b:c:'

  run bash -c "${PREFIX} '/usr/local/bin' '\/' ${SUFFIX}"
  assert_success
  assert_output 'usr local bin'

  run bash -c "${PREFIX} 'a: b: c: d' ': ' ${SUFFIX}"
  assert_success
  assert_output 'a b c d'

  run bash -c "${PREFIX} ' :a :b :c :d' ' :' ${SUFFIX}"
  assert_success
  assert_output 'a b c d'

  run bash -c "${PREFIX} ':a :b :c :d' ' :' ${SUFFIX}"
  assert_success
  assert_output ':a b c d'

  run bash -c "${PREFIX} '[a[b[c[d' '\[' ${SUFFIX}"
  assert_success
  assert_output 'a b c d'

  run bash -c "${PREFIX} 'a b c d' ' ' ${SUFFIX}"
  assert_success
  assert_output 'a b c d'

  run bash -c "${PREFIX} 'a lol b lol c lol d' ' lol ' ${SUFFIX}"
  assert_success
  assert_output 'a b c d'
}

@test "'line_is_comment_or_blank' works correctly" {
  run line_is_comment_or_blank '# nkdadjn'
  assert_success
  run line_is_comment_or_blank '    # nkdadjn'
  assert_success
  run line_is_comment_or_blank '    #### nk#dadjn #'
  assert_success
  run line_is_comment_or_blank '#### nkdadjn'
  assert_success
  run line_is_comment_or_blank '// kdawnjd' '//'
  assert_success
  run line_is_comment_or_blank '   // kdawnjd' '//'
  assert_success
  run line_is_comment_or_blank '// kdawnj//d' '//'
  assert_success
  run line_is_comment_or_blank '//' '//'
  assert_success
  run line_is_comment_or_blank ''
  assert_success

  run line_is_comment_or_blank 'nkdadjn'
  assert_failure
  run line_is_comment_or_blank 'n#kdadjn'
  assert_failure
  run line_is_comment_or_blank 'nkdadjn #'
  assert_failure
  run line_is_comment_or_blank '/' '//'
  assert_failure

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

@test "'escape' works correctly" {
  set -E
  shopt -s inherit_errexit

  run escape 'abc.bca' '.'
  assert_output 'abc\.bca'

  run escape 'abc.b.ca' '.'
  assert_output 'abc\.b\.ca'

  run escape 'abcbca' '.'
  assert_output 'abcbca'

  run escape 'uff' 'f'
  assert_success
  assert_output 'u\f\f'

  # shellcheck disable=SC1003
  run escape 'dka' '\\'
  assert_failure
  assert_output --partial 'Escape character is not allowed to be or contain a backslash'
  assert_output --partial "(use 'escape_backslash')"

  run escape
  assert_failure
  assert_output --partial 'No string to be escaped provided'

  run escape 'dka'
  assert_failure
  assert_output --partial 'No escape character(s) provided'
}

@test "'escape_backslash' works correctly" {
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

  # shellcheck disable=SC1003
  run escape_backslash '\'
  assert_success
  # shellcheck disable=SC1003
  assert_output '\\'

  # shellcheck disable=SC1003
  run escape_backslash '\\'
  assert_success
  # shellcheck disable=SC1003
  assert_output '\\\\'

  run escape_backslash 'a'
  assert_success
  assert_output 'a'

  run escape_backslash '\a'
  assert_success
  assert_output '\\a'

  # shellcheck disable=SC1003
  run escape_backslash 'a\'
  assert_success
  # shellcheck disable=SC1003
  assert_output 'a\\'

  run escape_backslash 'a\a'
  assert_success
  assert_output 'a\\a'

  run escape_backslash 'a\\\aa'
  assert_success
  assert_output 'a\\\\\\aa'
}

@test "exit wrappers work correctly" {
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

  run exit_failure 2 'oh my god!'
  assert_failure 2
  assert_output --partial 'oh my god!'

  function test_exit_failure_show_callstack
  {
    exit_failure_show_callstack 4 'noooooo'
  }

  run test_exit_failure_show_callstack
  assert_failure 4
  assert_output --partial 'call stack (most recent call first):'
  assert_output --partial 'exit_failure_show_callstack'
  assert_output --partial 'noooooo'
}

@test "return wrappers work correctly" {
  run return_success
  assert_success

  run return_failure 1
  assert_failure 1

  run return_failure 2
  assert_failure 2

  run return_failure 0
  assert_failure 1
  assert_output --partial "'return_failure' was called with exit code 0 or >127"

  run return_failure a
  assert_failure 1
  assert_output --partial "'return_failure' was called with non-number exit code"

  run return_failure 2 'Hey :D'
  assert_failure
  assert_output --partial 'Hey :D'
}

@test "'var_is_set_and_not_empty' works correctly" {
  run var_is_set_and_not_empty
  assert_failure

  run var_is_set_and_not_empty ''
  assert_failure

  run var_is_set_and_not_empty 'a'
  assert_success
}

@test "'ask_question' works correctly" {
  TEST_STRING='no one knows'

  run ask_question
  assert_failure
  assert_output --partial 'No question provided'

  run ask_question 'Is P=NP?'
  assert_failure
  assert_output --partial 'No variable to store result in provided'

  ask_question 'Is P=NP' TEST_VARIABLE <<< "${TEST_STRING}"
  [[ ${TEST_VARIABLE} == "${TEST_STRING}" ]]

  ask_question 'Is P=NP' TEST_VARIABLE <<< ""
  [[ -z ${TEST_VARIABLE} ]]
}

@test "'ask_yes_no_question' works correctly" {
  TEST_STRING='no one knows'

  run ask_yes_no_question
  assert_failure
  assert_output --partial 'No question provided'

  # default = no
  run bash -c "source load 'log' 'utils' ; ask_yes_no_question 'Is P=NP' <<< ''"
  assert_failure

  run bash -c "source load 'log' 'utils' ; ask_yes_no_question 'Is P=NP' y <<< ''"
  assert_success

  run bash -c "source load 'log' 'utils' ; ask_yes_no_question 'Is P=NP' y <<< 'y'"
  assert_success

  run bash -c "source load 'log' 'utils' ; ask_yes_no_question 'Is P=NP' n <<< 'y'"
  assert_success

  run bash -c "source load 'log' 'utils' ; ask_yes_no_question 'Is P=NP' n <<< 'yes'"
  assert_success

  run bash -c "source load 'log' 'utils' ; ask_yes_no_question 'Is P=NP' y <<< 'Yes'"
  assert_success

  run bash -c "source load 'log' 'utils' ; ask_yes_no_question 'Is P=NP' y <<< 'Y'"
  assert_success

  run bash -c "source load 'log' 'utils' ; ask_yes_no_question 'Is P=NP' n <<< 'Y'"
  assert_success

  run bash -c "source load 'log' 'utils' ; ask_yes_no_question 'Is P=NP' y <<< 'n'"
  assert_failure

  run bash -c "source load 'log' 'utils' ; ask_yes_no_question 'Is P=NP' y <<< 'N'"
  assert_failure

  run bash -c "source load 'log' 'utils' ; ask_yes_no_question 'Is P=NP' y <<< 'no'"
  assert_failure

  run bash -c "source load 'log' 'utils' ; ask_yes_no_question 'Is P=NP' y <<< 'No'"
  assert_failure

  run bash -c "source load 'log' 'utils' ; ask_yes_no_question 'Is P=NP' jibberish <<< 'y'"
  assert_success

  run bash -c "source load 'log' 'utils' ; ask_yes_no_question 'Is P=NP' jibberish <<< 'n'"
  assert_failure
}

@test "executble in PATH checks work correctly" {
  run is_in_path nadwadkwdnakdnwndakwdnakdnwdnakwdnakjwdnakwjda
  assert_failure

  run is_in_path ls
  assert_success

  run is_not_in_path nadwadkwdnakdnwndakwdnakdnwdnakwdnakjwdnakwjda
  assert_success

  run is_not_in_path ls
  assert_failure
}
