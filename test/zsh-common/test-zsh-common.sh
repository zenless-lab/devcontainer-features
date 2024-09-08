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

check_zsh_plugin_enabled() {
    local plugin=$1
    if ! grep -q "plugins=.*$plugin" $HOME/.zshrc; then
        echo "Error: Plugin $plugin is not enabled"
        exit 1
    fi
}

check "Check: zsh is available" check_zsh_is_available
check "Check: Oh My Zsh is installed" check_oh_my_zsh_is_installed

# Define the expected plugins
expected_plugins=("zsh-autosuggestions" "zsh-syntax-highlighting" "zsh-completions" "fzf" "sudo" "z" "web-search")

# Check if each expected plugin is enabled in .zshrc
for plugin in "${expected_plugins[@]}"; do
    check "Check: Plugin $plugin is enabled" check_zsh_plugin_enabled $plugin
done

reportResults