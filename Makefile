SHELL = /bin/bash

export ROOT_DIRECTORY := $(shell realpath -eL .)

test:
	@ ./tests/bats_core/bin/bats --timing tests/*.bats

lint:
	@ bash ./scripts/lint.sh
