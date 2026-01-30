#!/bin/bash
set -euo pipefail

echo "Starting UV installation script..."

# NOTE: The `install.sh` script is always executed as root.

UV_VERSION="${VERSION:-latest}"
COMPLETION_SHELL="${COMPLETION_SHELL:-automatic}"
PYTHON_VERSIONS="${PYTHON_VERSIONS:-automatic}"

uv_command=""


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


# Detect the Linux distribution
distro_detect() {
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        echo "$ID"
    else
        echo "unknown"
    fi
}


# Install dependencies for Ubuntu/Debian
install_deps_apt() {
    export DEBIAN_FRONTEND=noninteractive
    local pkgs=(
        sudo
        curl
        ca-certificates
    )
    apt-get update
    apt-get install -y "${pkgs[@]}"
    rm -rf /var/lib/apt/lists/*
}


# Install dependencies for Arch Linux
install_deps_pacman() {
    local pkgs=(
        sudo
        curl
        ca-certificates
    )
    pacman -Syu --noconfirm
    pacman -S --noconfirm --needed "${pkgs[@]}"
}


# Install dependencies for Fedora/CentOS/RHEL
install_deps_dnf() {
    local pkgs=(
        sudo
        curl
        ca-certificates
    )
    dnf check-update || true
    dnf install -y "${pkgs[@]}"
}


# Install dependencies for Gentoo
install_deps_emerge() {
    local pkgs=(
        app-admin/sudo
        net-misc/curl
        app-misc/ca-certificates
    )
    emerge --quiet "${pkgs[@]}"
}


# Install dependencies for RPM-OSTree systems
install_deps_rpm_ostree() {
    local pkgs=(
        sudo
        curl
        ca-certificates
    )
    rpm-ostree install "${pkgs[@]}"

    echo "Please reboot the system to complete the installation."
}


# Install dependencies for OpenSUSE/SLES
install_deps_zypper() {
    local pkgs=(
        sudo
        curl
        ca-certificates
    )
    zypper up -y
    zypper in -y "${pkgs[@]}"
}


# Install dependencies for Alpine Linux
install_deps_apk() {
    local pkgs=(
        sudo
        curl
        ca-certificates
    )
    apk add --no-cache "${pkgs[@]}"
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
            echo 'eval "$(uvx generate-shell-completion '"$shell"')" ' >> "$(find_user_home)/.${shell}rc"
            chown "${_REMOTE_USER:-root}":"${_REMOTE_USER:-root}" "$(find_user_home)/.${shell}rc"
            ;;
        fish)
            if [ ! -d "$(find_user_home)/.config/fish/completions" ]; then
                mkdir -p "$(find_user_home)/.config/fish/completions"
            fi
            echo 'uv generate-shell-completion fish | source' >> "$(find_user_home)/.config/fish/config.fish"
            echo 'uvx generate-shell-completion fish | source' >> "$(find_user_home)/.config/fish/config.fish"
            chown -R "${_REMOTE_USER:-root}":"${_REMOTE_USER:-root}" "$(find_user_home)/.config"
            ;;
        elvish)
            if [ ! -d "$(find_user_home)/.elvish" ]; then
                mkdir -p "$(find_user_home)/.elvish"
            fi
            echo 'eval (uv generate-shell-completion elvish | slurp)' >> "$(find_user_home)/.elvish/rc.elv"
            echo 'eval (uvx generate-shell-completion elvish | slurp)' >> "$(find_user_home)/.elvish/rc.elv"
            chown -R "${_REMOTE_USER:-root}":"${_REMOTE_USER:-root}" "$(find_user_home)/.elvish"
            ;;
        *)
            echo "Shell $shell is not supported for autocompletion setup."
            ;;
    esac
}

install_deps() {
    if command -v curl >/dev/null 2>&1 && command -v sudo >/dev/null 2>&1; then
        echo "Dependencies already installed."
        return
    fi

    echo "Installing dependencies for UV..."
    local distro
    distro=$(distro_detect)
    case "$distro" in
        ubuntu|debian)
            install_deps_apt
            ;;
        arch)
            install_deps_pacman
            ;;
        fedora|centos|rhel)
            install_deps_dnf
            ;;
        gentoo)
            install_deps_emerge
            ;;
        almalinux|rocky)
            install_deps_dnf
            ;;
        opensuse*|sles)
            install_deps_zypper
            ;;
        alpine)
            install_deps_apk
            ;;
        *)
            echo "Unsupported or unknown distribution: $distro"
            echo "Please install dependencies manually."
            exit 1
            ;;
    esac
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
    curl -LsSf "$download_url" | remote_user_do sh
    uv_command="$(find_user_home)/.local/bin/uv"
    echo "UV installation completed."
}

install_python_versions() {
    local versions_raw="$PYTHON_VERSIONS"

    if [ -z "$versions_raw" ]; then
        echo "Python installation skipped: empty version string."
        return
    fi

    if [ "$versions_raw" != "automatic" ]; then
        local versions=()
        IFS=',' read -r -a version <<< "$versions_raw"
        remote_user_do $uv_command python install ${version[*]}
        return
    else
        remote_user_do $uv_command python install
    fi
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
install_deps
install_uv
install_python_versions
init_autocompletion

echo "UV installation script completed."
