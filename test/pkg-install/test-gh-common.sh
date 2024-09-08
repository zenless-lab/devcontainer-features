#!/bin/bash

set -e

source dev-container-features-test-lib

check "Info: GH version" gh --version
check "Info: Git version" git --version

reportResults