SHELL = /bin/bash
.SHELLFLAGS = -eu -o pipefail -c

MAKEFLAGS += --warn-undefined-variables
MAKEFLAGS += --no-builtin-rules

export ROOT_DIRECTORY := $(shell realpath -eL .)

# Maybe use `--jobs $(shell nproc) \` in the future
test:
	@ ./tests/bats_core/bin/bats  \
		--timing              \
		--pretty              \
		tests/*.bats

lint:
	@ bash ./scripts/lint.sh
