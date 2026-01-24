#!/usr/bin/env bash

set -euo pipefail


INSTALL_DIR="/opt/heasoft"
VERSION="${VERSION:-"6.36"}"
TMP_DIR=$(mktemp -d)

export CC=/usr/bin/gcc
export CXX=/usr/bin/g++
export FC=/usr/bin/gfortran
export PERL=/usr/bin/perl
export PYTHON=/usr/bin/python3


# Detect the Linux distribution
distro_detect() {
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        echo "$ID"
    else
        echo "unknown"
    fi
}


install_apt_deps() {
    local pkgs=(
        build-essential
        libreadline-dev
        libncurses5-dev
        curl
        libcurl4-gnutls-dev
        xorg-dev
        gfortran
        python3-dev
        python3-pip
        aria2
    )
    apt-get update
    DEBIAN_FRONTEND=noninteractive apt-get install -y "${pkgs[@]}"
    rm -rf /var/lib/apt/lists/*
}


install_pacman_deps() {
    local pkgs=(
        base-devel
        gcc-fortran
        curl
        libxt
        perl-devel-checklib
        perl-file-which
        python
        python-pip
        python-setuptools
        python-astropy
        python-numpy
        python-scipy
        python-matplotlib
        aria2
    )
    pacman -Syu --noconfirm
    pacman -S --noconfirm --needed "${pkgs[@]}"
}


install_dnf_deps() {
    local pkgs=(
        redhat-rpm-config 
        readline-devel 
        ncurses-devel 
        zlib-devel 
        libcurl-devel 
        libXt-devel 
        make 
        gcc 
        gcc-c++ 
        gcc 
        gcc-gfortran 
        perl-devel 
        perl-Devel-CheckLib 
        perl-DirHandle 
        perl-Env 
        perl-ExtUtils-MakeMaker 
        perl-File-Which 
        python3-devel 
        # python3-astropy 
        python3-numpy 
        # python3-matplotlib
    )
    local pip_pkgs=(
        scipy
        astropy
        matplotlib
    )

    if dnf list aria2 >/dev/null 2>&1; then
        pkgs+=("aria2")
    else
        pkgs+=("curl")
    fi

    dnf check-update || true

    dnf install -y "${pkgs[@]}"
    pip3 install --break-system-packages "${pip_pkgs[@]}"
}


install_zypper_deps() {
    local patterns=(
        devel_basis
    )
    local pkgs=(
        readline-devel
        ncurses-devel
        libcurl-devel
        libXt-devel
        gcc-fortran
        perl-Devel-CheckLib
        perl-File-Which
        python3-devel
        python3-pip
        python3-setuptools
        python3-astropy
        python3-numpy
        python3-scipy
        python3-matplotlib
        aria2
    )
    zypper up -y
    zypper install -y "${pkgs[@]}"
    zypper install -t pattern "${patterns[@]}"
}


install_emerge_deps() {
    local pkgs=(
        sys-libs/readline
        sys-libs/ncurses
        net-misc/curl
        x11-libs/libXt
        dev-perl/Devel-CheckLib
        dev-perl/File-Which
        dev-python/astropy
        dev-python/numpy
        dev-python/scipy
        dev-python/matplotlib
        net-p2p/aria2
    )
    emerge -av sys-devel/gcc[fortran]
    emerge --ask "${pkgs[@]}"
}


install_apk_deps() {
    local pkgs=(
        build-base
        gfortran
        readline-dev
        ncurses-dev
        curl-dev
        libxt-dev
        perl-dev
        python3-dev
        py3-pip
        py3-setuptools
        py3-numpy
        py3-scipy
        aria2
        py3-matplotlib
        tcl-dev
        tk-dev
        tcl-readline=~2.1.0
    )
    apk add --no-cache "${pkgs[@]}"
    ls -l /usr/lib
    exit 1
    pip3 install --break-system-packages astropy
}


# Main installation function
install_deps() {
    local distro
    distro=$(distro_detect)

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
        almalinux|rocky)
            install_dnf_deps
            ;;
        opensuse*|sles)
            install_zypper_deps
            ;;
        alpine)
            install_apk_deps
            ;;
        *)
            echo "Unsupported or unknown distribution: $distro"
            echo "Please install dependencies manually."
            exit 1
            ;;
    esac
}


download_heasoft() {
    local src_url="https://heasarc.gsfc.nasa.gov/FTP/software/lheasoft/lheasoft${VERSION}/heasoft-${VERSION}src.tar.gz"

    echo "Downloading HEASoft ${VERSION}..."
    if command -v aria2c >/dev/null 2>&1; then
        echo "Using aria2c for multi-threaded download..."
        aria2c --max-tries=5 -x 16 -s 32 "${src_url}" -d "${TMP_DIR}" -o "heasoft.tar.gz"
    else
        echo "aria2c not found, falling back to curl..."
        curl --retry 5 -Lf "${src_url}" -o "${TMP_DIR}/heasoft.tar.gz"
    fi

    echo "Extracting HEASoft..."
    tar -xzf "${TMP_DIR}/heasoft.tar.gz" -C "${TMP_DIR}"
}


install_heasoft() {
    local source_dir="${TMP_DIR}/heasoft-${VERSION}"
    if [ ! -d "${source_dir}" ]; then
        echo "Error: Expected source directory ${source_dir} does not exist."
        exit 1
    fi

    cd "${source_dir}/BUILD_DIR"
    ./configure --prefix="${INSTALL_DIR}"

    echo "Building HEASoft (this may take a long time)..."
    make
    echo "Installing HEASoft..."
    make install

    echo "Cleaning up..."
    rm -rf "${TMP_DIR}"
}


setup_environment() {
    echo "Setting up environment variables..."
    local headas_init=$(ls -d ${INSTALL_DIR}/*/headas-init.sh | head -n 1)
    if [ -z "${headas_init}" ]; then
        echo "Error: headas-init.sh not found. Installation might have failed."
        exit 1
    fi
    local headas_dir=$(dirname "${headas_init}")

    {
        echo "export HEADAS=${headas_dir}"
        echo '. $HEADAS/headas-init.sh'
    } > /etc/profile.d/heasoft.sh
    chmod +x /etc/profile.d/heasoft.sh

    {
        echo "setenv HEADAS ${headas_dir}"
        echo 'source $HEADAS/headas-init.csh'
    } > /etc/profile.d/heasoft.csh
    chmod +x /etc/profile.d/heasoft.csh
}


# Main script execution
echo "Installing dependencies..."
install_deps
download_heasoft
install_heasoft
setup_environment
echo "HEASoft ${VERSION} installation completed successfully."
