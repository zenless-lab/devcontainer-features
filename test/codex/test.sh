#!/bin/bash

set -e

source dev-container-features-test-lib

check "codex cli installed" bash -c "command -v codex"
check "codex version" bash -c "codex --version"
check "auth.json symlink exists" bash -c "test -L \"${HOME}/.codex/auth.json\""
check "config.toml symlink exists" bash -c "test -L \"${HOME}/.codex/config.toml\""
check "try writing to auth file" bash -c "echo '{}' > /opt/codex/auth.json"
check "try writing to config file" bash -c "echo '' > /opt/codex/config.toml"

reportResults
