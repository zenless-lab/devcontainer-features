#!/bin/bash
set -e

source dev-container-features-test-lib

check "micromamba binary exists" ls /usr/local/bin/micromamba
check "micromamba version" micromamba --version
check "bashrc modified" grep -q "micromamba" $HOME/.bashrc

reportResults
