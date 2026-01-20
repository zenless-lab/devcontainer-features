# System Packages Feature

This feature allows you to install system packages on various Linux distributions solely by configuration, without writing `RUN` commands in your Dockerfile.

It supports:
- Debian/Ubuntu (`apt`)
- Arch Linux (`pacman`)
- Fedora/CentOS/RHEL (`dnf`, `yum`)
- Gentoo (`emerge`)
- openSUSE (`zypper`)
- Alpine Linux (`apk`)

You can specify common packages in `pkg` option, or distribution-specific packages in their respective options.
