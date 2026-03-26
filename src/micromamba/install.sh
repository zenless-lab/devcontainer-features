#!/usr/bin/env bash
set -euo pipefail

INIT_SHELLS="${INITSHELLS:-bash}"


# Execute command as remote user if specified
remote_user_do() {
    if [ -n "${_REMOTE_USER:-}" ] && [ "${_REMOTE_USER}" != "root" ]; then
        sudo -i -u "${_REMOTE_USER}" -- "$@"
    else
        "$@"
    fi
}

install_micromamba() {
    local VERSION="${VERSION:-latest}"
    local ARCH=$(uname -m)

    case "$(uname)" in
        Linux)
            PLATFORM="linux" ;;
        Darwin)
            PLATFORM="osx" ;;
        *NT*)
            PLATFORM="win" ;;
    esac

    case "$ARCH" in
        aarch64|ppc64le|arm64)
            ;;  # pass
        *)
            ARCH="64" ;;
    esac

    case "$PLATFORM-$ARCH" in
        linux-aarch64|linux-ppc64le|linux-64|osx-arm64|osx-64|win-64)
            ;;  # pass
        *)
            echo "Failed to detect your OS" >&2
            exit 1
            ;;
    esac

    echo "Installing micromamba for architecture: $ARCH"

    if [ "${VERSION}" = "latest" ]; then
        RELEASE_URL="https://micro.mamba.pm/api/micromamba/${PLATFORM}-${ARCH}/latest"
    else
        RELEASE_URL="https://micro.mamba.pm/api/micromamba/${PLATFORM}-${ARCH}/${VERSION}"
    fi

    # Use a temporary directory for extraction to avoid depending on the current working directory
    local TMP_DIR
    TMP_DIR="$(mktemp -d)"
    curl -Ls "${RELEASE_URL}" | tar -xvj -C "${TMP_DIR}" bin/micromamba

    # Move micromamba to /usr/local/bin
    mv "${TMP_DIR}/bin/micromamba" /usr/local/bin/micromamba
    chmod +x /usr/local/bin/micromamba
    rm -rf "${TMP_DIR}"
}

init_shells() {
    local SHELLS=$(echo "${INIT_SHELLS}" | tr ',' ' ')
    if [ -n "${_REMOTE_USER:-}" ] && [ "${_REMOTE_USER}" != "root" ]; then
        MICROMAMBA_ROOT="/home/${_REMOTE_USER}/.micromamba"
    else
        MICROMAMBA_ROOT="/root/.micromamba"
    fi

    for CURRENT_SHELL in $SHELLS; do
        case "$CURRENT_SHELL" in
            bash)
                echo "Initializing micromamba for bash"
                remote_user_do micromamba shell init -s bash -r "${MICROMAMBA_ROOT}"
                ;;
            zsh)
                echo "Initializing micromamba for zsh"
                remote_user_do micromamba shell init -s zsh -r "${MICROMAMBA_ROOT}"
                ;;
            fish)
                echo "Initializing micromamba for fish"
                remote_user_do micromamba shell init -s fish -r "${MICROMAMBA_ROOT}"
                ;;
            none)
                echo "Skipping shell initialization."
                ;;
            *)
                echo "Unsupported shell for initialization: $CURRENT_SHELL" >&2
                ;;
        esac
    done
}

echo "Activating feature 'micromamba'"
install_micromamba
init_shells

echo "Done!"
