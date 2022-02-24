# Contribution Guidelines

## Cloning this Repository Correctly

To clone this repository with all submodules, run

``` CONSOLE
$ git clone --recurse-submodules -j $(nproc) git@github.com:georglauterbach/libbash.git
Cloning into 'libbash'...
remote: Enumerating objects: 76, done.
remote: Counting objects: 100% (76/76), done.
remote: Compressing objects: 100% (53/53), done.
remote: Total 76 (delta 23), reused 68 (delta 20), pack-reused 0
Receiving objects: 100% (76/76), 32.70 KiB | 418.00 KiB/s, done.
Resolving deltas: 100% (23/23), done.
Submodule 'tests/bats_assert' ...
...
Submodule path 'tests/bats_assert': checked out ...
Submodule path 'tests/bats_core': checked out ...
Submodule path 'tests/bats_support': checked out ...
```

## When Writing Code

Take care of the following constraints.

### Robustness

Bash is a fragile language. Take special care of side-effects or unwanted
failures when writing code. Writing robust Bash is a very complicated thing
to do, be assured. Writing idiomatic code is even harder.

### Style

The code in this repository is (heavily) opinionated when it comes to formatting.
Please adjust to the already present style. Library scripts will always start
the same way:

``` BASH
#! /bin/bash

# version       <SEMVER VERSION>
# executed by   <CALLER / EXECUTOR>
# task          <TASK>

SCRIPT='<SCRIPT NAME>' # optional
```

## CI/CD

GitHub actions is in-place to test your code upon opening a pull request and
pushing to an upstream branch of a corresponding pull request. The Bash unit
tests are executed, and your code is linted against a variety of linters:

1. An EditorConfig linter to check compliance with `.editorconfig`
2. A Markdown linter
3. A YAML linter

The sets of rules are found in `.github/linters/`. CI must pass before a PR
is merged into another branch.
