#!/bin/bash

set -e

source dev-container-features-test-lib

check "chezmoi version" chezmoi --version
check "chezmoi toml config file exists" test -f ${HOME}/.config/chezmoi/chezmoi.toml
check "chezmoi toml config contains expected content" grep -q "stats" ${HOME}/.config/chezmoi/chezmoi.toml

reportResults
