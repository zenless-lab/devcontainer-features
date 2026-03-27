#!/bin/bash

set -euo pipefail


INSTALL_SCRIPT_URL="https://mirror.ctan.org/systems/texlive/tlnet/install-tl-unx.tar.gz"
TEMP_DIR=/tmp/texlive

SCHEME=${SCHEME:-"medium"}
PAPER=${PAPER:-"a4"}
DOC_INSTALL=${DOCINSTALL:-"true"}
SRC_INSTALL=${SRCINSTALL:-"true"}
REPO_URL=${REPOURL:-"automatic"}
RESOLVED_REPO_URL=""



require_command() {
    local command_name="$1"

    if ! command -v "${command_name}" >/dev/null 2>&1; then
        echo "Missing required command: ${command_name}"
        exit 1
    fi
}


get_remote_user_home() {
    if [ -n "${_REMOTE_USER:-}" ] && [ "${_REMOTE_USER}" != "root" ]; then
        echo "/home/${_REMOTE_USER}"
    else
        echo "/root"
    fi
}


print_parameters() {
    echo "Installation parameters:"
    echo "  Scheme:       ${SCHEME}"
    echo "  Paper size:   ${PAPER}"
    echo "  Doc install:  ${DOC_INSTALL}"
    echo "  Src install:  ${SRC_INSTALL}"
    echo "  Repo URL:     ${REPO_URL}"
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
    local download_url
    local effective_url

    echo "Downloading TeX Live installation script..."
    require_command curl
    require_command tar
    require_command perl
    require_command xz
    rm -rf "${TEMP_DIR}"
    mkdir -p "${TEMP_DIR}"
    download_url="${INSTALL_SCRIPT_URL}"
    effective_url=$(curl -fsSL -w '%{url_effective}' -o "${TEMP_DIR}/install-tl-unx.tar.gz" "${download_url}")
    tar xf "${TEMP_DIR}/install-tl-unx.tar.gz" -C "${TEMP_DIR}" --strip-components=1

    if [ "${REPO_URL}" = "automatic" ]; then
        RESOLVED_REPO_URL=${effective_url%/install-tl-unx.tar.gz}
        echo "Resolved TeX Live repository: ${RESOLVED_REPO_URL}"
    else
        RESOLVED_REPO_URL=${REPO_URL}
    fi

    echo "TeX Live installation script downloaded."
}


install_texlive() {
    echo "Starting TeX Live installation..."

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

    if [ -n "${RESOLVED_REPO_URL}" ]; then
        install_options+=("--repository" "${RESOLVED_REPO_URL}")
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
cleanup_texlive
download_install_script
install_texlive
post_install_configuration
# Clean up temporary directory
rm -rf "${TEMP_DIR}"
echo "TeX Live installation completed successfully."
