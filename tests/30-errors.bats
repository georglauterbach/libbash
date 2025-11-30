bats_require_minimum_version '1.10.0'

load 'bats_support/load'
load 'bats_assert/load'

# shellcheck disable=SC2034
BATS_TEST_NAME_PREFIX='30-errors           :: '

function setup_file() {
  export LOG_LEVEL='trace'
}

@test "module is correctly sourced" {
  run bash -c 'source libbash "errors"'
  assert_success

  run bash -c 'source libbash "errors" ; trap ;'
  assert_success
  assert_output --regexp 'log_unexpected_error.*ERR'
}

@test "module is correctly sourced with other modules" {
  run bash -c 'source libbash "errors" "log" "utils"'
  assert_success
}

@test "'escape_newlines' works" {
  export LOG_LEVEL='error'
  # shellcheck source=../libbash
  source libbash 'errors'
  trap - ERR

  run remove_newlines
  assert_success
  assert_output 'unknown'

  run remove_newlines $'a\nb\nc'
  assert_success
  assert_output 'a b c'

  run remove_newlines $'These\nare\nlines'
  assert_success
  assert_output 'These are lines'

  # shellcheck disable=SC2016
  run remove_newlines $'These\nare\nlines $(and a command)'
  assert_success
  # shellcheck disable=SC2016
  assert_output 'These are lines $(and a command)'
}

@test "'apply_shell_expansion' works" {
  export LOG_LEVEL='error'
  # shellcheck source=../libbash
  source libbash 'errors'
  trap - ERR

  run apply_shell_expansion
  assert_success
  assert_output 'unknown'

  run apply_shell_expansion 'some String'
  assert_success
  assert_output 'some String'

  # shellcheck disable=SC2016
  run apply_shell_expansion '$(eval date)'
  assert_success
  # shellcheck disable=SC2016
  assert_output '$(eval date)'

  export __SOME_VAR='This is a message'
  # shellcheck disable=SC2016
  run apply_shell_expansion 'Message: ${__SOME_VAR}'
  assert_success
  assert_output 'Message: This is a message'

  # shellcheck disable=SC2016
  run apply_shell_expansion '$(${__SOME_VAR})'
  assert_success
  # shellcheck disable=SC2016
  assert_output '$(This is a message)'

  # shellcheck disable=SC2016
  run apply_shell_expansion '${__SOME_VAR}; $(eval date)'
  assert_success
  # shellcheck disable=SC2016
  assert_output 'This is a message; $(eval date)'
}

@test "provoking a fault triggers an error" {
  run bash -c "( LOG_LEVEL=error ; source libbash 'errors' ; log 'warn' 'Test' ; )"
  assert_failure
  assert_output --partial "log module not loaded but 'log' called with log level other than 'error' (arguments: warn Test)"
}

@test "log output on error is correct" {
  run bash -c '( LOG_LEVEL=error ; source libbash "errors" "log" "utils" ; false ; )'
  assert_failure
  assert_output --partial 'unexpected error occurred:'
  assert_line '    script:     prompt or outside of function'
  assert_line '    function:   prompt or outside of function'
  assert_line '    command:'
  assert_line '      plain:    false'
  assert_line '      expanded: false'
  assert_line '    line:       1'
  assert_line '    exit code:  1'

  run -127 bash -c '( LOG_LEVEL=error ; source libbash "errors" "log" "utils" ; function __x() { __noTAcommand ; } ; __x ; )'
  assert_failure
  assert_output --partial 'unexpected error occurred:'
  assert_line '    script:     prompt or outside of function'
  assert_line '    function:   __x'
  assert_line '    command:'
  assert_line '      plain:    __noTAcommand'
  assert_line '      expanded: __noTAcommand'
  assert_line '    line:       1'
  assert_line '    exit code:  127'
}
