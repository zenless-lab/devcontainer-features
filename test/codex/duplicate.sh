#!/bin/bash

# Idempotency test: installing codex twice should not conflict.

set -e

source dev-container-features-test-lib

check "codex cli installed" bash -c "command -v codex"
check "codex version" bash -c "codex --version"
check "auth.json symlink exists" bash -c "test -L \"${HOME}/.codex/auth.json\""
check "config.toml symlink exists" bash -c "test -L \"${HOME}/.codex/config.toml\""
check "auth.json target is in /opt/codex" bash -c "readlink \"${HOME}/.codex/auth.json\" | grep -q /opt/codex"
check "config.toml target is in /opt/codex" bash -c "readlink \"${HOME}/.codex/config.toml\" | grep -q /opt/codex"

reportResults
