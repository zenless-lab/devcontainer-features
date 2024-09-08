#!/bin/bash

set -e

source dev-container-features-test-lib

mkdir ./test_proj
cd ./test_proj

check "Info: Rye version" rye --version
check "Try: init project" rye init

reportResults