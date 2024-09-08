#!/bin/zsh

set -e

source dev-container-features-test-lib

check_zsh_is_available() {
    if [ ! -x "$(command -v zsh)" ]; then
        echo "Error: zsh is not available"
        exit 1
    fi
}

check_oh_my_zsh_is_installed() {
    if [ ! -d "$HOME/.oh-my-zsh" ]; then
        echo "Error: Oh My Zsh is not installed"
        exit 1
    fi
}

# Check zsh is available
check "Check: Shell is available" check_zsh_is_available
check "Check: Oh My Zsh is installed" check_oh_my_zsh_is_installed

reportResults
