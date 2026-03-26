#!/bin/bash

set -euo pipefail


INSTALL_SCRIPT_URL="https://mirror.ctan.org/systems/texlive/tlnet/install-tl-unx.tar.gz"
TEMP_DIR=/tmp/texlive

SCHEME=${SCHEME:-"medium"}
PAPER=${PAPER:-"a4"}
DOC_INSTALL=${DOCINSTALL:-"true"}
SRC_INSTALL=${SRCINSTALL:-"true"}
REPO_URL=${REPOURL:-"automatic"}


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
    echo "Downloading TeX Live installation script..."
    rm -rf "${TEMP_DIR}"
    mkdir -p "${TEMP_DIR}"
    curl -L -o "${TEMP_DIR}/install-tl-unx.tar.gz" "${INSTALL_SCRIPT_URL}"
    tar xf "${TEMP_DIR}/install-tl-unx.tar.gz" -C "${TEMP_DIR}" --strip-components=1
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
cleanup_texlive
download_install_script
install_texlive
post_install_configuration
# Clean up temporary directory
rm -rf "${TEMP_DIR}"
echo "TeX Live installation completed successfully."
