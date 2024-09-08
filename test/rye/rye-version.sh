#!/bin/bash

set -e

source dev-container-features-test-lib


mkdir ./test_proj
cd ./test_proj


check_version() {
    if [ -z "$(rye --version | grep $1)" ]; then
        echo "Error: rye version [$(rye --version)] is not $1"
        exit 1
    fi
}


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


check "Check: Rye version" check_version "0.30.0"
check "Try: init project" init_project
check "Info: venv install" must_have_venv

reportResults
