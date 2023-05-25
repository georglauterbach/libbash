SHELL = /bin/bash
.SHELLFLAGS = -eu -o pipefail -c

MAKEFLAGS += --warn-undefined-variables
MAKEFLAGS += --no-builtin-rules

export ROOT_DIRECTORY := $(CURDIR)

.PHONY: tests

tests:
	@ ./tests/bats_core/bin/bats --timing tests/*.bats
