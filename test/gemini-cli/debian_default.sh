#!/bin/bash

set -e

source dev-container-features-test-lib

check "pnpm version" pnpm --version
check "node version" node --version
check "gemini cli" bash -c "command -v gemini >/dev/null 2>&1 && gemini --version || gemini-cli --version"
check "gemini profile script exists" ls /etc/profile.d/gemini-cli.sh
check "default sandbox env" bash -lc '[ "$GEMINI_SANDBOX" = "false" ]'

reportResults
