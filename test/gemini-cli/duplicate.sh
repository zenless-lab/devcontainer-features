#!/bin/bash

set -e

source dev-container-features-test-lib

check "gemini cli" bash -c "command -v gemini >/dev/null 2>&1 && gemini --version || gemini-cli --version"
check "try writing to auth file" bash -c "echo test > /opt/gemini-cli/oauth_creds.json"
check "try writing to accounts file" bash -c "echo test > /opt/gemini-cli/google_accounts.json"
check "try writing to settings file" bash -c "echo test > /opt/gemini-cli/settings.json"

rm -f /opt/gemini-cli/oauth_creds.json \
    /opt/gemini-cli/google_accounts.json \
    /opt/gemini-cli/settings.json

reportResults
