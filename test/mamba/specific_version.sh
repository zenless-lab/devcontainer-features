#!/bin/bash
set -e

source dev-container-features-test-lib

# NOTE: Should match the version in scenarios.json(24.9.2-0 -> 24.9.2)
EXPECTED_VERSION="24.9.2"

check "mamba binary exists" ls $HOME/miniforge3/bin/mamba
check "conda binary exists" ls $HOME/miniforge3/bin/conda
check "check conda specific version" bash -c "$HOME/miniforge3/bin/conda --version | grep 'conda $EXPECTED_VERSION'"

reportResults
