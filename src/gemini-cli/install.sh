#!/usr/bin/env bash

set -euo pipefail

readonly GEMINI_CLI_VERSION="${GEMINICLIVERSION:-latest}"

readonly GEMINI_CLI_CACHE="/opt/gemini-cli"
readonly GEMINI_CLI_AUTH_FILE="${GEMINI_CLI_CACHE}/oauth_creds.json"
readonly GEMINI_CLI_ACCOUNT_FILE="${GEMINI_CLI_CACHE}/google_accounts.json"
readonly GEMINI_CLI_SETTINGS_FILE="${GEMINI_CLI_CACHE}/settings.json"


remote_user_home() {
	if [ "${_REMOTE_USER:-}" = "root" ]; then
		echo "/root"
	else
		echo "/home/${_REMOTE_USER}"
	fi
}


setup_gemini_cli() {
	readonly GEMINI_CLI_HOME="$(remote_user_home)/.gemini"
	readonly ACL_SCRIPT_PATH="/usr/local/share/acl-scripts/gemini-cli-acls.sh"

	if [ -n "${GEMINI_CLI_CACHE}" ]; then
		mkdir -p "${GEMINI_CLI_CACHE}"
	fi
	chmod o+rwx "${GEMINI_CLI_CACHE}"

	if [ -n "${GEMINI_CLI_HOME}" ]; then
		mkdir -p "${GEMINI_CLI_HOME}"
	fi
	chown "${_REMOTE_USER}:" "${GEMINI_CLI_HOME}"
	chmod o+rwx "${GEMINI_CLI_HOME}"

	if [ ! -f "${GEMINI_CLI_AUTH_FILE}" ]; then
		echo "{}" > "${GEMINI_CLI_AUTH_FILE}"
	fi
	chmod u=rw,go= "${GEMINI_CLI_AUTH_FILE}"
	ln -s "${GEMINI_CLI_AUTH_FILE}" "${GEMINI_CLI_HOME}/oauth_creds.json"

	if [ ! -f "${GEMINI_CLI_ACCOUNT_FILE}" ]; then
		echo "{}" > "${GEMINI_CLI_ACCOUNT_FILE}"
	fi
	chmod u=rw,go=r "${GEMINI_CLI_ACCOUNT_FILE}"
	ln -s "${GEMINI_CLI_ACCOUNT_FILE}" "${GEMINI_CLI_HOME}/google_accounts.json"

	if [ ! -f "${GEMINI_CLI_SETTINGS_FILE}" ]; then
		echo "{}" > "${GEMINI_CLI_SETTINGS_FILE}"
	fi
	chmod u=rw,go= "${GEMINI_CLI_SETTINGS_FILE}"
	ln -s "${GEMINI_CLI_SETTINGS_FILE}" "${GEMINI_CLI_HOME}/settings.json"

	mkdir -p "$(dirname "${ACL_SCRIPT_PATH}")"
	tee "${ACL_SCRIPT_PATH}" > /dev/null <<EOF
#!/bin/bash
set -e

sudo setfacl -m "u:${_REMOTE_USER}:rw" "${GEMINI_CLI_AUTH_FILE}"
sudo setfacl -m "u:${_REMOTE_USER}:rw" "${GEMINI_CLI_ACCOUNT_FILE}"
sudo setfacl -m "u:${_REMOTE_USER}:rw" "${GEMINI_CLI_SETTINGS_FILE}"
EOF
	chmod +x "${ACL_SCRIPT_PATH}"
}


install_gemini_cli() {
	local package_spec="@google/gemini-cli"

	if [ "${GEMINI_CLI_VERSION}" != "latest" ]; then
		package_spec="${package_spec}@${GEMINI_CLI_VERSION}"
	fi

	echo "Installing ${package_spec} with npm"
	npm install -g ${package_spec}
}


echo "Activating feature 'gemini-cli'"
setup_gemini_cli
install_gemini_cli
echo "Finished installing Gemini CLI"
