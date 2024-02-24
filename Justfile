# -----------------------------------------------
# ----  Just  -----------------------------------
# ----  https://github.com/casey/just  ----------
# -----------------------------------------------

set shell             := [ "/bin/bash", "-eu", "-o", "pipefail", "-c" ]
set dotenv-load       := false

export ROOT_DIRECTORY := justfile_directory()



# show this help
@_default:
	just --list

# run all tests
@all_tests:
	bash "{{ROOT_DIRECTORY}}/tests/bats_core/bin/bats" \
		--jobs 2                                       \
		--no-parallelize-within-files                  \
		--timing                                       \
		{{ROOT_DIRECTORY}}/tests/*.bats

# run a specific test
@test name:
	bash "{{ROOT_DIRECTORY}}/tests/bats_core/bin/bats" --timing {{ROOT_DIRECTORY}}/tests/*-{{name}}.bats
