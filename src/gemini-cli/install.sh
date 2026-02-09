#!/usr/bin/env bash

set -euo pipefail

GEMINI_CLI_VERSION="${GEMINI_CLI_VERSION:-latest}"


# Execute command as remote user if specified
remote_user_do() {
	if [ -n "${_REMOTE_USER:-}" ] && [ "${_REMOTE_USER}" != "root" ]; then
		sudo -i -u "${_REMOTE_USER}" -- "$@"
	else
		"$@"
	fi
}


# Find the home directory of the remote user
find_user_home() {
	if [ -n "${_REMOTE_USER:-}" ] && [ "${_REMOTE_USER}" != "root" ]; then
		echo "/home/${_REMOTE_USER}"
	else
		echo "/root"
	fi
}


# Resolve PNPM home directory
resolve_pnpm_home() {
	if [ -n "${PNPM_HOME:-}" ]; then
		echo "$PNPM_HOME"
		return
	fi
	if [ -n "${_REMOTE_USER:-}" ] && [ "${_REMOTE_USER}" != "root" ]; then
		echo "$(find_user_home)/.local/share/pnpm"
	else
		echo "/usr/local/share/pnpm"
	fi
}


# Resolve PNPM binary path
resolve_pnpm_bin() {
	local pnpm_home=$(resolve_pnpm_home)
	if command -v pnpm >/dev/null 2>&1; then
		echo "pnpm"
		return
	fi
	if [ -x "$pnpm_home/pnpm" ]; then
		echo "$pnpm_home/pnpm"
		return
	fi
	local tools_bin
	tools_bin=$(find "$pnpm_home/.tools/pnpm-exe" -maxdepth 2 -type f -name pnpm 2>/dev/null | head -n 1 || true)
	if [ -n "$tools_bin" ]; then
		echo "$tools_bin"
		return
	fi
	return 1
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
		sudo
		curl
		ca-certificates
	)
	apt-get update
	apt-get install -y "${pkgs[@]}"
	rm -rf /var/lib/apt/lists/*
}


# Install dependencies for Arch Linux
install_deps_pacman() {
	local pkgs=(
		sudo
		curl
		ca-certificates
	)
	pacman -Syu --noconfirm
	pacman -S --noconfirm --needed "${pkgs[@]}"
}


# Install dependencies for Fedora/CentOS/RHEL
install_deps_dnf() {
	local pkgs=(
		sudo
		curl
		ca-certificates
	)
	dnf check-update || true
	dnf install -y "${pkgs[@]}"
}


# Install dependencies for Gentoo
install_deps_emerge() {
	local pkgs=(
		app-admin/sudo
		net-misc/curl
		app-misc/ca-certificates
	)
	emerge --quiet "${pkgs[@]}"
}


# Install dependencies for RPM-OSTree systems
install_deps_rpm_ostree() {
	local pkgs=(
		sudo
		curl
		ca-certificates
	)
	rpm-ostree install "${pkgs[@]}"

	echo "Please reboot the system to complete the installation."
}


# Install dependencies for OpenSUSE/SLES
install_deps_zypper() {
	local pkgs=(
		sudo
		curl
		ca-certificates
	)
	zypper up -y
	zypper in -y "${pkgs[@]}"
}


# Install dependencies for Alpine Linux
install_deps_apk() {
	local pkgs=(
		sudo
		curl
		ca-certificates
	)
	apk add --no-cache "${pkgs[@]}"
}


# Main installation function
install_deps() {
	local distro
	distro=$(distro_detect)
	case "$distro" in
		ubuntu|debian)
			install_deps_apt
			;;
		arch)
			install_deps_pacman
			;;
		fedora|centos|rhel)
			install_deps_dnf
			;;
		gentoo)
			install_deps_emerge
			;;
		almalinux|rocky)
			install_deps_dnf
			;;
		opensuse*|sles)
			install_deps_zypper
			;;
		alpine)
			install_deps_apk
			;;
		*)
			echo "Unsupported or unknown distribution: $distro"
			echo "Please install dependencies manually."
			exit 1
			;;
	esac
}


# Configure PNPM environment variables and PATH
configure_pnpm_path() {
    local pnpm_home=$(resolve_pnpm_home)
    {
        echo 'export PNPM_HOME="'"${pnpm_home}"'"'
        echo 'case ":$PATH:" in'
        echo '    *":$PNPM_HOME:"*) ;;'
        echo '    *) export PATH="$PNPM_HOME:$PATH" ;;'
        echo 'esac'
    } > /etc/profile.d/pnpm.sh
	chmod 644 /etc/profile.d/pnpm.sh
}


# Install PNPM
install_pnpm() {
	# Check pnpm availability in the remote user context, since pnpm will be
	# invoked via remote_user_do later (e.g., in install_node/install_gemini_cli).
	if remote_user_do pnpm --version >/dev/null 2>&1; then
		echo "pnpm already installed for remote user. Skipping pnpm installation."
		return 0
	fi
	local pnpm_home
	pnpm_home=$(resolve_pnpm_home)

	echo "Installing latest pnpm version"
	remote_user_do env PNPM_HOME="$pnpm_home" PATH="$pnpm_home:$PATH" \
		bash -c "curl -fsSL https://get.pnpm.io/install.sh | bash -"
	export PNPM_HOME="$pnpm_home"
	export PATH="$PNPM_HOME:$PATH"
}


# Install Node.js using PNPM
install_node() {
	echo "Installing Node.js version: lts"
    local distro
    distro=$(distro_detect)
    if [ "$distro" = "alpine" ]; then
        echo "Installing Node.js from Alpine repository"
        apk add --no-cache nodejs npm
    else
	    remote_user_do pnpm env use --global lts
    fi
}


# Install Gemini CLI using PNPM
install_gemini_cli() {
	echo "Installing Gemini CLI version: $GEMINI_CLI_VERSION"
	if [ "$GEMINI_CLI_VERSION" = "latest" ]; then
		remote_user_do pnpm add -g @google/gemini-cli
	else
		remote_user_do pnpm add -g @google/gemini-cli@"$GEMINI_CLI_VERSION"
	fi
}

# Main script execution
install_deps
configure_pnpm_path
install_pnpm
install_node
install_gemini_cli
