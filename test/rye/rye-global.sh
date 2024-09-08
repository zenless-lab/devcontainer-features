#!/bin/bash

set -e

source dev-container-features-test-lib

mkdir ./test_proj
cd ./test_proj


init_project() {
    rye init
    rye sync
}


must_have_venv() {
    if [ ! -d .venv ]; then
        echo "Error: .venv not found"
        exit 1
    fi
}


check "Info: Rye version" rye --version
check "Try: init project" init_project
check "Info: venv install" must_have_venv

reportResults
