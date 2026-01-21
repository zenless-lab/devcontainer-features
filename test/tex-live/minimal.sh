#!/bin/bash
set -e
source dev-container-features-test-lib

check "tex exists" tex --version
check "tlmgr exists" tlmgr --version

reportResults
