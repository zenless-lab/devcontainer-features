#!/bin/bash

set -e

source dev-container-features-test-lib

check "runsc sandbox env" bash -lc '[ "$GEMINI_SANDBOX" = "runsc" ]'

reportResults
