# System Packages (pkg)

Installs system packages on various Linux distributions.

## Feature Options

| Option | Description | Value Type | Default Value |
|---|---|---|---|
| pkg | Comma-separated list of packages to install on any distribution. | string | - |
| apt | Comma-separated list of packages to install on Debian/Ubuntu (apt). | string | - |
| pacman | Comma-separated list of packages to install on Arch Linux (pacman). | string | - |
| dnf | Comma-separated list of packages to install on Fedora/RHEL/CentOS (dnf). | string | - |
| dnf_group | Comma-separated list of groups to install on Fedora/RHEL/CentOS (dnf). | string | - |
| yum | Comma-separated list of packages to install via yum. | string | - |
| emerge | Comma-separated list of packages to install on Gentoo (emerge). | string | - |
| rpm_ostree | Comma-separated list of packages to install via rpm-ostree. | string | - |
| zypper | Comma-separated list of packages to install on openSUSE (zypper). | string | - |
| zypper_pattern | Comma-separated list of patterns to install on openSUSE (zypper). | string | - |
| apk | Comma-separated list of packages to install on Alpine Linux (apk). | string | - |
| xbps | Comma-separated list of packages to install on Void Linux (xbps). | string | - |
| nix | Comma-separated list of packages to install via Nix (nix-env). | string | - |

## Usage

```json
"features": {
    "ghcr.io/zenless-lab/devcontainer-features/pkg:1": {
        "pkg": "git,curl",
        "apt": "build-essential"
    }
}
```

## Overview

This feature allows you to install system packages on various Linux distributions solely by configuration, without writing `RUN` commands in your Dockerfile. It automatically detects the package manager and installs the specified packages.
