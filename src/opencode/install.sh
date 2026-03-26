#!/bin/bash

set -euo pipefail


OPENCODE_VERSION=${OPENCODEVERSION:-"latest"}
SHELL_INIT=${SHELLINIT:-"automatic"}

INSTALL_SCRIPT_URL="https://opencode.ai/install"


# Detect user home directory
detect_user_home() {
    if [ -n "${_REMOTE_USER:-}" ] && [ "${_REMOTE_USER}" != "root" ]; then
        echo "/home/${_REMOTE_USER}"
    else
        echo "/root"
    fi
}


# Execute command as remote user if specified
remote_user_do() {
    if [ -n "${_REMOTE_USER:-}" ] && [ "${_REMOTE_USER}" != "root" ]; then
        sudo -i -u "${_REMOTE_USER}" -- "$@"
    else
        "$@"
    fi
}


# Install OpenCode
install_opencode() {
    echo "Installing OpenCode version: $OPENCODE_VERSION"
    if [ "$OPENCODE_VERSION" = "latest" ]; then
        curl -fsSL "$INSTALL_SCRIPT_URL" | remote_user_do bash -s -- --no-modify-path
    else
        echo "specific version detected: $OPENCODE_VERSION"
        curl -fsSL "$INSTALL_SCRIPT_URL" | remote_user_do bash -s -- --version "$OPENCODE_VERSION" --no-modify-path
    fi
}


# Detect installed shells
detect_installed_shell() {
    local shells=()
    # Bash
    if command -v bash >/dev/null 2>&1; then
        shells+=("bash")
    fi
    # Zsh
    if command -v zsh >/dev/null 2>&1; then
        shells+=("zsh")
    fi
    # Fish
    if command -v fish >/dev/null 2>&1; then
        shells+=("fish")
    fi
    # Ash
    if command -v ash >/dev/null 2>&1; then
        shells+=("ash")
    fi
    # Sh
    if command -v sh >/dev/null 2>&1; then
        shells+=("sh")
    fi
    echo "${shells[@]}"
}


# Add command to config file if not already present
add_to_path() {
    local config_file=$1
    local command=$2
    local owner=${_REMOTE_USER:-root}

    if [ ! -f "$config_file" ]; then
        touch "$config_file"
        chown "$(id -u "$owner"):$(id -g "$owner")" "$config_file"
    fi

    if grep -Fxq "$command" "$config_file"; then
        echo "Path already set in $config_file"
    elif [[ -w $config_file ]]; then
        printf '\n# opencode\n%s\n' "$command" >> "$config_file"
        chown "$(id -u "$owner"):$(id -g "$owner")" "$config_file"
        echo "Added CMD to $config_file"
    else
        echo "CMD to add to $config_file:"
        echo "  $command"
    fi
}


# Initialize shell(s) to include OpenCode in PATH
init_shell() {
    local shells=()

    if [ "$SHELL_INIT" = "automatic" ]; then
        IFS=' ' read -r -a shells <<< "$(detect_installed_shell)"
    else
        IFS=',' read -r -a shells <<< "$SHELL_INIT"
    fi

    local user_home
    user_home=$(detect_user_home)
    local install_dir="$user_home/.opencode/bin"

    for shell in "${shells[@]}"; do
        case "$shell" in
            fish)
                mkdir -p "$user_home/.config/fish"
                add_to_path "$user_home/.config/fish/config.fish" "fish_add_path $install_dir"
                ;;
            bash)
                add_to_path "$user_home/.bashrc" "export PATH=\"$install_dir:\$PATH\""
                ;;
            zsh)
                add_to_path "$user_home/.zshrc" "export PATH=\"$install_dir:\$PATH\""
                ;;
            ash)
                add_to_path "$user_home/.profile" "export PATH=\"$install_dir:\$PATH\""
                ;;
            sh)
                add_to_path "$user_home/.profile" "export PATH=\"$install_dir:\$PATH\""
                ;;
            *)
                echo "Warning: Shell $shell is not specifically supported for initialization."
                ;;
        esac
    done
}


# Main script execution
echo "Activating feature 'opencode'"
install_opencode
init_shell
echo "OpenCode installation and initialization complete."
