#!/bin/bash

set -e

source dev-container-features-test-lib

check "pnpm version" pnpm --version
check "node version" node --version
check "gemini cli" bash -c "command -v gemini >/dev/null 2>&1 && gemini --version || gemini-cli --version"

reportResults
