# `libbash`

[![ci::bats::status]][ci::bats::action] [![ci::lint::status]][ci::lint::action]

[ci::bats::status]: https://img.shields.io/github/actions/workflow/status/georglauterbach/libbash/test-bats.yml?branch=main&color=blue&label=BASH%20UNIT%20TESTS&logo=github&logoColor=white&style=for-the-badge
[ci::bats::action]: https://github.com/georglauterbach/libbash/actions/workflows/test-bats.yml

[ci::lint::status]: https://img.shields.io/github/actions/workflow/status/georglauterbach/libbash/linting.yml?branch=main&color=blue&label=LINTING%20TESTS&logo=github&logoColor=white&style=for-the-badge
[ci::lint::action]: https://github.com/georglauterbach/libbash/actions/workflows/linting.yml

## About

`libbash` provides pure Bash functions like a library. `libbash` focuses on very high **code quality** and **safe** functions without common Bash side effects. Bash is difficult because it is extremely liberal. This project provides robust functions, checked by [_ShellCheck_](https://github.com/koalaman/shellcheck) and by [_BATS_](https://github.com/bats-core/bats-core).

>[!CAUTION]
>
> These functions are **not** POSIX compatible, i.e., they do not work with `sh`, only with `bash`. This project is written in and supports Bash v5.

## Usage

### Locally

During this usage demonstration, consider the following directory and file structure:

``` TXT
your_repository/
├── some_script.sh
├── some_dir/
│   └── some_other_script.sh
└── libbash/
    ├── ...
    ├── load
    └── ...
```

To source `load` - the script that handles the complete initialization of `libbash` - from `some_script.sh`, you can use the following command:

``` BASH
source libbash/load 'errors' 'log'
SCRIPT='some script'
```

This example assumes the script `some_script.sh` is executed (or sourced) from the directory it lives in (i.e., `your_repository`). To source `libbash` independently of the invocation location, for example in `some_dir/some_other_script.sh`, you may use this more elaborate call to `source`:

``` BASH
source "$(realpath "$(dirname "${BASH_SOURCE[0]}")/../libbash/load" 'errors' 'log'
SCRIPT='some other script'
```

### Remotely

You may also use `libbash` without cloning the repository. To do so, run:

```bash
source <(curl -qsSfL https://raw.githubusercontent.com/georglauterbach/libbash/main/load) --online 'log'
```

### Environment Variables

#### `__LIBBASH__*`

When `libbash` is loaded, it will set `__LIBBASH__IS_LOADED` to `1`. Moreover, when the [`log`] module is loaded, `__LIBBASH__IS_LOADED_LOG` is also set to `1`. The user cannot change the values of these variables, as they are marked with `readonly`.

#### Exit in Interactive Mode

When using `libbash` on an interactive prompt, you can use `export LIBBASH_EXIT_IN_INTERACTIVE_MODE=1` to specify that you want the prompt to quit when

1. the [`errors`] module is loaded, **and**
2. an unhandled error is thrown.

The default is `0`, i.e., your interactive prompt will not close by default.

## Modules

When you use `libbash`, you don't have to use all the code that `libbash` contains. `libbash` provides different modules. When you source the `load` script, you can provide the modules you would like to use as arguments.

To load a module, just specify its name after the `source` command, as shown in the examples above in [the usage section](#usage). All modules are located in the `modules` directory, and their name is just the file name without `.sh` at the end. When you open the file, you will see all the functions the module provides. These functions have Rust-like documentation comments above their definitions to give you a concise overview of what the function does.

1. `tra` or `trace`
2. `deb` or `debug`
3. `inf` or `info`
4. `war` or `warn`
5. `err` or `error`
### [`cri`](./modules/cri.sh)

This module provides the `setup_container_runtime` function to detect the container runtime. It will set the `CRI` variable to `docker` or `podman` or return with exit status 1 if no container runtime could be identified.

### [`errors`](./modules/errors.sh)

This module provides a very strict set of error primitives (e.g., `set -e`, `set -E`) to show and handle errors. The use of this module is recommended, but the set of rules imposed by this module is very strict. One might want to circumvent this by manually reverting some settings, for example with `set +e` after loading the module.

### [`log`](./modules/log.sh)

This module provides the [`log`] function. [`log`] is invoked by first specifying the log level:

1. `trace`
2. `debug`
3. `info`
4. `warn`
5. `error`

This is followed by the actual message (i.e., `log 'info' 'Some info message'`). You can supply many arguments to [`log`], but the first argument must be the log level. This function is guaranteed to not fail.

The log level itself can be changed anytime by setting `LOG_LEVEL` to one of the levels described above. Naturally, messages below the log level are not shown. The default `LOG_LEVEL` is `info`. If the environment variable `LOG_LEVEL` does not contain a valid log level, `LOG_LEVEL` is reset to `info` upon calling [`log`].

### [`utils`](./modules/utils.sh)

This module provides various miscellaneous functions, like `escape` to escape characters or `exit_failure` to exit with an error.

## Licensing

This project is licensed under the GNU General Public License v3.0 (GPLv3) or higher. See [`LICENSE`](./LICENSE).

[//]: # (Links)

[`cri`]: #cri
[`errors`]: #errors
[`log`]: #log
[`utils`]: #utils
