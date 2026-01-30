#!/bin/bash

set -e

source dev-container-features-test-lib

check "uv installed" uv --version

check "python 3.10 installed" bash -lc "uv python find 3.10"
check "python 3.11 installed" bash -lc "uv python find 3.11"
check "python 3.12 installed" bash -lc "uv python find 3.12"
check "python 3.8 not installed" bash -lc "! uv python find 3.8"

reportResults
