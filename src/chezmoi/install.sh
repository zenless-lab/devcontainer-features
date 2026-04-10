#!/bin/bash

set -euo pipefail


INSTALL=${INSTALL:-true}
CONFIG=${CONFIG:-}
CONFIGFORMAT=${CONFIGFORMAT:-toml}

CHEZMOI_INSTALL_DIR=/usr/local/bin
CHEZMOI_INSTALL_URL=https://get.chezmoi.io
CHEZMOI_INSTALLER_SCRIPT=


is_true() {
    case "${1}" in
        true|TRUE|True|1|yes|YES|on|ON)
            return 0
            ;;
        *)
            return 1
            ;;
    esac
}


require_command() {
    local command_name=$1

    if ! command -v "${command_name}" >/dev/null 2>&1; then
        echo "Missing required command: ${command_name}"
        exit 1
    fi
}


detect_user_home() {
    if [ -n "${_REMOTE_USER:-}" ] && [ "${_REMOTE_USER}" != "root" ]; then
        echo "/home/${_REMOTE_USER}"
    else
        echo "/root"
    fi
}


install_chezmoi() {
    require_command curl
    mkdir -p "${CHEZMOI_INSTALL_DIR}"

    CHEZMOI_INSTALLER_SCRIPT=$(mktemp)

    echo "Downloading chezmoi installer..."
    curl -fsSL "${CHEZMOI_INSTALL_URL}" -o "${CHEZMOI_INSTALLER_SCRIPT}"

    echo "Installing chezmoi into ${CHEZMOI_INSTALL_DIR}..."
    sh "${CHEZMOI_INSTALLER_SCRIPT}" -b "${CHEZMOI_INSTALL_DIR}"
    rm -f "${CHEZMOI_INSTALLER_SCRIPT}"
    CHEZMOI_INSTALLER_SCRIPT=

    if [ ! -x "${CHEZMOI_INSTALL_DIR}/chezmoi" ]; then
        echo "chezmoi binary was not installed correctly."
        exit 1
    fi

    chown root:root "${CHEZMOI_INSTALL_DIR}/chezmoi"
    chmod 0755 "${CHEZMOI_INSTALL_DIR}/chezmoi"
}


write_config() {
    local user_home
    local user_name
    local config_dir
    local config_file

    user_home=$(detect_user_home)
    user_name=${_REMOTE_USER:-root}
    config_dir="${user_home}/.config/chezmoi"
    config_file="${config_dir}/chezmoi.${CONFIGFORMAT}"

    if [ ! -d "${user_home}/.config" ]; then
        mkdir -p "${user_home}/.config"
        chown "${user_name}:" "${user_home}/.config"
    fi

    mkdir -p "${config_dir}"
    printf '%s' "${CONFIG}" > "${config_file}"
    chown -R "${user_name}:" "${config_dir}"
}


echo "Activating feature 'chezmoi'"
trap 'rm -f "${CHEZMOI_INSTALLER_SCRIPT:-}"' EXIT
if is_true "${INSTALL}"; then
    install_chezmoi
fi
if [ -n "${CONFIG}" ]; then
    write_config
fi
echo "chezmoi done."
