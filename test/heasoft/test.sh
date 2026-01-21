#!/bin/bash
set -e

source dev-container-features-test-lib

check "heasoft profile script exists" ls /etc/profile.d/heasoft.sh

check "HEADAS variable is set" echo $HEADAS
check "fhelp command available" command -v fhelp

reportResults
