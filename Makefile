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
