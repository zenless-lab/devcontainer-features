#!/bin/bash
set -e

# Import test library
source dev-container-features-test-lib

# Definition specific tests (assuming output contains the version string)
check "opencode version" opencode --version | grep "1.1.26"

# Report result
reportResults
