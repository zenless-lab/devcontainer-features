#!/bin/bash

set -e

source dev-container-features-test-lib

check "default uv tools are not installed when disabled" bash -lc '! uv tool list | grep -Eq "^(ruff|pytest|ty|black|pyright|pyrefly|pre-commit|rust-just)\\b"'

reportResults
