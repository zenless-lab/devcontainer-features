#!/bin/bash

set -euo pipefail


INSTALL_SCRIPT_URL="https://mirror.ctan.org/systems/texlive/tlnet/install-tl-unx.tar.gz"
TEMP_DIR=/tmp/texlive

SCHEME=${SCHEME:-"medium"}
PAPER=${PAPER:-"a4"}
DOC_INSTALL=${DOC_INSTALL:-"true"}
SRC_INSTALL=${SRC_INSTALL:-"true"}
REPO_URL=${REPO_URL:-"automatic"}


DEPS=(
    curl
    ca-certificates
    perl
    xz-utils
    gzip
    tar
)


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
    echo "  Scheme:       ${SCHEME}"
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

    perl "${TEMP_DIR}/install-tl" "${install_options[@]}"
    echo "TeX Live installation completed."
}


post_install_configuration() {
    echo "Configuring TeX Live environment..."

    local year
    year=$(ls /usr/local/texlive/ | grep -E '^[0-9]{4}$' | sort -r | head -n 1)
    local platform
    platform=$(ls /usr/local/texlive/"${year}"/bin/ | head -n 1)
    local texlive_bin="/usr/local/texlive/${year}/bin/${platform}"
    echo "TeX Live binary directory: ${texlive_bin}"

    # echo "export PATH=${texlive_bin}:\$PATH" > /etc/profile.d/texlive.sh
    {
        echo ""
        echo "# TeX Live environment variables"
        echo "export PATH=${texlive_bin}:\$PATH"
    } > /etc/profile.d/texlive.sh
    chmod +x /etc/profile.d/texlive.sh

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
