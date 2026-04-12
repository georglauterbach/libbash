# libbash

[![Unit Tests](https://img.shields.io/github/actions/workflow/status/georglauterbach/libbash/test.yml?branch=main&color=blue&label=TESTS&logo=github&logoColor=white&style=for-the-badge)](https://github.com/georglauterbach/libbash/actions/workflows/test.yml) [![Linters](https://img.shields.io/github/actions/workflow/status/georglauterbach/libbash/lint.yml?branch=main&color=blue&label=LINTERS&logo=github&logoColor=white&style=for-the-badge)](https://github.com/georglauterbach/libbash/actions/workflows/lint.yml)

## About

`libbash` is a collection of useful functions, checked by [_ShellCheck_](https://github.com/koalaman/shellcheck) and by [_BATS_](https://github.com/bats-core/bats-core), for your **Bash** scripts. `libbash` is **not** POSIX compatible and supports Bash v5.0.0 or newer.

## Usage

Copy the file [`libbash`](./libbash) into your project. You can then `source` this file from your scripts:

```bash
source libbash 'errors' 'log'
SCRIPT='some script'
```

This example assumes the script (that the above code lives in) is executed (or sourced) from the same directory it lives in. To source `libbash` independently of the invocation location, you may use this more elaborate call to `source`:

```bash
source "$(realpath -eL "$(dirname "${BASH_SOURCE[0]}")/libbash")" 'errors' 'log'
SCRIPT='some script'
```

## Conventions

`libbash` loads functions from modules with the following naming convention: A function from the `utils` modules called `exit_checked` is loaded as `libbash::utils::exit_checked`. Certain modules (especially `errors`) export functions like `libbash::errors::__apply_shell_expansion__`. Functions whose names begin and end with `__` are not supposed to be used nor altered by you. They are used internally by `libbash`. You can get a list of all functions loaded by `libbash` by running `declare -F | grep libbash`.

`libbash` also loads environment variables. You can get a list of all environment variables loaded by `libbash` by running `env | grep -i ^LIBBASH__`.

## Modules

When you load `libbash`, you don't have to use all the code that `libbash` actually contains. `libbash` provides different modules. When you source the `load` script, you can provide the modules you would like to use as arguments.

### `errors`

This module provides functions to show and handle errors. Also sets `set -E -o pipefail` and `shopt -s inherit_errexit`.

### `log`

This module provides the `log` function. `log` is invoked by first specifying a log level and then the message: `log 'info' 'Some info message'`. Log level can be one of

1. `error`
2. `warn`
3. `info`
4. `debug`
5. `trace`

You can supply more arguments to `log`, but the first argument must be the log level. This function is guaranteed to not fail, i.e. it always returns with exit code 0, even when an issue is detected.

The log level itself can be changed anytime by setting `LOG_LEVEL` to one of the levels described above. Naturally, messages below the log level are not shown. The default log level is `info`.

### `utils`

This module provides various miscellaneous functions, like `libbash::utils::escape` to libbash::utils::escape characters or `libbash::utils::exit_failure` to exit with an error. Take a look at the function `__libbash::__load_module__::utils` in [`libbash`](./libbash) to see all the functions in this module.

## Environment Variables

When `libbash` is loaded, it uses variables that start with `__LIBBASH` to manage internal state. These variables are marked with `readonly`, hence they are not modifiable. You are **not** supposed to use these variables! Due to the way Bash handles scoping, having these variables in the global scope is inevitable.
