#!/usr/bin/env bash

set -euo pipefail


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
# Compared to the official example, the `xdg-utils` dependency was added because stripped-down Docker images often lack `xdg-open`.
install_deps_apt() {
    export DEBIAN_FRONTEND=noninteractive
    local pkgs="\
        libwebkit2gtk-4.1-dev \
        build-essential \
        curl \
        wget \
        file \
        libxdo-dev \
        libssl-dev \
        libayatana-appindicator3-dev \
        librsvg2-dev \
        xdg-utils \
    "
    apt-get update 
    apt-get install -y $pkgs
    rm -rf /var/lib/apt/lists/*
}


# Install dependencies for Arch Linux
# Compared to the official example, the `xdg-utils` dependency was added because stripped-down Docker images often lack `xdg-open`.
install_deps_pacman() {
    local pkgs="\
        webkit2gtk-4.1 \
        base-devel \
        curl \
        wget \
        file \
        openssl \
        appmenu-gtk-module \
        libappindicator-gtk3 \
        librsvg \
        xdotool \
        xdg-utils \
    "
    pacman -Syu --noconfirm
    pacman -S --noconfirm --needed $pkgs
}


# Install dependencies for Fedora/CentOS/RHEL
# Compared to the official example, the `xdg-utils` dependency was added because stripped-down Docker images often lack `xdg-open`.
install_deps_dnf() {
    local pkgs="\
        webkit2gtk4.1-devel \    
        openssl-devel \
        curl \
        wget \
        file \
        libappindicator-gtk3-devel \
        librsvg2-devel \
        libxdo-devel \
        xdg-utils \
    "
    dnf check-update || true
    dnf install -y $pkgs
    dnf group install -y "c-development"
}


# Install dependencies for Gentoo
# Compared to the official example, the `xdg-utils` dependency was added because stripped-down Docker images often lack `xdg-open`.
install_deps_emerge() {
    local pkgs="\"
        net-libs/webkit-gtk:4.1 \
        dev-libs/libappindicator \
        net-misc/curl \
        net-misc/wget \
        sys-apps/file \
        x11-misc/xdg-utils \
    "
    emerge --ask $pkgs
}


# Install dependencies for RPM-OSTree systems
# Compared to the official example, the `xdg-utils` dependency was added because stripped-down Docker images often lack `xdg-open`.
install_deps_rpm_ostree() {
    local pkgs="\
        webkit2gtk4.1-devel \
        openssl-devel \
        curl \
        wget \
        file \
        libappindicator-gtk3-devel \
        librsvg2-devel \
        libxdo-devel \
        gcc \
        gcc-c++ \
        make \
        xdg-utils \
    "
    rpm-ostree install $pkgs

    echo "Please reboot the system to complete the installation."
}


# Install dependencies for OpenSUSE/SLES
# Compared to the official example, the `xdg-utils` dependency was added because stripped-down Docker images often lack `xdg-open`.
install_deps_zypper() {
    local pkgs="\
        webkit2gtk3-devel \
        libopenssl-devel \
        curl \
        wget \
        file \
        libappindicator3-1 \
        librsvg-devel \
        xdg-utils \
    "
    zypper up -y
    zypper in -y $pkgs
    zypper in -t pattern devel_basis
}


# Install dependencies for Alpine Linux
# Compared to the official example, the `xdg-utils` dependency was added because stripped-down Docker images often lack `xdg-open`.
install_deps_apk() {
    local pkgs="\
        build-base \
        webkit2gtk-4.1-dev \
        curl \
        wget \
        file \
        openssl \
        libayatana-appindicator-dev \
        librsvg \
        xdg-utils \
    "
    apk add --no-cache $pkgs
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


# Main installation flow
install_deps
