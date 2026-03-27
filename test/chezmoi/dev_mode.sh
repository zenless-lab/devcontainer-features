#!/bin/bash

set -e

source dev-container-features-test-lib

check "chezmoi version" chezmoi --version
check "dev mode profile script exists" test -f /etc/profile.d/chezmoi-dev-mode.sh
check "dev mode alias configured" bash -lc "alias chezmoi | grep -F \"alias chezmoi='chezmoi --source .'\""
check "dev mode writes source files to current directory" bash -lc 'src_dir=$(mktemp -d); home_dir=$(mktemp -d); export HOME="$home_dir"; touch "$HOME/.bashrc"; cd "$src_dir"; shopt -s expand_aliases; . /etc/profile.d/chezmoi-dev-mode.sh; eval "chezmoi add \"$HOME/.bashrc\""; test -f "$src_dir/empty_dot_bashrc"'

reportResults
