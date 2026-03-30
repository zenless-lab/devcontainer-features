#!/bin/bash

set -e

source dev-container-features-test-lib

check "chezmoi version" chezmoi --version

echo "# " >> ~/.bashrc

check "dev mode config exists for remote user" test -f /home/vscode/.config/chezmoi/chezmoi.yaml
check "source files not in default location" test ! -f /home/vscode/.local/share/chezmoi/dot_bashrc
check "dev mode writes source files to current directory" chezmoi add /home/vscode/.bashrc && test -f "$PWD/dot_bashrc"

reportResults
