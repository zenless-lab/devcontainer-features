#!/bin/sh

set -eu

PKG=${PKG:-}

APT=${APT:-}
PACMAN=${PACMAN:-}
DNF=${DNF:-}
DNF_GROUP=${DNFGROUP:-}
YUM=${YUM:-}
EMERGE=${EMERGE:-}
RPM_OSTREE=${RPMOSTREE:-}
ZYPPER=${ZYPPER:-}
ZYPPER_PATTERN=${ZYPPERPATTERN:-}
APK=${APK:-}


install_apt_deps() {
    export DEBIAN_FRONTEND=noninteractive

    install_pkgs="$(echo "${PKG}" | tr ',' ' ') $(echo "${APT}" | tr ',' ' ')"
    install_pkgs=$(echo "$install_pkgs" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
    if [ -n "${install_pkgs}" ]; then
        echo "Installing packages: ${install_pkgs}"
        apt-get update
        apt-get install -y ${install_pkgs}
        rm -rf /var/lib/apt/lists/*
    fi
}


install_pacman_deps() {
    install_pkgs="$(echo "${PKG}" | tr ',' ' ') $(echo "${PACMAN}" | tr ',' ' ')"
    install_pkgs=$(echo "$install_pkgs" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
    if [ -n "${install_pkgs}" ]; then
        echo "Installing packages: ${install_pkgs}"
        pacman -Syu --noconfirm
        pacman -S --noconfirm --needed ${install_pkgs}
    fi
}


install_dnf_deps() {
    install_pkgs="$(echo "${PKG}" | tr ',' ' ') $(echo "${DNF}" | tr ',' ' ')"
    install_pkgs=$(echo "$install_pkgs" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
    if [ -n "${install_pkgs}" ]; then
        echo "Installing packages: ${install_pkgs}"
        dnf check-update || true
        dnf install -y ${install_pkgs}
    fi
    install_groups="$(echo "${DNF_GROUP}" | tr ',' ' ')"
    install_groups=$(echo "$install_groups" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
    if [ -n "${install_groups}" ]; then
        echo "Installing groups: ${install_groups}"
        dnf groupinstall -y ${install_groups}
    fi
}


install_yum_deps() {
    install_pkgs="$(echo "${PKG}" | tr ',' ' ') $(echo "${YUM}" | tr ',' ' ')"
    install_pkgs=$(echo "$install_pkgs" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
    if [ -n "${install_pkgs}" ]; then
        echo "Installing packages: ${install_pkgs}"
        yum install -y ${install_pkgs}
    fi
}


install_emerge_deps() {
    install_pkgs="$(echo "${PKG}" | tr ',' ' ') $(echo "${EMERGE}" | tr ',' ' ')"
    install_pkgs=$(echo "$install_pkgs" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
    if [ -n "${install_pkgs}" ]; then
        echo "Installing packages: ${install_pkgs}"
        emerge --quiet ${install_pkgs}
    fi
}


install_rpm_ostree_deps() {
    install_pkgs="$(echo "${PKG}" | tr ',' ' ') $(echo "${RPM_OSTREE}" | tr ',' ' ')"
    install_pkgs=$(echo "$install_pkgs" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
    if [ -n "${install_pkgs}" ]; then
        echo "Installing packages: ${install_pkgs}"
        rpm-ostree install ${install_pkgs}
    fi
}


install_zypper_deps() {
    install_pkgs="$(echo "${PKG}" | tr ',' ' ') $(echo "${ZYPPER}" | tr ',' ' ')"
    install_pkgs=$(echo "$install_pkgs" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
    if [ -n "${install_pkgs}" ]; then
        echo "Installing packages: ${install_pkgs}"
        zypper up -y
        zypper in -y ${install_pkgs}
    fi
    install_patterns="$(echo "${ZYPPER_PATTERN}" | tr ',' ' ')"
    install_patterns=$(echo "$install_patterns" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
    if [ -n "${install_patterns}" ]; then
        echo "Installing patterns: ${install_patterns}"
        zypper in -y -t pattern ${install_patterns}
    fi
}


install_apk_deps() {
    install_pkgs="$(echo "${PKG}" | tr ',' ' ') $(echo "${APK}" | tr ',' ' ')"
    install_pkgs=$(echo "$install_pkgs" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
    if [ -n "${install_pkgs}" ]; then
        echo "Installing packages: ${install_pkgs}"
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
        fedora|centos|rhel|almalinux|rocky)
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
