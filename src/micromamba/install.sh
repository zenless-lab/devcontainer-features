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
        curl
        bzip2
        ca-certificates
        tar
        sudo
    )
    apt-get update
    apt-get install -y "${pkgs[@]}"
    rm -rf /var/lib/apt/lists/*
}


# Install dependencies for Arch Linux
install_deps_pacman() {
    local pkgs=(
        curl
        bzip2
        ca-certificates
        tar
        sudo
    )
    pacman -Syu --noconfirm
    pacman -S --noconfirm --needed "${pkgs[@]}"
}


# Install dependencies for Fedora/CentOS/RHEL and compatibles
install_deps_dnf() {
    local pkgs=(
        curl
        bzip2
        ca-certificates
        tar
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


# Install dependencies for OpenSUSE/SLES
install_deps_zypper() {
    local pkgs=(
        curl
        bzip2
        ca-certificates
        tar
        sudo
    )
    zypper refresh
    zypper install -y "${pkgs[@]}"
}


# Install dependencies for Alpine Linux
install_deps_apk() {
    local pkgs=(
        curl
        bzip2
        ca-certificates
        tar
        sudo
    )
    apk add --no-cache "${pkgs[@]}"
}


# Install dependencies for microdnf-based images
install_deps_microdnf() {
    local pkgs=(
        curl
        bzip2
        ca-certificates
        tar
        sudo
    )
    microdnf install -y "${pkgs[@]}"
}

prepare_deps() {
    if command -v curl > /dev/null 2>&1 && command -v bzip2 > /dev/null 2>&1 && command -v tar > /dev/null 2>&1 && command -v sudo > /dev/null 2>&1; then
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
            echo "Dependencies are missing and could not be installed for distro: $distro"
            echo "Please install curl, bzip2, ca-certificates, tar and sudo manually."
            exit 1
            ;;
    esac

    if ! command -v curl > /dev/null 2>&1 || ! command -v bzip2 > /dev/null 2>&1 || ! command -v tar > /dev/null 2>&1; then
        echo "Required dependencies are still missing after installation."
        exit 1
    fi
}

install_micromamba() {
    local VERSION="${VERSION:-latest}"
    local ARCH=$(uname -m)

    case "$(uname)" in
        Linux)
            PLATFORM="linux" ;;
        Darwin)
            PLATFORM="osx" ;;
        *NT*)
            PLATFORM="win" ;;
    esac

    case "$ARCH" in
        aarch64|ppc64le|arm64)
            ;;  # pass
        *)
            ARCH="64" ;;
    esac

    case "$PLATFORM-$ARCH" in
        linux-aarch64|linux-ppc64le|linux-64|osx-arm64|osx-64|win-64)
            ;;  # pass
        *)
            echo "Failed to detect your OS" >&2
            exit 1
            ;;
    esac

    echo "Installing micromamba for architecture: $ARCH"

    if [ "${VERSION}" = "latest" ]; then
        RELEASE_URL="https://micro.mamba.pm/api/micromamba/${PLATFORM}-${ARCH}/latest"
    else
        RELEASE_URL="https://micro.mamba.pm/api/micromamba/${PLATFORM}-${ARCH}/${VERSION}"
    fi

    # Use a temporary directory for extraction to avoid depending on the current working directory
    local TMP_DIR
    TMP_DIR="$(mktemp -d)"
    curl -Ls "${RELEASE_URL}" | tar -xvj -C "${TMP_DIR}" bin/micromamba

    # Move micromamba to /usr/local/bin
    mv "${TMP_DIR}/bin/micromamba" /usr/local/bin/micromamba
    chmod +x /usr/local/bin/micromamba
    rm -rf "${TMP_DIR}"
}

init_shells() {
    local SHELLS=$(echo "${INIT_SHELLS}" | tr ',' ' ')
    if [ -n "${_REMOTE_USER:-}" ] && [ "${_REMOTE_USER}" != "root" ]; then
        MICROMAMBA_ROOT="/home/${_REMOTE_USER}/.micromamba"
    else
        MICROMAMBA_ROOT="/root/.micromamba"
    fi

    for CURRENT_SHELL in $SHELLS; do
        case "$CURRENT_SHELL" in
            bash)
                echo "Initializing micromamba for bash"
                remote_user_do micromamba shell init -s bash -r "${MICROMAMBA_ROOT}"
                ;;
            zsh)
                echo "Initializing micromamba for zsh"
                remote_user_do micromamba shell init -s zsh -r "${MICROMAMBA_ROOT}"
                ;;
            fish)
                echo "Initializing micromamba for fish"
                remote_user_do micromamba shell init -s fish -r "${MICROMAMBA_ROOT}"
                ;;
            *)
                echo "Unsupported shell for initialization: $CURRENT_SHELL" >&2
                ;;
        esac
    done
}

echo "Activating feature 'micromamba'"
prepare_deps
install_micromamba
init_shells

echo "Done!"
