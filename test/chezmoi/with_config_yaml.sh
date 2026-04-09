#!/bin/bash

set -e

source dev-container-features-test-lib

check "chezmoi version" chezmoi --version
check "chezmoi yaml config file exists" test -f /root/.config/chezmoi/chezmoi.yaml
check "chezmoi yaml config contains expected content" grep -q "stats" /root/.config/chezmoi/chezmoi.yaml

reportResults
