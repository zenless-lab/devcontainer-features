#!/bin/bash
set -e

source dev-container-features-test-lib

check "zshrc modified" grep -q "micromamba" $HOME/.zshrc
check "bashrc not modified" bash -c "! grep -q 'micromamba' $HOME/.bashrc"

reportResults
