#!/bin/bash

set -e

source dev-container-features-test-lib

check "workspace git hook exists" bash -lc '[ -f .git/hooks/pre-commit ]'

reportResults
