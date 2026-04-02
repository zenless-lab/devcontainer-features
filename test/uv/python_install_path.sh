#!/bin/bash

set -e

source dev-container-features-test-lib

PYTHON_VERSION="3.11"

check "install python ${PYTHON_VERSION}" bash -lc "uv python install ${PYTHON_VERSION}"
check "python path is under /opt/uv/python" bash -lc 'python_path="$(uv python find 3.11)" && [ -n "$python_path" ] && [ -x "$python_path" ] && case "$python_path" in /opt/uv/python/*) exit 0 ;; *) exit 1 ;; esac'

reportResults
