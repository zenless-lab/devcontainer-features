#!/bin/bash

set -e

source dev-container-features-test-lib

check "codex cli should not be installed" bash -c "command -v codex >/dev/null 2>&1 && codex --version && exit 1 || exit 0"
check "auth.json symlink exists" bash -c "test -L \"${HOME}/.codex/auth.json\""
check "config.toml symlink exists" bash -c "test -L \"${HOME}/.codex/config.toml\""
check "try writing to auth file" bash -c "echo '{}' > /opt/codex/auth.json"
check "try writing to config file" bash -c "echo '' > /opt/codex/config.toml"
