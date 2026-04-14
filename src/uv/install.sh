#!/bin/bash
set -euo pipefail

echo "Starting UV installation script..."

# NOTE: The `install.sh` script is always executed as root.

UV_VERSION="${VERSION:-latest}"
COMPLETION_SHELL="${COMPLETIONSHELL:-automatic}"

uv_command=""


require_command() {
    local command_name="$1"

    if ! command -v "${command_name}" >/dev/null 2>&1; then
        echo "Missing required command: ${command_name}"
        exit 1
    fi
}


remote_user_name() {
    if [ -n "${_REMOTE_USER:-}" ]; then
        echo "${_REMOTE_USER}"
    else
        echo "root"
    fi
}


set_remote_ownership() {
    local target_path="$1"
    local owner

    owner="$(remote_user_name)"
    chown -R "${owner}:$(id -gn "${owner}")" "${target_path}"
}


# Execute command as remote user if specified
remote_user_do() {
    if [ -n "${_REMOTE_USER:-}" ] && [ "${_REMOTE_USER}" != "root" ]; then
        sudo -i -u "${_REMOTE_USER}" -- "$@"
    else
        "$@"
    fi
}


find_user_home() {
    if [ -n "${_REMOTE_USER:-}" ] && [ "${_REMOTE_USER}" != "root" ]; then
        echo "/home/${_REMOTE_USER}"
    else
        echo "/root"
    fi
}



detect_installed_shell() {
    local shells=""
    # Bash
    if command -v bash >/dev/null 2>&1; then
        shells="${shells} bash"
    fi
    # Zsh
    if command -v zsh >/dev/null 2>&1; then
        shells="${shells} zsh"
    fi
    # Fish
    if command -v fish >/dev/null 2>&1; then
        shells="${shells} fish"
    fi
    # Elvish
    if command -v elvish >/dev/null 2>&1; then
        shells="${shells} elvish"
    fi
    echo "${shells}"
}

check_is_init_autocompletion() {
    local shell_name="$1"
    local remote_user_home
    remote_user_home=$(find_user_home)
    local pattern
    local profile_files=()

    case "$shell_name" in
        bash)
            pattern="uv generate-shell-completion bash"
            profile_files=("${remote_user_home}/.bashrc" "${remote_user_home}/.bash_profile" "${remote_user_home}/.profile")
            ;;
        zsh)
            pattern="uv generate-shell-completion zsh"
            profile_files=("${remote_user_home}/.zshrc")
            ;;
        fish)
            pattern="uv generate-shell-completion fish"
            profile_files=("${remote_user_home}/.config/fish/completions/uv.fish")
            ;;
        elvish)
            pattern="uv generate-shell-completion elvish"
            profile_files=("${remote_user_home}/.elvish/rc.elv")
            ;;
        *)
            echo "Shell $shell_name is not supported for autocompletion initialization."
            return 1
            ;;
    esac

    for file in "${profile_files[@]}"; do
        if [ -f "$file" ] && grep -Fq "$pattern" "$file"; then
            return 0
        fi
    done

    return 1
}

setup_autocompletion() {
    local shell="$1"
    echo "Setting up UV autocompletion for $shell..."
    case "$shell" in
        bash|zsh)
            echo 'eval "$(uv generate-shell-completion '"$shell"')" ' >> "$(find_user_home)/.${shell}rc"
            echo 'eval "$(uvx --generate-shell-completion '"$shell"')" ' >> "$(find_user_home)/.${shell}rc"
            set_remote_ownership "$(find_user_home)/.${shell}rc"
            ;;
        fish)
            if [ ! -d "$(find_user_home)/.config/fish/completions" ]; then
                mkdir -p "$(find_user_home)/.config/fish/completions"
            fi
            echo 'uv generate-shell-completion fish | source' >> "$(find_user_home)/.config/fish/config.fish"
            echo 'uvx --generate-shell-completion fish | source' >> "$(find_user_home)/.config/fish/config.fish"
            set_remote_ownership "$(find_user_home)/.config"
            ;;
        elvish)
            if [ ! -d "$(find_user_home)/.elvish" ]; then
                mkdir -p "$(find_user_home)/.elvish"
            fi
            echo 'eval (uv generate-shell-completion elvish | slurp)' >> "$(find_user_home)/.elvish/rc.elv"
            echo 'eval (uvx --generate-shell-completion elvish | slurp)' >> "$(find_user_home)/.elvish/rc.elv"
            set_remote_ownership "$(find_user_home)/.elvish"
            ;;
        *)
            echo "Shell $shell is not supported for autocompletion setup."
            ;;
    esac
}

install_uv() {
    local version="$UV_VERSION"
    local download_url=""

    require_command curl

    echo "Installing UV version: $version"

    if [ "$version" = "latest" ]; then
        download_url="https://astral.sh/uv/install.sh"
    else
        download_url="https://astral.sh/uv/${version}/install.sh"
    fi
    echo "Downloading and running UV installer from $download_url ..."
    curl -LsSf "$download_url" | remote_user_do sh
    uv_command="$(find_user_home)/.local/bin/uv"
    echo "UV installation completed."
}

prepare_uv_dirs() {
    mkdir -p /opt/uv/cache /opt/uv/python
    set_remote_ownership /opt/uv
    chmod -R o+rwX /opt/uv
}

create_default_venv() {
    echo "Creating default virtual environment at /opt/uv/venv..."
    remote_user_do "${uv_command}" venv /opt/uv/venv
    set_remote_ownership /opt/uv/venv
    chmod -R o+rwX /opt/uv/venv
}

init_autocompletion() {
    if [ -z "$COMPLETION_SHELL" ] || [ "$COMPLETION_SHELL" = "none" ]; then
        echo "Autocompletion setup skipped as per configuration."
        return
    fi
    local installed_shells
    installed_shells=($(detect_installed_shell))
    echo "Detected installed shells: ${installed_shells[*]}"

    local target_shells=()
    if [ "$COMPLETION_SHELL" = "automatic" ]; then
        target_shells=("${installed_shells[@]}")
    else
        local completion_shells
        IFS=',' read -r -a completion_shells <<< "$COMPLETION_SHELL"
        for shell in "${installed_shells[@]}"; do
            for target in "${completion_shells[@]}"; do
                if [ "$shell" = "$target" ]; then
                    target_shells+=("$shell")
                fi
            done
        done
    fi
    echo "Target shells for autocompletion setup: ${target_shells[*]}"

    for shell in "${target_shells[@]}"; do
        if check_is_init_autocompletion "$shell"; then
            echo "Skipping autocompletion setup for $shell."
        else
            setup_autocompletion "$shell"
        fi
    done
}

# Main installation flow
install_uv
prepare_uv_dirs
create_default_venv
init_autocompletion

echo "UV installation script completed."
