#!/bin/bash
set -e

source dev-container-features-test-lib

check "mamba binary exists" ls $HOME/miniforge3/bin/mamba
check "zshrc modified" grep -q "miniforge3/bin" $HOME/.zshrc

reportResults
