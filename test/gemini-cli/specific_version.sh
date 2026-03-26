#!/bin/bash

set -e

source dev-container-features-test-lib

check "gemini version is 0.35.1" bash -lc 'gemini --version | grep "0.35.1"'

reportResults
