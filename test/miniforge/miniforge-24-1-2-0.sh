#!/bin/bash

set -e

source dev-container-features-test-lib


check_version() {
    if [ -z "$(rye --version | grep $1)" ]; then
        echo "Error: rye version [$(rye --version)] is not $1"
        exit 1
    fi
}


check "Info: Mamba version" mamba --version
check "Info: Conda version" conda --version

reportResults
