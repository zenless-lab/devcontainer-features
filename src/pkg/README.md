
# System Packages (pkg)

Installs system packages on various Linux distributions.

## Example Usage

```json
"features": {
    "ghcr.io/zenless-lab/devcontainer-features/pkg:2": {}
}
```

## Options

| Options Id | Description | Type | Default Value |
|-----|-----|-----|-----|
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



---

_Note: This file was auto-generated from the [devcontainer-feature.json](https://github.com/zenless-lab/devcontainer-features/blob/main/src/pkg/devcontainer-feature.json).  Add additional notes to a `NOTES.md`._
