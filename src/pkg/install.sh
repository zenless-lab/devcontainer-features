#!/bin/sh

set -eu

log_info() {
    printf '[INFO] %s\n' "$*"
}

log_warn() {
    printf '[WARN] %s\n' "$*" >&2
}

log_error() {
    printf '[ERROR] %s\n' "$*" >&2
}

trim() {
    printf '%s' "$1" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//'
}

join_args() {
    left=$(trim "$1")
    right=$(trim "$2")

    if [ -n "$left" ] && [ -n "$right" ]; then
        printf '%s %s' "$left" "$right"
        return
    fi

    printf '%s%s' "$left" "$right"
}

has_command() {
    command -v "$1" >/dev/null 2>&1
}

warn_if_set() {
    option_name=$1
    option_value=$(trim "$2")

    if [ -n "$option_value" ]; then
        log_warn "Ignoring option '${option_name}' for detected package manager '${ACTIVE_MANAGER}': ${option_value}"
    fi
}

PKG=$(trim "${PKG:-}")
APT=$(trim "${APT:-}")
PACMAN=$(trim "${PACMAN:-}")
DNF=$(trim "${DNF:-}")
DNF_GROUP=$(trim "${DNFGROUP:-}")
YUM=$(trim "${YUM:-}")
EMERGE=$(trim "${EMERGE:-}")
RPM_OSTREE=$(trim "${RPMOSTREE:-}")
ZYPPER=$(trim "${ZYPPER:-}")
ZYPPER_PATTERN=$(trim "${ZYPPERPATTERN:-}")
APK=$(trim "${APK:-}")

install_apt_deps() {
    install_pkgs=$(join_args "$PKG" "$APT")
    if [ -z "$install_pkgs" ]; then
        log_info 'No apt packages requested.'
        return
    fi

    export DEBIAN_FRONTEND=noninteractive
    log_info "Installing apt packages: ${install_pkgs}"
    apt-get update
    eval "set -- ${install_pkgs}"
    apt-get install -y "$@"
    log_info 'Cleaning apt cache.'
    rm -rf /var/lib/apt/lists/*
}

install_apk_deps() {
    install_pkgs=$(join_args "$PKG" "$APK")
    if [ -z "$install_pkgs" ]; then
        log_info 'No apk packages requested.'
        return
    fi

    log_info "Installing apk packages: ${install_pkgs}"
    eval "set -- ${install_pkgs}"
    apk add --no-cache "$@"
}

install_dnf_deps() {
    install_pkgs=$(join_args "$PKG" "$DNF")
    install_groups=$DNF_GROUP
    did_install=false

    if [ -n "$install_pkgs" ]; then
        log_info "Installing dnf packages: ${install_pkgs}"
        dnf check-update || true
        eval "set -- ${install_pkgs}"
        dnf install -y "$@"
        did_install=true
    fi

    if [ -n "$install_groups" ]; then
        log_info "Installing dnf groups: ${install_groups}"
        eval "set -- ${install_groups}"
        dnf group install -y "$@"
        did_install=true
    fi

    if [ "$did_install" = true ]; then
        log_info 'Cleaning dnf cache.'
        dnf clean all
    else
        log_info 'No dnf packages requested.'
    fi
}

install_yum_deps() {
    install_pkgs=$(join_args "$PKG" "$YUM")
    if [ -z "$install_pkgs" ]; then
        log_info 'No yum packages requested.'
        return
    fi

    log_info "Installing yum packages: ${install_pkgs}"
    eval "set -- ${install_pkgs}"
    yum install -y "$@"
    log_info 'Cleaning yum cache.'
    yum clean all
}

install_pacman_deps() {
    install_pkgs=$(join_args "$PKG" "$PACMAN")
    if [ -z "$install_pkgs" ]; then
        log_info 'No pacman packages requested.'
        return
    fi

    log_info "Installing pacman packages: ${install_pkgs}"
    pacman -Syu --noconfirm
    eval "set -- ${install_pkgs}"
    pacman -S --noconfirm --needed "$@"
    log_info 'Cleaning pacman cache.'
    pacman -Scc --noconfirm >/dev/null 2>&1 || true
}

install_zypper_deps() {
    install_pkgs=$(join_args "$PKG" "$ZYPPER")
    install_patterns=$ZYPPER_PATTERN
    did_install=false

    if [ -n "$install_pkgs" ]; then
        log_info "Installing zypper packages: ${install_pkgs}"
        zypper --non-interactive refresh
        eval "set -- ${install_pkgs}"
        zypper --non-interactive install "$@"
        did_install=true
    fi

    if [ -n "$install_patterns" ]; then
        log_info "Installing zypper patterns: ${install_patterns}"
        eval "set -- ${install_patterns}"
        zypper --non-interactive install -t pattern "$@"
        did_install=true
    fi

    if [ "$did_install" = true ]; then
        log_info 'Cleaning zypper cache.'
        zypper clean -a
    else
        log_info 'No zypper packages requested.'
    fi
}

install_emerge_deps() {
    install_pkgs=$(join_args "$PKG" "$EMERGE")
    if [ -z "$install_pkgs" ]; then
        log_info 'No emerge packages requested.'
        return
    fi

    log_info "Installing emerge packages: ${install_pkgs}"
    eval "set -- ${install_pkgs}"
    emerge --quiet "$@"
}

install_rpm_ostree_deps() {
    install_pkgs=$(join_args "$PKG" "$RPM_OSTREE")
    if [ -z "$install_pkgs" ]; then
        log_info 'No rpm-ostree packages requested.'
        return
    fi

    log_info "Installing rpm-ostree packages: ${install_pkgs}"
    eval "set -- ${install_pkgs}"
    rpm-ostree install "$@"
}

detect_package_manager() {
    if has_command apt-get; then
        printf 'apt'
        return
    fi

    if has_command apk; then
        printf 'apk'
        return
    fi

    if has_command dnf; then
        printf 'dnf'
        return
    fi

    if has_command yum; then
        printf 'yum'
        return
    fi

    if has_command pacman; then
        printf 'pacman'
        return
    fi

    if has_command zypper; then
        printf 'zypper'
        return
    fi

    if has_command emerge; then
        printf 'emerge'
        return
    fi

    if has_command rpm-ostree; then
        printf 'rpm-ostree'
        return
    fi

    log_error 'Unsupported distribution: no known package manager detected.'
    exit 1
}

warn_ignored_options() {
    case "$1" in
        apt)
            warn_if_set 'apk' "$APK"
            warn_if_set 'dnf' "$DNF"
            warn_if_set 'dnfGroup' "$DNF_GROUP"
            warn_if_set 'yum' "$YUM"
            warn_if_set 'pacman' "$PACMAN"
            warn_if_set 'zypper' "$ZYPPER"
            warn_if_set 'zypperPattern' "$ZYPPER_PATTERN"
            warn_if_set 'emerge' "$EMERGE"
            warn_if_set 'rpmOstree' "$RPM_OSTREE"
            ;;
        apk)
            warn_if_set 'apt' "$APT"
            warn_if_set 'dnf' "$DNF"
            warn_if_set 'dnfGroup' "$DNF_GROUP"
            warn_if_set 'yum' "$YUM"
            warn_if_set 'pacman' "$PACMAN"
            warn_if_set 'zypper' "$ZYPPER"
            warn_if_set 'zypperPattern' "$ZYPPER_PATTERN"
            warn_if_set 'emerge' "$EMERGE"
            warn_if_set 'rpmOstree' "$RPM_OSTREE"
            ;;
        dnf)
            warn_if_set 'apt' "$APT"
            warn_if_set 'apk' "$APK"
            warn_if_set 'yum' "$YUM"
            warn_if_set 'pacman' "$PACMAN"
            warn_if_set 'zypper' "$ZYPPER"
            warn_if_set 'zypperPattern' "$ZYPPER_PATTERN"
            warn_if_set 'emerge' "$EMERGE"
            warn_if_set 'rpmOstree' "$RPM_OSTREE"
            ;;
        yum)
            warn_if_set 'apt' "$APT"
            warn_if_set 'apk' "$APK"
            warn_if_set 'dnf' "$DNF"
            warn_if_set 'dnfGroup' "$DNF_GROUP"
            warn_if_set 'pacman' "$PACMAN"
            warn_if_set 'zypper' "$ZYPPER"
            warn_if_set 'zypperPattern' "$ZYPPER_PATTERN"
            warn_if_set 'emerge' "$EMERGE"
            warn_if_set 'rpmOstree' "$RPM_OSTREE"
            ;;
        pacman)
            warn_if_set 'apt' "$APT"
            warn_if_set 'apk' "$APK"
            warn_if_set 'dnf' "$DNF"
            warn_if_set 'dnfGroup' "$DNF_GROUP"
            warn_if_set 'yum' "$YUM"
            warn_if_set 'zypper' "$ZYPPER"
            warn_if_set 'zypperPattern' "$ZYPPER_PATTERN"
            warn_if_set 'emerge' "$EMERGE"
            warn_if_set 'rpmOstree' "$RPM_OSTREE"
            ;;
        zypper)
            warn_if_set 'apt' "$APT"
            warn_if_set 'apk' "$APK"
            warn_if_set 'dnf' "$DNF"
            warn_if_set 'dnfGroup' "$DNF_GROUP"
            warn_if_set 'yum' "$YUM"
            warn_if_set 'pacman' "$PACMAN"
            warn_if_set 'emerge' "$EMERGE"
            warn_if_set 'rpmOstree' "$RPM_OSTREE"
            ;;
        emerge)
            warn_if_set 'apt' "$APT"
            warn_if_set 'apk' "$APK"
            warn_if_set 'dnf' "$DNF"
            warn_if_set 'dnfGroup' "$DNF_GROUP"
            warn_if_set 'yum' "$YUM"
            warn_if_set 'pacman' "$PACMAN"
            warn_if_set 'zypper' "$ZYPPER"
            warn_if_set 'zypperPattern' "$ZYPPER_PATTERN"
            warn_if_set 'rpmOstree' "$RPM_OSTREE"
            ;;
        rpm-ostree)
            warn_if_set 'apt' "$APT"
            warn_if_set 'apk' "$APK"
            warn_if_set 'dnf' "$DNF"
            warn_if_set 'dnfGroup' "$DNF_GROUP"
            warn_if_set 'yum' "$YUM"
            warn_if_set 'pacman' "$PACMAN"
            warn_if_set 'zypper' "$ZYPPER"
            warn_if_set 'zypperPattern' "$ZYPPER_PATTERN"
            warn_if_set 'emerge' "$EMERGE"
            ;;
    esac
}

install_deps() {
    case "$1" in
        apt)
            install_apt_deps
            ;;
        apk)
            install_apk_deps
            ;;
        dnf)
            install_dnf_deps
            ;;
        yum)
            install_yum_deps
            ;;
        pacman)
            install_pacman_deps
            ;;
        zypper)
            install_zypper_deps
            ;;
        emerge)
            install_emerge_deps
            ;;
        rpm-ostree)
            install_rpm_ostree_deps
            ;;
    esac
}

ACTIVE_MANAGER=$(detect_package_manager)
log_info "Detected package manager: ${ACTIVE_MANAGER}"
warn_ignored_options "$ACTIVE_MANAGER"
install_deps "$ACTIVE_MANAGER"
