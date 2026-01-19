#!/bin/sh
set -eu

echo "Starting UV installation script..."

# NOTE: The `install.sh` script is always executed as root.

UV_VERSION="${VERSION:-latest}"
COMPLETION_SHELL="${COMPLETION_SHELL:-automatic}"


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
    case "$shell_name" in
        bash)
            local pattern="uv generate-shell-completion bash"
            local profile_files="~/.bashrc ~/.bash_profile ~/.profile"
            ;;
        zsh)
            local pattern="uv generate-shell-completion zsh"
            local profile_files="~/.zshrc"
            ;;
        fish)
            local pattern="uv generate-shell-completion fish"
            local profile_files="~/.config/fish/completions/uv.fish"
            ;;
        elvish)
            local pattern="uv generate-shell-completion elvish"
            local profile_files="~/.elvish/rc.elv"
            ;;
        *)
            echo "Shell $shell_name is not supported for autocompletion initialization."
            return 1
            ;;
    esac

    for file in $profile_files; do
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
            # su - "${_REMOTE_USER:-root}" -c "uv generate-shell-completion $shell >> ~/.${shell}rc"
            su - "${_REMOTE_USER:-root}" -c "echo 'eval \"\$(uv generate-shell-completion $shell)\"' >> ~/.${shell}rc"
            su - "${_REMOTE_USER:-root}" -c "echo 'eval \"\$(uvx generate-shell-completion $shell)\"' >> ~/.${shell}rc"
            ;;
        fish)
            # su - "${_REMOTE_USER:-root}" -c "uv generate-shell-completion fish > ~/.config/fish/completions/uv.fish"
            su - "${_REMOTE_USER:-root}" -c "echo 'uv generate-shell-completion fish | source' >> ~/.config/fish/config.fish"
            su - "${_REMOTE_USER:-root}" -c "echo 'uvx generate-shell-completion fish | source' >> ~/.config/fish/config.fish"
            ;;
        elvish)
            # su - "${_REMOTE_USER:-root}" -c "uv generate-shell-completion elvish >> ~/.elvish/rc.elv"
            su - "${_REMOTE_USER:-root}" -c "echo 'eval (uv generate-shell-completion elvish | slurp)' >> ~/.elvish/rc.elv"
            su - "${_REMOTE_USER:-root}" -c "echo 'eval (uvx generate-shell-completion elvish | slurp)' >> ~/.elvish/rc.elv"
            ;;
        *)
            echo "Shell $shell is not supported for autocompletion setup."
            ;;
    esac
}

install_deps() {
    if command -v curl >/dev/null 2>&1 && command -v ca-certificates >/dev/null 2>&1; then
        echo "Dependencies already installed."
        return
    fi

    echo "Installing dependencies for UV..."
    # APT: Debian/Ubuntu
    if command -v apt-get >/dev/null 2>&1; then
        apt-get update
        apt-get install -y curl ca-certificates
    # YUM: RHEL/CentOS(older)
    elif command -v yum >/dev/null 2>&1; then
        yum install -y curl ca-certificates
    # DNF: Fedora/CentOS(newer)
    elif command -v dnf >/dev/null 2>&1; then
        dnf install -y curl ca-certificates
    # Zypper: openSUSE/SLE
    elif command -v zypper >/dev/null 2>&1; then
        zypper install -y curl ca-certificates
    # Pacman: Arch Linux
    elif command -v pacman >/dev/null 2>&1; then
        pacman -Sy --noconfirm curl ca-certificates
    # APK: Alpine Linux
    elif command -v apk >/dev/null 2>&1; then
        apk add --no-cache curl ca-certificates
    else
        echo "No supported package manager found. Please install curl and ca-certificates manually."
        exit 1
    fi
}

install_uv() {
    local version="$UV_VERSION"
    local download_url=""

    echo "Installing UV version: $version"

    if [ "$version" = "latest" ]; then
        download_url="https://astral.sh/uv/install.sh"
    else
        download_url="https://astral.sh/uv/${version}/install.sh"
    fi
    echo "Downloading and running UV installer from $download_url ..."
    su - "${_REMOTE_USER:-root}" -c "curl -LsSf '$download_url' | sh"
    echo "UV installation completed."
}

init_autocompletion() {
    local installed_shells
    installed_shells=$(detect_installed_shell)
    echo "Detected installed shells: $installed_shells"

    local target_shells=""
    if [ "$COMPLETION_SHELL" = "automatic" ]; then
        target_shells="$installed_shells"
    else
        for shell in $installed_shells; do
            for target in $(echo "$COMPLETION_SHELL" | tr ',' ' '); do
                if [ "$shell" = "$target" ]; then
                    target_shells="${target_shells} $shell"
                fi
            done
        done
    fi
    echo "Target shells for autocompletion setup: $target_shells"

    for shell in $target_shells; do
        if check_is_init_autocompletion "$shell"; then
            echo "Skipping autocompletion setup for $shell."
        else
            setup_autocompletion "$shell"
        fi
    done
}

# Main installation flow
install_deps
install_uv
init_autocompletion

echo "UV installation script completed."
