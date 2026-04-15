#!/bin/bash

set -e

source dev-container-features-test-lib

check "ruff is installed via uv tool" bash -lc 'uv tool list | grep -Eq "^ruff\b"'
check "black is installed via uv tool" bash -lc 'uv tool list | grep -Eq "^black\b"'
check "pytest is not installed via uv tool" bash -lc '! uv tool list | grep -Eq "^pytest\b"'

reportResults
