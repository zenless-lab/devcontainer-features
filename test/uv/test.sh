#!/bin/bash

set -e

source dev-container-features-test-lib

mkdir ./test_proj
cd ./test_proj

check "Info: uv version" uv version
check "Try: init project" uv venv

reportResults