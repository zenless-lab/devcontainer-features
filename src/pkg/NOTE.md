# System Packages (pkg)

Installs system packages on various Linux distributions.

## Feature Options

| Option | Description | Value Type | Default Value |
|---|---|---|---|
| pkg | Space-separated list of packages to install on any distribution. | string | - |
| apt | Space-separated list of packages to install on Debian/Ubuntu (apt). | string | - |
| pacman | Space-separated list of packages to install on Arch Linux (pacman). | string | - |
| dnf | Space-separated list of packages to install on Fedora/RHEL/CentOS (dnf). | string | - |
| dnfGroup | Space-separated list of groups to install on Fedora/RHEL/CentOS (dnf). Use quotes for group names that contain spaces. | string | - |
| yum | Space-separated list of packages to install via yum. | string | - |
| emerge | Space-separated list of packages to install on Gentoo (emerge). | string | - |
| rpmOstree | Space-separated list of packages to install via rpm-ostree. | string | - |
| zypper | Space-separated list of packages to install on openSUSE (zypper). | string | - |
| zypperPattern | Space-separated list of patterns to install on openSUSE (zypper). Use quotes for pattern names that contain spaces. | string | - |
| apk | Space-separated list of packages to install on Alpine Linux (apk). | string | - |

## Usage

```json
"features": {
    "ghcr.io/zenless-lab/devcontainer-features/pkg:1": {
        "pkg": "git curl",
        "apt": "build-essential"
    }
}
```

## Overview

This feature allows you to install system packages on various Linux distributions solely by configuration, without writing `RUN` commands in your Dockerfile. It detects the package manager by binary availability, logs the installation lifecycle, warns about ignored manager-specific options, and installs the specified packages.

## Quoted Groups

Use shell-style quotes when a DNF group or zypper pattern contains spaces.

```json
"features": {
    "ghcr.io/zenless-lab/devcontainer-features/pkg:1": {
        "dnfGroup": "'Development Tools'"
    }
}
```
