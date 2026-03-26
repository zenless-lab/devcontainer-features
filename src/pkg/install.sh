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


trim_space() {
    printf '%s' "$1" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//'
}


csv_to_words() {
    printf '%s' "$1" | tr ',' ' '
}


merge_lists() {
    merged=""
    for value in "$@"; do
        if [ -n "$value" ]; then
            merged="$merged $(csv_to_words "$value")"
        fi
    done
    trim_space "$merged"
}


install_apt_deps() {
    export DEBIAN_FRONTEND=noninteractive

    install_pkgs=$(merge_lists "$PKG" "$APT")
    if [ -n "${install_pkgs}" ]; then
        echo "Installing packages: ${install_pkgs}"
        apt-get update
        apt-get install -y ${install_pkgs}
        rm -rf /var/lib/apt/lists/*
    fi
}


install_pacman_deps() {
    install_pkgs=$(merge_lists "$PKG" "$PACMAN")
    if [ -n "${install_pkgs}" ]; then
        echo "Installing packages: ${install_pkgs}"
        pacman -Syu --noconfirm
        pacman -S --noconfirm --needed ${install_pkgs}
    fi
}


install_dnf_deps() {
    install_pkgs=$(merge_lists "$PKG" "$DNF")
    if [ -n "${install_pkgs}" ]; then
        echo "Installing packages: ${install_pkgs}"
        dnf check-update || true
        dnf install -y ${install_pkgs}
    fi

    install_groups=$(merge_lists "$DNF_GROUP")
    if [ -n "${install_groups}" ]; then
        echo "Installing groups: ${install_groups}"
        dnf groupinstall -y ${install_groups}
    fi
}


install_yum_deps() {
    install_pkgs=$(merge_lists "$PKG" "$DNF" "$YUM")
    if [ -n "${install_pkgs}" ]; then
        echo "Installing packages: ${install_pkgs}"
        yum install -y ${install_pkgs}
    fi

    install_groups=$(merge_lists "$DNF_GROUP")
    if [ -n "${install_groups}" ]; then
        echo "Installing groups: ${install_groups}"
        yum groupinstall -y ${install_groups}
    fi
}


install_microdnf_deps() {
    install_pkgs=$(merge_lists "$PKG" "$DNF")
    if [ -n "${install_pkgs}" ]; then
        echo "Installing packages: ${install_pkgs}"
        microdnf install -y ${install_pkgs}
    fi

    install_groups=$(merge_lists "$DNF_GROUP")
    if [ -n "${install_groups}" ]; then
        echo "Skipping dnfGroup on microdnf-based image: ${install_groups}"
    fi
}


install_emerge_deps() {
    install_pkgs=$(merge_lists "$PKG" "$EMERGE")
    if [ -n "${install_pkgs}" ]; then
        echo "Installing packages: ${install_pkgs}"
        emerge --quiet ${install_pkgs}
    fi
}


install_rpm_ostree_deps() {
    install_pkgs=$(merge_lists "$PKG" "$DNF" "$RPM_OSTREE")
    if [ -n "${install_pkgs}" ]; then
        echo "Installing packages: ${install_pkgs}"
        rpm-ostree install ${install_pkgs}
    fi
}


install_zypper_deps() {
    install_pkgs=$(merge_lists "$PKG" "$ZYPPER")
    if [ -n "${install_pkgs}" ]; then
        echo "Installing packages: ${install_pkgs}"
        zypper up -y
        zypper in -y ${install_pkgs}
    fi

    install_patterns=$(merge_lists "$ZYPPER_PATTERN")
    if [ -n "${install_patterns}" ]; then
        echo "Installing patterns: ${install_patterns}"
        zypper in -y -t pattern ${install_patterns}
    fi
}


install_apk_deps() {
    install_pkgs=$(merge_lists "$PKG" "$APK")
    if [ -n "${install_pkgs}" ]; then
        echo "Installing packages: ${install_pkgs}"
        apk add --no-cache ${install_pkgs}
    fi
}


install_deps() {
    if command -v apt-get >/dev/null 2>&1; then
            install_apt_deps
    elif command -v pacman >/dev/null 2>&1; then
            install_pacman_deps
    elif command -v rpm-ostree >/dev/null 2>&1; then
            install_rpm_ostree_deps
    elif command -v dnf >/dev/null 2>&1; then
            install_dnf_deps
    elif command -v yum >/dev/null 2>&1; then
            install_yum_deps
    elif command -v microdnf >/dev/null 2>&1; then
            install_microdnf_deps
    elif command -v emerge >/dev/null 2>&1; then
            install_emerge_deps
    elif command -v zypper >/dev/null 2>&1; then
            install_zypper_deps
    elif command -v apk >/dev/null 2>&1; then
            install_apk_deps
    else
        echo "Unsupported package manager. Please install dependencies manually."
        exit 1
    fi
}


install_deps
