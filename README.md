# libbash

[![Unit Tests](https://img.shields.io/github/actions/workflow/status/georglauterbach/libbash/test-bats.yml?branch=main&color=blue&label=UNIT%20TESTS&logo=github&logoColor=white&style=for-the-badge)](https://github.com/georglauterbach/libbash/actions/workflows/test-bats.yml) [![Linters](https://img.shields.io/github/actions/workflow/status/georglauterbach/libbash/linting.yml?branch=main&color=blue&label=LINTERS&logo=github&logoColor=white&style=for-the-badge)](https://github.com/georglauterbach/libbash/actions/workflows/linting.yml)

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

## Modules

When you load `libbash`, you don't have to use all the code that `libbash` actually contains. `libbash` provides different modules. When you source the `load` script, you can provide the modules you would like to use as arguments.

### `cri`

This module provides the `setup_container_runtime` function to detect the container runtime. It will set the `CRI` variable to `docker` or `podman` or return with exit status 1 if no container runtime could be identified.

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

This module provides various miscellaneous functions, like `escape` to escape characters or `exit_failure` to exit with an error. Take a look at the function `__libbash__load_module_utils` in [`libbash`](./libbash) to see all the functions in this module.

## Environment Variables

When `libbash` is loaded, it uses variables that start with `__LIBBASH` to manage internal state. These variables are marked with `readonly`, hence they are not modifiable. You are **not** supposed to use these variables! Due to the way Bash handles scoping, having these variables in the global scope is inevitable.
