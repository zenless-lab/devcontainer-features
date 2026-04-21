#!/usr/bin/env bash

set -euo pipefail

readonly CODEX_VERSION="${CODEXVERSION:-latest}"

readonly CODEX_CACHE="/opt/codex"
readonly CODEX_AUTH_FILE="${CODEX_CACHE}/auth.json"
readonly CODEX_CONFIG_FILE="${CODEX_CACHE}/config.toml"


remote_user_home() {
    if [ "${_REMOTE_USER:-}" = "root" ]; then
        echo "/root"
    else
        echo "/home/${_REMOTE_USER}"
    fi
}


setup_codex() {
    readonly CODEX_HOME="$(remote_user_home)/.codex"
    readonly ACL_SCRIPT_PATH="/usr/local/share/acl-scripts/codex-acls.sh"

    if [ -n "${CODEX_CACHE}" ]; then
        mkdir -p "${CODEX_CACHE}"
    fi
    chmod o+rwx "${CODEX_CACHE}"

    if [ -n "${CODEX_HOME}" ]; then
        mkdir -p "${CODEX_HOME}"
    fi
    chown "${_REMOTE_USER}:" "${CODEX_HOME}"
    chmod o+rwx "${CODEX_HOME}"

    if [ ! -f "${CODEX_AUTH_FILE}" ]; then
        echo "{}" > "${CODEX_AUTH_FILE}"
    fi
    chmod u=rw,go= "${CODEX_AUTH_FILE}"
    ln -sf "${CODEX_AUTH_FILE}" "${CODEX_HOME}/auth.json"

    touch "${CODEX_CONFIG_FILE}"
    chmod u=rw,go= "${CODEX_CONFIG_FILE}"
    ln -sf "${CODEX_CONFIG_FILE}" "${CODEX_HOME}/config.toml"

    mkdir -p "$(dirname "${ACL_SCRIPT_PATH}")"
    tee "${ACL_SCRIPT_PATH}" > /dev/null <<EOF
#!/bin/bash
set -e

sudo setfacl -m "u:${_REMOTE_USER}:rw" "${CODEX_AUTH_FILE}"
sudo setfacl -m "u:${_REMOTE_USER}:rw" "${CODEX_CONFIG_FILE}"
EOF
    chmod +x "${ACL_SCRIPT_PATH}"
}


install_codex() {
    local package_spec="@openai/codex"

    if [ "${CODEX_VERSION}" != "latest" ]; then
        package_spec="${package_spec}@${CODEX_VERSION}"
    fi

    echo "Installing ${package_spec} with npm"
    npm install -g "${package_spec}"
}


echo "Activating Codex CLI feature (version: ${CODEX_VERSION})"
setup_codex
install_codex
echo "Finished setting up Codex CLI"
