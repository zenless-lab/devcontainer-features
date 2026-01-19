# Tauri Dependencies Dev Container Feature

This feature installs system dependencies required for [Tauri v2](https://v2.tauri.app/) development.

## Overview

- **Installation**: Detects the system package manager and installs the necessary libraries and tools.
- **Dependencies**: Installs `webkit2gtk`, `openssl`, `curl`, `wget`, `file`, `libappindicator`, `librsvg`, etc., based on the distribution.

## Supported Package Managers

The `install.sh` script attempts to detect and use the following package managers:

- `apt-get` (Debian/Ubuntu)
- `pacman` (Arch Linux)
- `dnf` (Fedora/RHEL)
- `emerge` (Gentoo)
- `rpm-ostree` (Fedora Silverblue/Kinoite)
- `zypper` (openSUSE)
- `apk` (Alpine Linux)
- `xbps-install` (Void Linux)
- `nix-env` (NixOS)

## Usage

Add this feature to your `devcontainer.json`:

```json
"features": {
    "ghcr.io/zenless-lab/devcontainer-features/tauri:1": {}
}
```
