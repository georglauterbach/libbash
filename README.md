# `libbash`

[![ci::bats::status]][ci::bats::action] [![ci::lint::status]][ci::lint::action]

<!-- markdownlint-disable-next-line ine-length  -->
[ci::bats::status]: https://img.shields.io/github/workflow/status/georglauterbach/libbash/Bash%20Unit%20Testing?color=blue&label=BASH%20UNIT%20TESTS&logo=github&logoColor=white&style=for-the-badge
[ci::bats::action]: https://github.com/georglauterbach/libbash/actions/workflows/bats.yml

<!-- markdownlint-disable-next-line ine-length  -->
[ci::lint::status]: https://img.shields.io/github/workflow/status/georglauterbach/libbash/Linting?color=blue&label=LINTING&logo=github&logoColor=white&style=for-the-badge
[ci::lint::action]: https://github.com/georglauterbach/libbash/actions/workflows/linting.yml

## About

`libbash` provides pure Bash functions like a library. These functions are **not**
POSIX compatible, i.e. they do not work with `sh`, only with `bash`. `libbash` focuses
on very high **code quality** and **safe** functions without common Bash side-effects.
Bash is difficult because it is extremely liberal. This project provides robust
functions, checked by [`shellcheck`](https://github.com/koalaman/shellcheck). This
project is written in and supports Bash v5 (or higher).

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
    ├── init.sh
    ├── log.sh
    └── ...
```

One can then use `libbash` in `some_script.sh` the following way. to source the `init.sh`
script, which handles the complete initialization of `libbash`, you can use the following
command:

``` BASH
source libbash/init.sh 'errors' 'log'
SCRIPT='some script'
```

The former example assumes a constant caller / invocation place (the directory from which
`some_script.sh` is called is constant). To source `libbash` independently of the invocation
location, you may use this more elaborate call to `source`:

``` BASH
#! /bin/bash

source "$(realpath "$(dirname "$(realpath -eL "${0}")")/../libbash/init.sh" 'errors' 'log'
SCRIPT='some other script'
```

## Modules

When you use `libbash`, you don't have to use all the code that `libbash` contains.
`libbash` provides different modules. When you source the `init.sh` script, you can
provide the modules you would like to use as arguments.

To load a module, just specify its name after the `source` command as shown in the
examples above in [usage section](#usage).

`libbash` provides the following modules.

### `cri`

This module provides the `setup_container_runtime` function to detect the container runtime.
It will set the `CRI` variable to `docker` or `podman` or return with exit status 1 if no
container runtime could be identified.

### `errors`

This module provides a very strict set of error primitives (`set -e`, etc.) to show and
handle errors. The use of this module is recommended, but the set of rules imposed by this
module is very strict. One might want to circumvent some of the strictness by manually
reverting some settings, for example with `set +e`.

### `log`

This module provides the `notify` function. `notify` is invoked by specifying the log level

1. `tra` - "trace"
2. `deb` - "debug"
3. `inf` - "info"
4. `war` - "warning"
5. `err` - "error"

and then the message (i.e. `notify 'inf' 'Some info message`). You can supply many
arguments to `notify`, only the first argument should be the log level. This function
is guaranteed to not fail. If called with a string that is not representative if the
log level, `war` is assumed.

The log level itself can be changed anytime by setting `LOG_LEVEL` to one of the
levels described above. Naturally, messages below the log level are not shown.

## Licensing

This project is licensed under the GNU General Public License v3.0 (GPLv3) or higher.
See [`LICENSE`](./LICENSE).
