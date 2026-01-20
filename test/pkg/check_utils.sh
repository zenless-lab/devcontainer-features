#!/bin/bash
set -e

# Import test library
source dev-container-features-test-lib

# Test if 'jq' is installed (from 'pkg' option)
check "jq" command -v jq
check "jq version" jq --version

# Test if 'zip' is installed (from distro specific option)
check "zip" command -v zip
# zip -v outputs a lot of text, but exit code 0 is enough
check "zip version" zip -v

# Report result
reportResults
