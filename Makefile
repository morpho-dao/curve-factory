-include .env
.EXPORT_ALL_VARIABLES:
MAKEFLAGS += --no-print-directory


install:
	yarn
	foundryup
	forge install
	pip install -r requirements.txt


contracts:
	FOUNDRY_TEST=/dev/null forge build --via-ir --extra-output-files irOptimized --sizes --force


test:
	forge test -vvv


test-%:
	@FOUNDRY_MATCH_TEST=$* make test


test/%:
	@FOUNDRY_MATCH_CONTRACT=$* make test


.PHONY: contracts test coverage
