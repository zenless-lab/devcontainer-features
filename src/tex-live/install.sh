#!/bin/bash

set -euo pipefail


INSTALL_SCRIPT_URL="https://mirror.ctan.org/systems/texlive/tlnet/install-tl-unx.tar.gz"
TEMP_DIR=/tmp/texlive

SCHEME=${SCHEME:-"medium"}
PAPER=${PAPER:-"a4"}
DOC_INSTALL=${DOC_INSTALL}
SRC_INSTALL=${SRC_INSTALL}
REPO_URL=${REPO_URL:-"automatic"}


DEPS=(
    curl
    ca-certificates
    perl
    xz-utils
    gzip
    tar
    sudo
)


remote_user_do() {
    sudo -i -u "$_REMOTE_USER" -- "$@"
}


get_remote_user_home() {
    if [ -n "${_REMOTE_USER:-}" ] && [ "${_REMOTE_USER}" != "root" ]; then
        echo "/home/${_REMOTE_USER}"
    else
        echo "/root"
    fi
}


detect_distro() {
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        echo "$ID"
    else
        echo "unknown"
    fi
}


install_apt_deps() {
    export DEBIAN_FRONTEND=noninteractive

    echo "Installing dependencies: ${DEPS[*]}"
    apt-get update
    apt-get install -y "${DEPS[@]}"
    rm -rf /var/lib/apt/lists/*
}


install_yum_deps() {
    echo "Installing dependencies: ${DEPS[*]}"
    yum install -y "${DEPS[@]}"
    yum clean all
}


install_pacman_deps() {
    echo "Installing dependencies: ${DEPS[*]}"
    pacman -Syu --noconfirm
    pacman -S --noconfirm --needed "${DEPS[@]}"
}


install_dnf_deps() {
    echo "Installing dependencies: ${DEPS[*]}"
    dnf check-update || true
    dnf install -y "${DEPS[@]}"
}


install_apk_deps() {
    local apk_pkgs=(
        curl
        ca-certificates
        perl
        xz
        gzip
        tar
        sudo
    )
    echo "Installing dependencies: ${apk_pkgs[*]}"
    apk add --no-cache "${apk_pkgs[@]}"
}


install_zypper_deps() {
    echo "Installing dependencies: ${DEPS[*]}"
    zypper refresh
    zypper install -y "${DEPS[@]}"
}


print_parameters() {
    echo "Installation parameters:"
    echo "  Scheme:        ${SCHEME}"
    echo "  Paper size:   ${PAPER}"
    echo "  Doc install:  ${DOC_INSTALL}"
    echo "  Src install:  ${SRC_INSTALL}"
    echo "  Repo URL:     ${REPO_URL}"
}


install_deps() {
    local distro
    distro=$(detect_distro)

    case "${distro}" in
        ubuntu|debian)
            install_apt_deps
            ;;
        centos|rhel|rocky|almalinux)
            install_yum_deps
            ;;
        fedora)
            install_dnf_deps
            ;;
        arch)
            install_pacman_deps
            ;;
        alpine)
            install_apk_deps
            ;;
        opensuse*|sles)
            install_zypper_deps
            ;;
        *)
            echo "Unsupported distribution: ${distro}. Please install dependencies manually: ${DEPS[*]}"
            exit 1
            ;;
    esac
}


cleanup_texlive() {
    echo "Cleaning up any existing TeX Live installations..."
    local user_home
    user_home=$(get_remote_user_home)

    rm -rf /usr/local/texlive/*
    rm -rf "${user_home}/.texlive*"
    echo "Cleanup completed."
}


download_install_script() {
    echo "Downloading TeX Live installation script..."
    rm -rf "${TEMP_DIR}"
    mkdir -p "${TEMP_DIR}"
    curl -L -o "${TEMP_DIR}/install-tl-unx.tar.gz" "${INSTALL_SCRIPT_URL}"
    tar xf "${TEMP_DIR}/install-tl-unx.tar.gz" -C "${TEMP_DIR}" --strip-components=1
    chmod -R +x "${TEMP_DIR}"
    chown -R "$_REMOTE_USER" "${TEMP_DIR}"
    echo "TeX Live installation script downloaded."
}


install_texlive() {
    echo "Starting TeX Live installation..."

    # Ensure target directory exists and is writable by the user
    mkdir -p /usr/local/texlive
    chown "$_REMOTE_USER" /usr/local/texlive

    local install_options=()
    install_options+=("--no-interaction")
    install_options+=("--scheme" "${SCHEME}")
    install_options+=("--paper" "${PAPER}")
    
    if [ "${DOC_INSTALL}" = "0" ] || [ "${DOC_INSTALL}" = "false" ]; then
        install_options+=("--no-doc-install")
    else
        install_options+=("--doc-install")
    fi
    
    if [ "${SRC_INSTALL}" = "0" ] || [ "${SRC_INSTALL}" = "false" ]; then
        install_options+=("--no-src-install")
    else
        install_options+=("--src-install")
    fi
    
    if [ "${REPO_URL}" != "automatic" ]; then
        install_options+=("--repository" "${REPO_URL}")
    fi

    remote_user_do perl "${TEMP_DIR}/install-tl" "${install_options[@]}"
    echo "TeX Live installation completed."
}


post_install_configuration() {
    echo "Configuring TeX Live environment..."
    
    local texlive_year
    texlive_year=$(ls /usr/local/texlive/ | grep -E '^[0-9]{4}$' | sort -r | head -n 1)
    
    if [ -z "${texlive_year}" ]; then
        echo "Error: Could not determine TeX Live year. Installation might have failed."
        exit 1
    fi

    local bin_root="/usr/local/texlive/${texlive_year}/bin"
    local bin_dir=""

    if [ -d "${bin_root}" ]; then
        bin_dir=$(find "${bin_root}" -mindepth 1 -maxdepth 1 -type d | head -n 1)
    fi
    
    if [ -z "${bin_dir}" ] || [ ! -d "${bin_dir}" ]; then
        echo "Error: TeX Live binary directory not found in ${bin_root}"
        exit 1
    fi

    echo "Found binary directory: ${bin_dir}"

    # Add to path for the current session to use tlmgr
    export PATH="${bin_dir}:$PATH"

    # Create symlinks for tlmgr and other binaries
    if command -v tlmgr >/dev/null 2>&1; then
        echo "Creating symlinks for TeX Live binaries..."
        tlmgr path add
    else
        echo "Warning: tlmgr not executable. Symlinks not created."
    fi
    # Persist PATH for future sessions
    echo "export PATH=\"${bin_dir}:\$PATH\"" > /etc/profile.d/00-texlive.sh
    chmod +x /etc/profile.d/00-texlive.sh
    
    echo "TeX Live configuration completed."
}


# Main execution
echo "Starting TeX Live installation..."
print_parameters
install_deps
cleanup_texlive
download_install_script
install_texlive
post_install_configuration
# Clean up temporary directory
rm -rf "${TEMP_DIR}"
echo "TeX Live installation completed successfully."
