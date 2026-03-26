#!/bin/bash

set -e

source dev-container-features-test-lib

check "docker sandbox env" bash -lc '[ "$GEMINI_SANDBOX" = "docker" ]'

reportResults
