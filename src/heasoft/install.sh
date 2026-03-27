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
detect_distro() {
    local distro

    if [ -f /etc/os-release ]; then
        . /etc/os-release
        echo "$ID"
        return
    fi

    echo "unknown"
}


post_install_system_adjustments() {
    case "$(detect_distro)" in
        fedora|centos|rhel|almalinux|rocky)
            pip3 install --break-system-packages scipy astropy matplotlib
            ;;
        alpine)
            if [ ! -e '/usr/lib/libtclreadline-2.1.0.so' ]; then
                local source

                source=$(ls /usr/lib/libtclreadline-*.so 2>/dev/null | sort -V | tail -n 1)
                echo "Target missing. Creating symlink: ${source} -> /usr/lib/libtclreadline-2.1.0.so"
                ln -s "${source}" /usr/lib/libtclreadline-2.1.0.so
            fi
            pip3 install --break-system-packages astropy
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
echo "Installing HEASoft..."
post_install_system_adjustments
download_heasoft
install_heasoft
setup_environment
echo "HEASoft ${VERSION} installation completed successfully."
