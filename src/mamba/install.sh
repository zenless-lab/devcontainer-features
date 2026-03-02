#!/usr/bin/env bash
set -euo pipefail

INIT_SHELLS="${INITSHELLS:-all}"


# Ensure wget is installed for downloading the installer
prepare_deps() {
    if ! command -v wget > /dev/null 2>&1; then
        if [ -x "/usr/bin/apt-get" ]; then
            apt-get update && apt-get install -y wget
            rm -rf /var/lib/apt/lists/*
        elif [ -x "/sbin/apk" ]; then
            apk add --no-cache wget
        else
            echo "wget is missing and could not be installed. Please install it manually."
            exit 1
        fi
    fi
}


# Download and run the Miniforge installer
install_mamba() {
    local version="${VERSION:-latest}"
    local install_script_url=""
    
    echo "Installing mamba version: $version"
    echo "Downloading and installing Miniforge..."
    # Determine URL based on version
    if [ "${version}" = "latest" ]; then
        install_script_url="https://github.com/conda-forge/miniforge/releases/latest/download/Miniforge3-$(uname)-$(uname -m).sh"
    else
        install_script_url="https://github.com/conda-forge/miniforge/releases/download/${version}/Miniforge3-${version}-$(uname)-$(uname -m).sh"
    fi

    wget "${install_script_url}" -O /tmp/miniforge.sh
    
    echo "Running Miniforge installer..."
    chmod +x /tmp/miniforge.sh
    # Run installer in batch mode
    su - "${_REMOTE_USER:-root}" -c "bash /tmp/miniforge.sh -b"

    echo "Cleaning up installer..."
    rm /tmp/miniforge.sh
}


# Check if the version supports the new 'shell init' command (>= 25.1.1-1)
check_is_new_init() {
    local version="${VERSION:-latest}"
    local min_version="25.1.1-1"

    if [[ "$version" == "latest" ]]; then
        return 0
    fi

    if [[ "$version" == "$min_version" ]]; then
        return 0
    fi

    local lowest=$(printf "%s\n%s" "$min_version" "$version" | sort -V | head -n1)

    if [[ "$lowest" == "$min_version" ]]; then
        return 0
    else
        return 1
    fi
}


# Initialize mamba for specified shells
init_shells() {
    local shells=$(echo "${INIT_SHELLS}" | tr ',' ' ')
    local version="${VERSION:-latest}"
    local mamba_path=""
    local init_command=""
    if [ -n "${_REMOTE_USER:-}" ] && [ "${_REMOTE_USER}" != "root" ]; then
        mamba_path="/home/${_REMOTE_USER}/miniforge3/bin/mamba"
    else
        mamba_path="/root/miniforge3/bin/mamba"
    fi

    if check_is_new_init; then
        echo "Using new mamba shell init method."
        init_command="${mamba_path} shell init -s"
        shell_init_opts="-s"
    else
        echo "Using legacy conda shell init method."
        init_command="${mamba_path} init"
    fi
    

    for current_shell in $shells; do
        case "$current_shell" in
            none)
                echo "Skipping shell initialization as 'none' was specified."
                ;;
            bash)
                echo "Initializing mamba for bash"
                su - "${_REMOTE_USER:-root}" -c "${init_command} bash"
                ;;
            zsh)
                echo "Initializing mamba for zsh"
                su - "${_REMOTE_USER:-root}" -c "${init_command} zsh"
                ;;
            fish)
                echo "Initializing mamba for fish"
                su - "${_REMOTE_USER:-root}" -c "${init_command} fish"
                ;;
            tcsh)
                echo "Initializing mamba for tcsh"
                su - "${_REMOTE_USER:-root}" -c "${init_command} tcsh"
                ;;
            xonsh)
                echo "Initializing mamba for xonsh"
                su - "${_REMOTE_USER:-root}" -c "${init_command} xonsh"
                ;;
            powershell)
                echo "Initializing mamba for powershell"
                su - "${_REMOTE_USER:-root}" -c "${init_command} powershell"
                ;;
            *)
                echo "Shell $current_shell is not supported for initialization." 
                ;;
        esac
    done
}


echo "Activating feature 'mamba'"
prepare_deps
install_mamba
init_shells
echo "Done!"
