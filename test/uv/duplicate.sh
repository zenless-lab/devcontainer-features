#!/bin/bash

set -euo pipefail

source dev-container-features-test-lib

check "uv remains available after duplicated feature install" bash -lc 'uv --version >/dev/null'

check "uv default virtual environment is created" bash -lc 'uv init . && uv sync'

check "default venv remains usable after duplicated feature install" bash -lc '[ -x /opt/uv/venv/bin/python ] && /opt/uv/venv/bin/python --version >/dev/null'

check "bash completion is configured only once" bash -lc 'if [ ! -f "$HOME/.bashrc" ]; then exit 0; fi; [ "$(grep -Fc "uv generate-shell-completion bash" "$HOME/.bashrc")" -le 1 ] && [ "$(grep -Fc "uvx --generate-shell-completion bash" "$HOME/.bashrc")" -le 1 ]'

check "default uv tools remain installed and not duplicated" bash -lc 'LIST="$(uv tool list)"; echo "$LIST" | grep -Eq "^ruff([[:space:]]|$)"; [ "$(echo "$LIST" | grep -Ec "^ruff([[:space:]]|$)")" -le 1 ]; echo "$LIST" | grep -Eq "^black([[:space:]]|$)"; [ "$(echo "$LIST" | grep -Ec "^black([[:space:]]|$)")" -le 1 ]'

reportResults
