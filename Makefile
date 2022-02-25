SHELL = /bin/bash
.SHELLFLAGS = -eu -o pipefail -c

MAKEFLAGS += --warn-undefined-variables
MAKEFLAGS += --no-builtin-rules

export ROOT_DIRECTORY := $(shell realpath -eL .)

.PHONY: test tests lint ci-bats

tests: test
test:
	@ ./tests/bats_core/bin/bats  \
		--timing              \
		--pretty              \
		tests/*.bats

ci-bats:
	@ ./tests/bats_core/bin/bats  \
		--timing              \
		tests/*.bats

lint:
	@ bash ./scripts/lint.sh
