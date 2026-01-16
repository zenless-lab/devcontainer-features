#!/bin/bash
set -e

source dev-container-features-test-lib

check "mamba binary exists" ls $HOME/miniforge3/bin/mamba
check "conda binary exists" ls $HOME/miniforge3/bin/conda

check "mamba version" $HOME/miniforge3/bin/mamba --version
check "conda version" $HOME/miniforge3/bin/conda --version

check "bashrc modified" grep -q "miniforge3/bin" $HOME/.bashrc

reportResults
