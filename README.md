# `libbash`

## About

`libbash` provides pure Bash functions like a library. These functions are **not** POSIX compatible, i.e. they do not work with `sh`, only with `bash`. `libbash` focuses on very high **code quality** and **safe** functions without common Bash side-effects. Bash is difficult because it is extremely liberal. This project provides robust functions, checked by [`shellcheck`](https://github.com/koalaman/shellcheck). This project is written in and supports Bash v5 (or higher).

## Modules

`libbash` provides so-called modules. When you source the `init.sh` script, you can provide the modules you would like to use as arguments. `libbash` provides the following modules:

1. `cri` - provides the `setup_container_runtime` function to detect the container runtime
2. `errors` - provides a very strict set of error primitives (`set -e`, etc.) to show and handle errors;
   it is recommended to use this module, and if the rules are too strict, revert some of the settings with `set +e` for example
3. `log` - provides the `notify` function; `notify` is invoked by specifying the log level (`tra`, `deb`, `inf`, `war` or `err`)
   and then the message (i.e. `notify 'inf' 'Some info message`)

## Usage

During this usage demonstration, consider the following directory and file structure:

``` TXT
your_repository/
├── some_script.sh
├── some_dir/
│   └── some_other_script.sh
└── libbash
    ├── init.sh
    ├── log.sh
    └── ...
```

One can then use `libbash` in `some_script.sh` this way:

``` BASH
#! /bin/bash

# to source the `init.sh` script, which handles the complete
# initialization of `libbash`, you can use the following command

# shellcheck source=... (depends on your shellcheck setup)
source libbash/init.sh 'errors' 'log'
SCRIPT='some script'
```

To source `libbash` independently of the invocation location, you may use this more elaborate call to `source`:

``` BASH
#! /bin/bash

source "$(realpath "$(dirname "$(realpath -eL "${0}")")/../libbash/init.sh" 'errors' 'log'
SCRIPT='some other script'
```

If the invocation location is always the same, this simplifies to

``` BASH
#! /bin/bash

# we assume the caller is always in `some_dir/`

source ../libbash/init.sh 'errors' 'log'
SCRIPT='some other script'
```

## Licensing

This project is licensed under the GNU General Public License v3.0 (GPLv3) or higher. See [`LICENSE`](./LICENSE).
