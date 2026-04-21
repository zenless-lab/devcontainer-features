#!/bin/bash

set -e

source dev-container-features-test-lib

check "codex cli installed" bash -c "command -v codex"
check "specific version installed" bash -c "codex --version | grep -q '0.119.0'"

reportResults
