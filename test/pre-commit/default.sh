#!/bin/bash

set -e

source dev-container-features-test-lib

check "pre-commit command available" bash -lc 'command -v pre-commit'
check "uv tool list includes pre-commit" bash -lc 'uv tool list | grep -Eq "^pre-commit\\b"'
check "workspace git hook exists" bash -lc '[ -f .git/hooks/pre-commit ]'

reportResults
