#!/usr/bin/env bash
set -euo pipefail

INIT_SHELLS="${INITSHELLS:-bash}"

prepare_deps() {
    if ! type curl > /dev/null 2>&1 || ! type bzip2 > /dev/null 2>&1 || ! type tar > /dev/null 2>&1; then
        if [ -x "/usr/bin/apt-get" ]; then
            apt-get update && apt-get install -y curl bzip2 ca-certificates tar
            rm -rf /var/lib/apt/lists/*
        elif [ -x "/sbin/apk" ]; then
            apk add --no-cache curl bzip2 ca-certificates tar
        elif [ -x "/usr/bin/dnf" ] || [ -x "/usr/bin/yum" ]; then
            if [ -x "/usr/bin/dnf" ]; then _PKG_MNGR="dnf"; else _PKG_MNGR="yum"; fi
            # if curl-minimal is installed, replace it with curl
            $_PKG_MNGR install -y curl bzip2 ca-certificates tar
        elif [ -x "/usr/bin/microdnf" ]; then
            microdnf install -y curl bzip2 ca-certificates tar
        elif [ -x "/usr/bin/zypper" ]; then
            zypper install -y curl bzip2 ca-certificates tar
        else
            echo "curl, bzip2, ca-certificates, or tar is missing and could not be installed. Please install them manually."
            exit 1
        fi
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
                su - "${_REMOTE_USER}" -c "micromamba shell init -s bash -r \"${MICROMAMBA_ROOT}\""
                ;;
            zsh)
                echo "Initializing micromamba for zsh"
                su - "${_REMOTE_USER}" -c "micromamba shell init -s zsh -r \"${MICROMAMBA_ROOT}\""
                ;;
            fish)
                echo "Initializing micromamba for fish"
                su - "${_REMOTE_USER}" -c "micromamba shell init -s fish -r \"${MICROMAMBA_ROOT}\""
                ;;
            *)
                echo "Unsupported shell for initialization: $CURRENT_SHELL" >&2
                ;;
        esac
    done
}

echo "Activating feature 'micromamba'"
prepare_deps
install_micromamba
init_shells

echo "Done!"
