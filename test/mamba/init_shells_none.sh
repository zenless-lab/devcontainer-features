#!/bin/bash
set -e

source dev-container-features-test-lib

check "mamba binary exists" ls $HOME/miniforge3/bin/mamba

if [ -f "$HOME/.bashrc" ]; then
    check "bashrc NOT modified" bash -c "! grep 'miniforge3/bin' $HOME/.bashrc"
else
    check "bashrc does not exist" true
fi

reportResults
