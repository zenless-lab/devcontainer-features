#!/usr/bin/env bash

set -euo pipefail

GEMINI_CLI_VERSION="${GEMINICLIVERSION:-latest}"
SANDBOX_MODE="${SANDBOX:-false}"

readonly DEFAULT_PNPM_GLOBAL_DIR="/usr/local/share/pnpm-global"
readonly DEFAULT_PNPM_GLOBAL_BIN_DIR="/usr/local/bin"
readonly DEFAULT_GEMINI_CLI_HOME="/gemini-cli"
readonly DEFAULT_GEMINI_CONFIG_DIR="${DEFAULT_GEMINI_CLI_HOME}/.gemini"


configure_sandbox_env() {
	{
		echo "export GEMINI_SANDBOX=\"${SANDBOX_MODE}\""
		echo "export GEMINI_CLI_HOME=\"${DEFAULT_GEMINI_CLI_HOME}\""
	} > /etc/profile.d/gemini-cli.sh
	chmod 644 /etc/profile.d/gemini-cli.sh
}


has_pnpm_global_config() {
	local global_dir
	local global_bin_dir

	global_dir="$(pnpm config get global-dir 2>/dev/null || true)"
	global_bin_dir="$(pnpm config get global-bin-dir 2>/dev/null || true)"

	case "${global_dir}" in
		""|undefined|null)
			return 1
			;;
	esac

	case "${global_bin_dir}" in
		""|undefined|null)
			return 1
			;;
	esac

	return 0
}


resolve_pnpm_config_value() {
	local key="$1"
	local fallback="$2"
	local value

	value="$(pnpm config get "${key}" 2>/dev/null || true)"
	case "${value}" in
		""|undefined|null)
			echo "${fallback}"
			;;
		*)
			echo "${value}"
			;;
	esac
}


configure_pnpm_global_dirs() {
	if has_pnpm_global_config; then
		echo "pnpm global directories already configured. Reusing existing configuration."
		return
	fi

	mkdir -p "${DEFAULT_PNPM_GLOBAL_DIR}"
	chmod 755 "${DEFAULT_PNPM_GLOBAL_DIR}"
	pnpm config set global-dir "${DEFAULT_PNPM_GLOBAL_DIR}"
	pnpm config set global-bin-dir "${DEFAULT_PNPM_GLOBAL_BIN_DIR}"
}


export_pnpm_runtime_env() {
	local global_dir
	local global_bin_dir

	global_dir="$(resolve_pnpm_config_value global-dir "${DEFAULT_PNPM_GLOBAL_DIR}")"
	global_bin_dir="$(resolve_pnpm_config_value global-bin-dir "${DEFAULT_PNPM_GLOBAL_BIN_DIR}")"

	mkdir -p "${global_dir}" "${global_bin_dir}"
	export PNPM_HOME="${global_bin_dir}"
	case ":${PATH}:" in
		*":${PNPM_HOME}:"*)
			;;
		*)
			export PATH="${PNPM_HOME}:${PATH}"
			;;
	esac
}


install_gemini_cli() {
	local package_spec="@google/gemini-cli"

	if [ "${GEMINI_CLI_VERSION}" != "latest" ]; then
		package_spec="${package_spec}@${GEMINI_CLI_VERSION}"
	fi

	echo "Installing ${package_spec} with pnpm"
	pnpm add -g "${package_spec}"
}


prepare_gemini_config_dirs() {
	mkdir -p "${DEFAULT_GEMINI_CONFIG_DIR}"
	chmod 755 "${DEFAULT_GEMINI_CLI_HOME}" "${DEFAULT_GEMINI_CONFIG_DIR}"

	if [ -n "${_REMOTE_USER:-}" ] && [ "${_REMOTE_USER}" != "root" ]; then
		chown -R "${_REMOTE_USER}:${_REMOTE_USER}" "${DEFAULT_GEMINI_CLI_HOME}"
	else
		chown -R root:root "${DEFAULT_GEMINI_CLI_HOME}"
	fi
}


echo "Activating feature 'gemini-cli'"
configure_sandbox_env
configure_pnpm_global_dirs
export_pnpm_runtime_env
prepare_gemini_config_dirs
install_gemini_cli
echo "Finished installing Gemini CLI"
