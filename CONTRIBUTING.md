# Contribution Guidelines

## Cloning this Repository Correctly

To clone this repository with all submodules, run

``` CONSOLE
$ git clone --recurse-submodules -j $(nproc) git@github.com:georglauterbach/libbash.git
...
```

## Robustness

Bash is a fragile language. Take special care of side-effects or unwanted failures when writing code.

## Style

The code in this repository is (heavily) opinionated when it comes to formatting. Please adjust to the already present style. Library scripts will always start the same way:

``` BASH
#! /bin/bash

# version       <SEMVER VERSION>
# executed by   <CALLER / EXECUTOR>
# task          <TASK>

SCRIPT='<SCRIPT NAME>'
```
