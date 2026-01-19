#!/bin/bash

set -e

source dev-container-features-test-lib

POSSIBLE_RC_FILES=(
    "$HOME/.bashrc"
    "/root/.bashrc"
    "/home/vscode/.bashrc"
    "/home/node/.bashrc"
)

FOUND=0
for rc in "${POSSIBLE_RC_FILES[@]}"; do
    if [ -f "$rc" ]; then
        if grep -Fq "uv generate-shell-completion bash" "$rc"; then
            echo "Found completion in $rc"
            FOUND=1
            break
        fi
    fi
done

if [ "$FOUND" -eq 1 ]; then
    check "autocompletion configured" true
else
    echo "Could not find 'uv generate-shell-completion bash' in any checked .bashrc files."
    check "autocompletion configured" false
fi

reportResults
