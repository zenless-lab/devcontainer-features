#!/bin/bash
set -e

source dev-container-features-test-lib

MICROMAMBA_VERSION="1.5.10"

check "micromamba version $MICROMAMBA_VERSION" micromamba --version | grep "$MICROMAMBA_VERSION"

reportResults
