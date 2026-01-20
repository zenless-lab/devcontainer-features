#!/bin/sh

set -eu

PKG=${PKG:-}

APT=${APT:-}
PACMAN=${PACMAN:-}
DNF=${DNF:-}
DNF_GROUP=${DNF_GROUP:-}
YUM=${YUM:-}
EMERGE=${EMERGE:-}
RPM_OSTREE=${RPM_OSTREE:-}
ZYPPER=${ZYPPER:-}
ZYPPER_PATTERN=${ZYPPER_PATTERN:-}
APK=${APK:-}


install_apt_deps() {
    export DEBIAN_FRONTEND=noninteractive

    install_pkgs="$(echo "${PKG}" | tr ',' ' ') $(echo "${APT}" | tr ',' ' ')"
    if [ -n "${install_pkgs}" ]; then
        apt-get update
        apt-get install -y ${install_pkgs}
        rm -rf /var/lib/apt/lists/*
    fi
}


install_pacman_deps() {
    install_pkgs="$(echo "${PKG}" | tr ',' ' ') $(echo "${PACMAN}" | tr ',' ' ')"
    if [ -n "${install_pkgs}" ]; then
        pacman -Syu --noconfirm
        pacman -S --noconfirm --needed ${install_pkgs}
    fi
}


install_dnf_deps() {
    install_pkgs="$(echo "${PKG}" | tr ',' ' ') $(echo "${DNF}" | tr ',' ' ')"
    if [ -n "${install_pkgs}" ]; then
        dnf check-update || true
        dnf install -y ${install_pkgs}
    fi
    install_groups="$(echo "${DNF_GROUP}" | tr ',' ' ')"
    if [ -n "${install_groups}" ]; then
        dnf groupinstall -y ${install_groups}
    fi
}


install_yum_deps() {
    install_pkgs="$(echo "${PKG}" | tr ',' ' ') $(echo "${YUM}" | tr ',' ' ')"
    if [ -n "${install_pkgs}" ]; then
        yum install -y ${install_pkgs}
    fi
}


install_emerge_deps() {
    install_pkgs="$(echo "${PKG}" | tr ',' ' ') $(echo "${EMERGE}" | tr ',' ' ')"
    if [ -n "${install_pkgs}" ]; then
        emerge --quiet ${install_pkgs}
    fi
}


install_rpm_ostree_deps() {
    install_pkgs="$(echo "${PKG}" | tr ',' ' ') $(echo "${RPM_OSTREE}" | tr ',' ' ')"
    if [ -n "${install_pkgs}" ]; then
        rpm-ostree install ${install_pkgs}
    fi
}


install_zypper_deps() {
    install_pkgs="$(echo "${PKG}" | tr ',' ' ') $(echo "${ZYPPER}" | tr ',' ' ')"
    if [ -n "${install_pkgs}" ]; then
        zypper up -y
        zypper in -y ${install_pkgs}
    fi
    install_patterns="$(echo "${ZYPPER_PATTERN}" | tr ',' ' ')"
    if [ -n "${install_patterns}" ]; then
        zypper in -y -t pattern ${install_patterns}
    fi
}


install_apk_deps() {
    install_pkgs="$(echo "${PKG}" | tr ',' ' ') $(echo "${APK}" | tr ',' ' ')"
    if [ -n "${install_pkgs}" ]; then
        apk add --no-cache ${install_pkgs}
    fi
}


detect_distro() {
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        echo "$ID"
    else
        echo "unknown"
    fi
}


install_deps() {
    distro=$(detect_distro)
    case "$distro" in
        ubuntu|debian)
            install_apt_deps
            ;;
        arch)
            install_pacman_deps
            ;;
        fedora|centos|rhel)
            install_dnf_deps
            ;;
        gentoo)
            install_emerge_deps
            ;;
        opensuse*|sles*)
            install_zypper_deps
            ;;
        alpine)
            install_apk_deps
            ;;
        *)
            echo "Unsupported distribution: $distro"
            exit 1
            ;;
    esac
}


# Install dependencies for openSUSE/SLE
install_deps
