#!/bin/bash

set -e

# Import test library
source dev-container-features-test-lib

# Definition of tests
check "curl is installed" curl --version
check "wget is installed" wget --version
check "file is installed" file --version

# Report result
reportResults
