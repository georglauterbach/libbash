# `libbash`

[![ci::bats::status]][ci::bats::action] [![ci::lint::status]][ci::lint::action]

[//]: # (editorconfig-checker-disable)

<!-- markdownlint-disable-next-line ine-length  -->
[ci::bats::status]: https://img.shields.io/github/actions/workflow/status/georglauterbach/libbash/test-bats.yml?branch=main&color=blue&label=BASH%20UNIT%20TESTS&logo=github&logoColor=white&style=for-the-badge
[ci::bats::action]: https://github.com/georglauterbach/libbash/actions/workflows/test-bats.yml

<!-- markdownlint-disable-next-line ine-length  -->
[ci::lint::status]: https://img.shields.io/github/actions/workflow/status/georglauterbach/libbash/linting.yml?branch=main&color=blue&label=LINTING%20TESTS&logo=github&logoColor=white&style=for-the-badge
[ci::lint::action]: https://github.com/georglauterbach/libbash/actions/workflows/linting.yml

[//]: # (editorconfig-checker-enable)

## About

`libbash` provides pure Bash functions like a library. These functions are **not**
POSIX compatible, i.e. they do not work with `sh`, only with `bash`. `libbash` focuses
on very high **code quality** and **safe** functions without common Bash side-effects.
Bash is difficult because it is extremely liberal. This project provides robust
functions, checked by [_shellcheck_](https://github.com/koalaman/shellcheck) and by
[_BATS_](https://github.com/bats-core/bats-core). This project is written in and supports
Bash v5 (or higher).

`libbash` is not supposed to be used in conjunction with `.bashrc` or as
[_dotfiles_](https://wiki.archlinux.org/title/Dotfiles). Rather, it should satisfy
reoccurring needs in projects that use Bash, and provide frequently used functions.

## Usage

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

One can then use `libbash` in `some_script.sh` the following way. To source `load`, the
script that handles the complete initialization of `libbash`, you can use the following
command:

``` BASH
source libbash/load 'errors' 'log'
SCRIPT='some script'
```

The former example assumes a constant caller / invocation place (the directory from which
`some_script.sh` is called is constant, here `your_repository/`). To source `libbash`
independently of the invocation location, for example in `some_dir/some_other_script.sh`,
you may use this more elaborate call to `source`:

``` BASH
#! /bin/bash

source "$(realpath "$(dirname "${BASH_SOURCE[0]}")/../libbash/load" 'errors' 'log'
SCRIPT='some other script'
```

When using `libbash` on an interactive prompt, you may use `LIBBASH_EXIT_IN_INTERACTIVE_MODE`
to specify whether you want to prompt to quit when the `errors` module is loaded and
an unhandled error is thrown. The default is `false`, so your interactive prompt will
not close be default.

## Modules

When you use `libbash`, you don't have to use all the code that `libbash` contains.
`libbash` provides different modules. When you source the `load` script, you can
provide the modules you would like to use as arguments.

To load a module, just specify its name after the `source` command as shown in the
examples above in [usage section](#usage). All modules are located in the `modules`
directory, and their name is just the file name without `.sh` at the end. When you
open the file, you will see all the functions the module provides. These functions
have Rust-like documentation comments above their definitions in order to give you
a concise overview over what the function does.

`libbash` provides the following modules.

### `cri`

This module provides the `setup_container_runtime` function to detect the container
runtime. It will set the `CRI` variable to `docker` or `podman` or return with exit
status 1 if no container runtime could be identified.

### `errors`

This module provides a very strict set of error primitives (`set -e`, etc.) to show and
handle errors. The use of this module is recommended, but the set of rules imposed by this
module is very strict. One might want to circumvent some of the strictness by manually
reverting some settings, for example with `set +e`.

### `log`

This module provides the `log` function. `log` is invoked by specifying the log level

1. `tra` or `trace`
2. `deb` or `debug`
3. `inf` or `info`
4. `war` or `warn`
5. `err` or `error`

and then the message (i.e. `log 'inf' 'Some info message'`). You can supply many
arguments to `log`, but the first argument must be the log level. This function
is guaranteed to not fail. If called with a string that is not representative if the
log level, `war` is assumed. The default `LOG_LEVEL` is `inf`.

The log level itself can be changed anytime by setting `LOG_LEVEL` to one of the
levels described above. Naturally, messages below the log level are not shown.

### `utils`

This module provides various miscellaneous functions, like `escape` to escape characters
or `exit_failure` to exit with an error.

## Licensing

This project is licensed under the GNU General Public License v3.0 (GPLv3) or higher.
See [`LICENSE`](./LICENSE).
