#!/bin/bash

set -e

source dev-container-features-test-lib

check "custom gemini cli home env" bash -lc '[ "$GEMINI_CLI_HOME" = "/gemini-cli" ]'

reportResults
