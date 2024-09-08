#!/bin/bash

set -e

source dev-container-features-test-lib

check "Info: Rye version" rye --version
check "Info: Mamba version" mamba --version
check "Info: Conda version" conda --version

reportResults