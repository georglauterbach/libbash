# shellcheck disable=SC2030,SC2031

bats_require_minimum_version '1.10.0'

load 'bats_support/load'
load 'bats_assert/load'

# shellcheck disable=SC2034
BATS_TEST_NAME_PREFIX='40-utils            :: '

function setup_file() {
  export LOG_LEVEL='debug'
}

# shellcheck source=../libbash
function setup() { source libbash 'log' 'utils' ; }

@test "module is correctly sourced" {
  run bash -c "( source libbash 'utils' ; )"
  assert_success
}

@test "module is correctly sourced with other modules" {
  run bash -c "( source libbash 'errors' 'log' 'utils' ; )"
  assert_success

  run bash -c "( source libbash 'utils' 'errors' 'log' ; )"
  assert_success
}

@test "'split_into_array' works correctly" {
  run split_into_array
  assert_failure
  assert_output --partial 'array name is required'

  run split_into_array FOO
  assert_failure
  assert_output --partial 'string to split is required'

  local PREFIX="export LOG_LEVEL=error ; source libbash 'log' 'utils' ; split_into_array FOO"
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

@test "'var_is_set' works correctly" {
  run var_is_set
  assert_failure

  unset __DEFINITELY_UNSET__
  run var_is_set __DEFINITELY_UNSET__
  assert_failure

  export __DEFINITELY_SET__=
  run var_is_set __DEFINITELY_SET__
  assert_success

  export __DEFINITELY_SET__='somevalue'
  run var_is_set __DEFINITELY_SET__
  assert_success
}

@test "'var_is_set_and_not_empty' works correctly" {
  run var_is_set_and_not_empty
  assert_failure

  unset __DEFINITELY_UNSET__
  run var_is_set_and_not_empty __DEFINITELY_UNSET__
  assert_failure

  export __DEFINITELY_SET__=
  run var_is_set_and_not_empty __DEFINITELY_SET__
  assert_failure

  export __DEFINITELY_SET__='somevalue'
  run var_is_set __DEFINITELY_SET__
  assert_success
}

@test "'parameter_is_not_empty' works correctly" {
  run parameter_is_not_empty
  assert_failure

  run parameter_is_not_empty ''
  assert_failure

  run parameter_is_not_empty 'a'
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
  run bash -c "source libbash 'log' 'utils' ; ask_yes_no_question 'Is P=NP' <<< ''"
  assert_failure

  run bash -c "source libbash 'log' 'utils' ; ask_yes_no_question 'Is P=NP' y <<< ''"
  assert_success

  run bash -c "source libbash 'log' 'utils' ; ask_yes_no_question 'Is P=NP' y <<< 'y'"
  assert_success

  run bash -c "source libbash 'log' 'utils' ; ask_yes_no_question 'Is P=NP' n <<< 'y'"
  assert_success

  run bash -c "source libbash 'log' 'utils' ; ask_yes_no_question 'Is P=NP' n <<< 'yes'"
  assert_success

  run bash -c "source libbash 'log' 'utils' ; ask_yes_no_question 'Is P=NP' y <<< 'Yes'"
  assert_success

  run bash -c "source libbash 'log' 'utils' ; ask_yes_no_question 'Is P=NP' y <<< 'Y'"
  assert_success

  run bash -c "source libbash 'log' 'utils' ; ask_yes_no_question 'Is P=NP' n <<< 'Y'"
  assert_success

  run bash -c "source libbash 'log' 'utils' ; ask_yes_no_question 'Is P=NP' y <<< 'n'"
  assert_failure

  run bash -c "source libbash 'log' 'utils' ; ask_yes_no_question 'Is P=NP' y <<< 'N'"
  assert_failure

  run bash -c "source libbash 'log' 'utils' ; ask_yes_no_question 'Is P=NP' y <<< 'no'"
  assert_failure

  run bash -c "source libbash 'log' 'utils' ; ask_yes_no_question 'Is P=NP' y <<< 'No'"
  assert_failure

  run bash -c "source libbash 'log' 'utils' ; ask_yes_no_question 'Is P=NP' jibberish <<< 'y'"
  assert_success

  run bash -c "source libbash 'log' 'utils' ; ask_yes_no_question 'Is P=NP' jibberish <<< 'n'"
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

@test "dir is empty or not works correctly" {
  local TEST_DIR='/tmp/.libbash_tests/test_dir'
  rm -rf "${TEST_DIR}"
  mkdir -p "${TEST_DIR}"

  run dir_is_empty "${TEST_DIR}"
  assert_success

  run dir_is_not_empty "${TEST_DIR}"
  assert_failure

  touch "${TEST_DIR}/test_file"

  run dir_is_empty "${TEST_DIR}"
  assert_failure

  run dir_is_not_empty "${TEST_DIR}"
  assert_success

  rm "${TEST_DIR}/test_file"
  mkdir "${TEST_DIR}/test_dir_2"

  run dir_is_empty "${TEST_DIR}"
  assert_failure

  run dir_is_not_empty "${TEST_DIR}"
  assert_success

  rmdir "${TEST_DIR}/test_dir_2"
  touch "${TEST_DIR}/.hidden_file"

  run dir_is_empty "${TEST_DIR}"
  assert_failure

  run dir_is_not_empty "${TEST_DIR}"
  assert_success
}

@test "value_is_true should work" {
  # shellcheck disable=SC2034
  local                       \
    SHOULD_BE_TRUE_1='TRUE'   \
    SHOULD_BE_TRUE_2='true'   \
    SHOULD_BE_TRUE_3='True'   \
    SHOULD_BE_TRUE_4='TRue'   \
    SHOULD_BE_TRUE_5='TRUe'   \
    SHOULD_BE_TRUE_6='tRUE'   \
    SHOULD_BE_TRUE_7='trUE'   \
    SHOULD_BE_TRUE_8='truE'   \
    SHOULD_BE_TRUE_9='trUE'   \
    SHOULD_BE_TRUE_10='YES'   \
    SHOULD_BE_TRUE_11='yes'   \
    SHOULD_BE_TRUE_12='y'     \
    SHOULD_BE_TRUE_13='YeS'   \
                              \
    SHOULD_BE_FALSE_1='False' \
    SHOULD_BE_FALSE_2='false' \
    SHOULD_BE_FALSE_3='FALSE' \
    SHOULD_BE_FALSE_4='No'    \
    SHOULD_BE_FALSE_5='no'    \
    SHOULD_BE_FALSE_6='ye'

  run value_is_true SHOULD_BE_TRUE_1
  assert_success

  run value_is_true SHOULD_BE_TRUE_2
  assert_success

  run value_is_true SHOULD_BE_TRUE_3
  assert_success

  run value_is_true SHOULD_BE_TRUE_4
  assert_success

  run value_is_true SHOULD_BE_TRUE_5
  assert_success

  run value_is_true SHOULD_BE_TRUE_6
  assert_success

  run value_is_true SHOULD_BE_TRUE_7
  assert_success

  run value_is_true SHOULD_BE_TRUE_8
  assert_success

  run value_is_true SHOULD_BE_TRUE_9
  assert_success

  run value_is_true SHOULD_BE_TRUE_10
  assert_success

  run value_is_true SHOULD_BE_TRUE_11
  assert_success

  run value_is_true SHOULD_BE_TRUE_12
  assert_success

  run value_is_true SHOULD_BE_TRUE_13
  assert_success

  run value_is_true SHOULD_BE_FALSE_1
  assert_failure

  run value_is_true SHOULD_BE_FALSE_2
  assert_failure

  run value_is_true SHOULD_BE_FALSE_3
  assert_failure

  run value_is_true SHOULD_BE_FALSE_4
  assert_failure

  run value_is_true SHOULD_BE_FALSE_5
  assert_failure

  run value_is_true SHOULD_BE_FALSE_6
  assert_failure
}
