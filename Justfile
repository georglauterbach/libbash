# -----------------------------------------------
# ----  Just  -----------------------------------
# ----  https://github.com/casey/just  ----------
# -----------------------------------------------

set shell             := [ "/bin/bash", "-eu", "-o", "pipefail", "-c" ]
set dotenv-load       := false

export ROOT_DIRECTORY := justfile_directory()

[private]
@default:
	just --list

# Run a single or all tests
test name="":
	#! /bin/bash

	if [[ -n "{{name}}" ]]; then
		bash "{{ROOT_DIRECTORY}}/tests/bats_core/bin/bats" \
			--timing {{ROOT_DIRECTORY}}/tests/*-{{name}}.bats
	else
		bash "{{ROOT_DIRECTORY}}/tests/bats_core/bin/bats" \
			--jobs 2                                       \
			--no-parallelize-within-files                  \
			--timing                                       \
			{{ROOT_DIRECTORY}}/tests/*.bats
	fi
