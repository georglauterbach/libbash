SHELL = /bin/bash
.SHELLFLAGS = -eu -o pipefail -c

MAKEFLAGS += --warn-undefined-variables
MAKEFLAGS += --no-builtin-rules

export ROOT_DIRECTORY := $(CURDIR)

.PHONY: test tests lint

tests: test
test:
	@ ./tests/bats_core/bin/bats --timing tests/*.bats

lint:
	@ bash ./tests/lint.sh
