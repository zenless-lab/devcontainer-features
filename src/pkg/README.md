
# System Packages (pkg)

Installs system packages on various Linux distributions.

## Example Usage

```json
"features": {
    "ghcr.io/zenless-lab/devcontainer-features/pkg:1": {}
}
```

## Options

| Options Id | Description | Type | Default Value |
|-----|-----|-----|-----|
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



---

_Note: This file was auto-generated from the [devcontainer-feature.json](https://github.com/zenless-lab/devcontainer-features/blob/main/src/pkg/devcontainer-feature.json).  Add additional notes to a `NOTES.md`._
