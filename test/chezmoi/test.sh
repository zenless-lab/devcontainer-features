#!/bin/bash

set -e

source dev-container-features-test-lib

check "chezmoi version" chezmoi --version
check "chezmoi path" bash -lc '[ "$(readlink -f "$(command -v chezmoi)")" = "/usr/local/bin/chezmoi" ]'
check "chezmoi ownership and mode" bash -lc '[ "$(stat -c "%U:%G %a" /usr/local/bin/chezmoi)" = "root:root 755" ]'

echo "# " >> ~/.bashrc

check "add bashrc to chezmoi" chezmoi add ~/.bashrc
check "dot_bashrc existing in default location" test -f ~/.local/share/chezmoi/dot_bashrc
check "dot_bashrc not existing in current directory" test ! -f "$PWD/dot_bashrc"

reportResults
