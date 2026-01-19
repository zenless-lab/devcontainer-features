#!/bin/bash

set -e

source dev-container-features-test-lib

check "uv version is 0.9.24" uv --version | grep "0.9.24"

reportResults
