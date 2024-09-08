#!/bin/zsh

set -e

source dev-container-features-test-lib

check "Info: poetry version" poetry --version
check "Try: init project" poetry new test-proj

reportResults