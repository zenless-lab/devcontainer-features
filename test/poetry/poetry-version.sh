#!/bin/zsh

set -e

source dev-container-features-test-lib

check_version() {
    if poetry --version | grep -q "1.2.0"; then
        return 0
    else
        return 1
    fi
}

check "Info: poetry version" check_version
check "Try: init project" poetry new test-proj

reportResults