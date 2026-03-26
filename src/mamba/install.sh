#!/usr/bin/env bash
set -euo pipefail

INIT_SHELLS="${INITSHELLS:-bash}"


# Execute command as remote user if specified
remote_user_do() {
    if [ -n "${_REMOTE_USER:-}" ] && [ "${_REMOTE_USER}" != "root" ]; then
        sudo -i -u "${_REMOTE_USER}" -- "$@"
    else
        "$@"
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
        wget
        sudo
    )
    apt-get update
    apt-get install -y "${pkgs[@]}"
    rm -rf /var/lib/apt/lists/*
}


# Install dependencies for Arch Linux
install_deps_pacman() {
    local pkgs=(
        wget
        sudo
    )
    pacman -Syu --noconfirm
    pacman -S --noconfirm --needed "${pkgs[@]}"
}


# Install dependencies for Fedora/CentOS/RHEL and compatibles
install_deps_dnf() {
    local pkgs=(
        wget
        sudo
    )
    if command -v dnf > /dev/null 2>&1; then
        dnf check-update || true
        dnf install -y "${pkgs[@]}"
    elif command -v yum > /dev/null 2>&1; then
        yum install -y "${pkgs[@]}"
    elif command -v microdnf > /dev/null 2>&1; then
        microdnf install -y "${pkgs[@]}"
    else
        echo "Neither dnf/yum/microdnf is available to install dependencies."
        exit 1
    fi
}


# Install dependencies for Alpine Linux
install_deps_apk() {
    local pkgs=(
        wget
        sudo
    )
    apk add --no-cache "${pkgs[@]}"
}


# Install dependencies for OpenSUSE/SLES
install_deps_zypper() {
    local pkgs=(
        wget
        sudo
    )
    zypper refresh
    zypper install -y "${pkgs[@]}"
}


# Install dependencies for microdnf-based images
install_deps_microdnf() {
    local pkgs=(
        wget
        sudo
    )
    microdnf install -y "${pkgs[@]}"
}


# Ensure wget is installed for downloading the installer
prepare_deps() {
    if command -v wget > /dev/null 2>&1 && command -v sudo > /dev/null 2>&1; then
        return
    fi

    local distro
    distro=$(distro_detect)
    case "$distro" in
        ubuntu|debian)
            install_deps_apt
            ;;
        arch)
            install_deps_pacman
            ;;
        fedora|centos|rhel|almalinux|rocky)
            install_deps_dnf
            ;;
        opensuse*|sles)
            install_deps_zypper
            ;;
        alpine)
            install_deps_apk
            ;;
        *)
            echo "wget/sudo is missing and could not be installed for distro: $distro"
            echo "Please install dependencies manually."
            exit 1
            ;;
    esac

    if ! command -v wget > /dev/null 2>&1; then
        echo "wget is missing after dependency installation."
        exit 1
    fi
}


# Download and run the Miniforge installer
install_mamba() {
    local version="${VERSION:-latest}"
    local install_script_url=""

    echo "Installing mamba version: $version"
    echo "Downloading and installing Miniforge..."
    # Determine URL based on version
    if [ "${version}" = "latest" ]; then
        install_script_url="https://github.com/conda-forge/miniforge/releases/latest/download/Miniforge3-$(uname)-$(uname -m).sh"
    else
        install_script_url="https://github.com/conda-forge/miniforge/releases/download/${version}/Miniforge3-${version}-$(uname)-$(uname -m).sh"
    fi

    wget "${install_script_url}" -O /tmp/miniforge.sh

    echo "Running Miniforge installer..."
    chmod +x /tmp/miniforge.sh
    # Run installer in batch mode
    remote_user_do bash /tmp/miniforge.sh -b

    echo "Cleaning up installer..."
    rm /tmp/miniforge.sh
}


# Check if the version supports the new 'shell init' command (>= 25.1.1-1)
check_is_new_init() {
    local version="${VERSION:-latest}"
    local min_version="25.1.1-1"

    if [[ "$version" == "latest" ]]; then
        return 0
    fi

    if [[ "$version" == "$min_version" ]]; then
        return 0
    fi

    local lowest=$(printf "%s\n%s" "$min_version" "$version" | sort -V | head -n1)

    if [[ "$lowest" == "$min_version" ]]; then
        return 0
    else
        return 1
    fi
}


# Initialize mamba for specified shells
init_shells() {
    local shells=$(echo "${INIT_SHELLS}" | tr ',' ' ')
    local version="${VERSION:-latest}"
    local mamba_path=""
    local init_command=""
    if [ -n "${_REMOTE_USER:-}" ] && [ "${_REMOTE_USER}" != "root" ]; then
        mamba_path="/home/${_REMOTE_USER}/miniforge3/bin/mamba"
    else
        mamba_path="/root/miniforge3/bin/mamba"
    fi

    if check_is_new_init; then
        echo "Using new mamba shell init method."
        init_command="${mamba_path} shell init -s"
        shell_init_opts="-s"
    else
        echo "Using legacy conda shell init method."
        init_command="${mamba_path} init"
    fi


    for current_shell in $shells; do
        case "$current_shell" in
            none)
                echo "Skipping shell initialization as 'none' was specified."
                ;;
            bash)
                echo "Initializing mamba for bash"
                remote_user_do ${init_command} bash
                ;;
            zsh)
                echo "Initializing mamba for zsh"
                remote_user_do ${init_command} zsh
                ;;
            fish)
                echo "Initializing mamba for fish"
                remote_user_do ${init_command} fish
                ;;
            tcsh)
                echo "Initializing mamba for tcsh"
                remote_user_do ${init_command} tcsh
                ;;
            xonsh)
                echo "Initializing mamba for xonsh"
                remote_user_do ${init_command} xonsh
                ;;
            powershell)
                echo "Initializing mamba for powershell"
                remote_user_do ${init_command} powershell
                ;;
            *)
                echo "Shell $current_shell is not supported for initialization."
                ;;
        esac
    done
}


echo "Activating feature 'mamba'"
prepare_deps
install_mamba
init_shells
echo "Done!"
