#!/bin/bash

set -euo pipefail


OPENCODE_VERSION=${OPENCODE_VERSION:-"latest"}
SHELL_INIT=${SHELL_INIT:-"automatic"}

INSTALL_SCRIPT_URL="https://opencode.ai/install"

PKGS=(
    sudo
    curl
    ca-certificates
)


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
    sudo -i -u "${_REMOTE_USER}" -- "$@"
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
    apt-get update
    apt-get install -y "${PKGS[@]}"
    rm -rf /var/lib/apt/lists/*
}


# Install dependencies for Arch Linux
install_deps_pacman() {
    pacman -Syu --noconfirm
    pacman -S --noconfirm --needed "${PKGS[@]}"
}


# Install dependencies for Fedora/CentOS/RHEL
install_deps_dnf() {
    dnf check-update || true
    dnf install -y "${PKGS[@]}"
    dnf group install -y "c-development"
}


# Install dependencies for Gentoo
install_deps_emerge() {
    local emerge_pkgs=(
        sudo
        net-misc/curl
        app-misc/ca-certificates
    )
    emerge --quiet "${emerge_pkgs[@]}"
}


# Install dependencies for RPM-OSTree systems
install_deps_rpm_ostree() {
    rpm-ostree install "${PKGS[@]}"

    echo "Please reboot the system to complete the installation."
}


# Install dependencies for OpenSUSE/SLES
install_deps_zypper() {
    zypper up -y
    zypper in -y "${PKGS[@]}"
    zypper in -t pattern devel_basis
}


# Install dependencies for Alpine Linux
install_deps_apk() {
    apk add --no-cache "${PKGS[@]}"
}


# Main installation function
install_deps() {
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


# Install OpenCode
install_opencode() {
    echo "Installing OpenCode version: $OPENCODE_VERSION"
    if [ "$OPENCODE_VERSION" = "latest" ]; then
        remote_user_do curl -fsSL "$INSTALL_SCRIPT_URL" | remote_user_do bash -s -- --no-modify-path
    else
        echo "specific version detected: $OPENCODE_VERSION"
        remote_user_do curl -fsSL "$INSTALL_SCRIPT_URL" | remote_user_do bash -s -- --version "$OPENCODE_VERSION" --no-modify-path
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

    if grep -Fxq "$command" "$config_file"; then
        echo "Path already set in $config_file"
    elif [[ -w $config_file ]]; then
        remote_user_do echo -e "\n# opencode" >> "$config_file"
        remote_user_do echo "$command" >> "$config_file"
        chown "$(id -u ${_REMOTE_USER}):$(id -g ${_REMOTE_USER})" "$config_file"
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
install_deps
install_opencode
init_shell
echo "OpenCode installation and initialization complete."
