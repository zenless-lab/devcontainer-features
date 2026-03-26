#!/bin/bash

set -e

source dev-container-features-test-lib

check "pnpm version" pnpm --version
check "node version" node --version
check "gemini cli" bash -c "command -v gemini >/dev/null 2>&1 && gemini --version || gemini-cli --version"
check "gemini profile script exists" ls /etc/profile.d/gemini-cli.sh
check "default gemini cli home env" bash -lc '[ "$GEMINI_CLI_HOME" = "/usr/local/share/gemini-cli" ]'
check "shared gemini config dir exists" bash -lc '[ -d "/usr/local/share/gemini-cli/.gemini" ]'
check "default sandbox env" bash -lc '[ "$GEMINI_SANDBOX" = "false" ]'

reportResults
