#!/usr/bin/env bash

set -euo pipefail


install_deps_apt() {
    apt-get update
    # if libwebkit2gtk-4.1-dev is not available (e.g. Ubuntu 20.04), fall back to libwebkit2gtk-4.0-dev
    local WEBKIT_PKG=""
    if apt-cache show libwebkit2gtk-4.1-dev >/dev/null 2>&1; then
        WEBKIT_PKG="libwebkit2gtk-4.1-dev"
    else
        WEBKIT_PKG="libwebkit2gtk-4.0-dev libgtk-3-dev"
    fi

    DEBIAN_FRONTEND=noninteractive apt-get install -y \
        $WEBKIT_PKG \
        build-essential \
        curl \
        wget \
        file \
        libxdo-dev \
        libssl-dev \
        libayatana-appindicator3-dev \
        librsvg2-dev
    rm -rf /var/lib/apt/lists/*
}


install_deps_pacman() {
    pacman -Syu --noconfirm
    pacman -S --noconfirm --needed \
        webkit2gtk-4.1 \
        base-devel \
        curl \
        wget \
        file \
        openssl \
        appmenu-gtk-module \
        libappindicator-gtk3 \
        librsvg \
        xdotool
}


install_deps_dnf() {
    dnf check-update || true
    dnf install -y \
        webkit2gtk4.1-devel \
        openssl-devel \
        curl \
        wget \
        file \
        libappindicator-gtk3-devel \
        librsvg2-devel \
        libxdo-devel
    dnf group install -y "c-development"
}


install_deps_emerge() {
    emerge --ask \
        net-libs/webkit-gtk:4.1 \
        dev-libs/libappindicator \
        net-misc/curl \
        net-misc/wget \
        sys-apps/file
}


install_deps_rpm_ostree() {
    rpm-ostree install \
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
        make
    echo "Please reboot the system to complete the installation."
}


install_deps_zypper() {
    zypper up -y
    zypper in -y \
        webkit2gtk3-devel \
        libopenssl-devel \
        curl \
        wget \
        file \
        libappindicator3-1 \
        librsvg-devel
    zypper in -t pattern devel_basis
}


install_deps_apk() {
    apk add --no-cache \
        build-base \
        webkit2gtk-4.1-dev \
        curl \
        wget \
        file \
        openssl \
        libayatana-appindicator-dev \
        librsvg
}   


install_deps() {
    if command -v apt-get >/dev/null 2>&1; then
        install_deps_apt
    elif command -v pacman >/dev/null 2>&1; then
        install_deps_pacman
    elif command -v dnf >/dev/null 2>&1; then
        install_deps_dnf
    elif command -v emerge >/dev/null 2>&1; then
        install_deps_emerge
    elif command -v rpm-ostree >/dev/null 2>&1; then
        install_deps_rpm_ostree
    elif command -v zypper >/dev/null 2>&1; then
        install_deps_zypper
    elif command -v apk >/dev/null 2>&1; then
        install_deps_apk
    else
        echo "Unsupported package manager. Please install dependencies manually."
        exit 1
    fi
}


# Main installation flow
install_deps
