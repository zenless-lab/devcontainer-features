#!/bin/bash

set -e

source dev-container-features-test-lib

check "uv version" uv --version

# Verify Python installation and path
check "install python 3.11" bash -lc "uv python install 3.11"
check "python path is under /opt/uv/python" bash -lc 'python_path="$(uv python find 3.11)" && [ -n "$python_path" ] && [ -x "$python_path" ] && case "$python_path" in /opt/uv/python/*) exit 0 ;; *) exit 1 ;; esac'

# Verify VIRTUAL_ENV is configured to the expected path
check "VIRTUAL_ENV is set to /opt/uv/venv" bash -c '[ "$VIRTUAL_ENV" = "/opt/uv/venv" ]'

# After uv init, no virtual environment should be created in the working directory
TEST_DIR=$(mktemp -d)
cd "$TEST_DIR"
uv init --no-workspace --quiet 2>/dev/null
check "no .venv created in working directory after uv init" bash -c "[ ! -d '${TEST_DIR}/.venv' ]"
cd /

# The VIRTUAL_ENV location should have a valid virtual environment
check "virtual environment exists at VIRTUAL_ENV" bash -c '[ -d "${VIRTUAL_ENV}/bin" ]'
check "python executable exists at VIRTUAL_ENV" bash -c '[ -x "${VIRTUAL_ENV}/bin/python" ]'

# Verify default CLI tools are installed via uv tool
check "ruff is installed via uv tool" bash -lc 'uv tool list | grep -Eq "^ruff\b"'
check "pytest is installed via uv tool" bash -lc 'uv tool list | grep -Eq "^pytest\b"'
check "black is installed via uv tool" bash -lc 'uv tool list | grep -Eq "^black\b"'

reportResults
