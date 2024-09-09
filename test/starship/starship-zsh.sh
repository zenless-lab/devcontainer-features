#!/bin/zsh

set -e

source dev-container-features-test-lib

cat ~/.zshrc
check "Info: starship version" starship -V

reportResults