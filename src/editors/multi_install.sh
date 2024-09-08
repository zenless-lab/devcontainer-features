#!/bin/bash

set -e

# Package manager detection
detect_package_manager() {
    if command -v apt-get &> /dev/null; then
        echo "apt"
    elif command -v yum &> /dev/null; then
        echo "yum"
    elif command -v dnf &> /dev/null; then
        echo "dnf"
    elif command -v pacman &> /dev/null; then
        echo "pacman"
    elif command -v zypper &> /dev/null; then
        echo "zypper"
    elif command -v rpm &> /dev/null; then
        echo "rpm"
    elif command -v apk &> /dev/null; then
        echo "apk"
    else
        echo "unknown"
    fi
}

# Package installation
install_package() {
    echo "Installing packages for $1..."
    echo "Packages: ${@:2}"
    local package_manager=$1
    shift
    local packages=("$@")

    case "$package_manager" in
        apt)
            apt-get update
            apt-get install -y "${packages[@]}"
            ;;
        yum)
            yum install -y "${packages[@]}"
            ;;
        dnf)
            dnf install -y "${packages[@]}"
            ;;
        pacman)
            pacman -Syu --noconfirm "${packages[@]}"
            ;;
        zypper)
            zypper install -y "${packages[@]}"
            ;;
        rpm)
            rpm -i "${packages[@]}"
            ;;
        apk)
            apk add --no-cache "${packages[@]}"
            ;;
        *)
            echo "Unsupported package manager: $package_manager"
            exit 1
            ;;
    esac
}

# Split arguments
# Supported package managers: apt(a), rpm(r), yum(y), dnf(d), pacman(p), zypper(z), apk(k)
# Example: ./tmp.sh a+curl r-curl ary+curl
args=("$@")
before_double_dash=()
after_double_dash=()
found_double_dash=false

for arg in "${args[@]}"; do
    if [ "$arg" == "--" ]; then
        found_double_dash=true
        continue
    fi
    if [[ "$arg" == --block=* || "$arg" == -b=* ]]; then
        block_list+=(${arg#*=})
        continue
    fi
    if [ "$found_double_dash" == false ]; then
        before_double_dash+=("$arg")
    else
        after_double_dash+=("$arg")
    fi
done

apt_list=("${before_double_dash[@]}")
rpm_list=("${before_double_dash[@]}")
yum_list=("${before_double_dash[@]}")
dnf_list=("${before_double_dash[@]}")
pacman_list=("${before_double_dash[@]}")
zypper_list=("${before_double_dash[@]}")
apk_list=("${before_double_dash[@]}")

for item in "${after_double_dash[@]}"; do
    names="${item%%[+-]*}"
    operation="${item:$((${#names}))}"
    value="${operation:1}"
    operation="${operation:0:1}"

    for (( i=0; i<${#names}; i++ )); do
        name="${names:$i:1}"
        case "$name" in
            a)
                name="apt"
                ;;
            r)
                name="rpm"
                ;;
            y)
                name="yum"
                ;;
            d)
                name="dnf"
                ;;
            p)
                name="pacman"
                ;;
            z)
                name="zypper"
                ;;
            k)
                name="apk"
                ;;
        esac

        case "$name" in
            apt)
                if [ "$operation" == "-" ]; then
                    apt_list=("${apt_list[@]/$value}")
                elif [ "$operation" == "+" ]; then
                    apt_list+=("$value")
                fi
                ;;
            rpm)
                if [ "$operation" == "-" ]; then
                    rpm_list=("${rpm_list[@]/$value}")
                elif [ "$operation" == "+" ]; then
                    rpm_list+=("$value")
                fi
                ;;
            yum)
                if [ "$operation" == "-" ]; then
                    yum_list=("${yum_list[@]/$value}")
                elif [ "$operation" == "+" ]; then
                    yum_list+=("$value")
                fi
                ;;
            dnf)
                if [ "$operation" == "-" ]; then
                    dnf_list=("${dnf_list[@]/$value}")
                elif [ "$operation" == "+" ]; then
                    dnf_list+=("$value")
                fi
                ;;
            pacman)
                if [ "$operation" == "-" ]; then
                    pacman_list=("${pacman_list[@]/$value}")
                elif [ "$operation" == "+" ]; then
                    pacman_list+=("$value")
                fi
                ;;
            zypper)
                if [ "$operation" == "-" ]; then
                    zypper_list=("${zypper_list[@]/$value}")
                elif [ "$operation" == "+" ]; then
                    zypper_list+=("$value")
                fi
                ;;
            apk)
                if [ "$operation" == "-" ]; then
                    apk_list=("${apk_list[@]/$value}")
                elif [ "$operation" == "+" ]; then
                    apk_list+=("$value")
                fi
                ;;
        esac
    done
done

# Detect package manager
package_manager=$(detect_package_manager)

# Check if the detected package manager is blocked
IFS=',' read -r -a blocked_managers <<< "${block_list[0]}"
for blocked_manager in "${blocked_managers[@]}"; do
    if [ "$package_manager" == "$blocked_manager" ]; then
        echo "Package manager $package_manager is blocked. Exiting."
        exit 1
    fi
done

echo "Detected package manager: $package_manager"
echo "Install packages:"
echo "apt: ${apt_list[@]}"
echo "rpm: ${rpm_list[@]}"
echo "yum: ${yum_list[@]}"
echo "dnf: ${dnf_list[@]}"
echo "pacman: ${pacman_list[@]}"
echo "zypper: ${zypper_list[@]}"
echo "apk: ${apk_list[@]}"

# Install packages
case "$package_manager" in
    apt)
        install_package "apt" "${apt_list[@]}"
        ;;
    yum)
        install_package "yum" "${yum_list[@]}"
        ;;
    dnf)
        install_package "dnf" "${dnf_list[@]}"
        ;;
    pacman)
        install_package "pacman" "${pacman_list[@]}"
        ;;
    zypper)
        install_package "zypper" "${zypper_list[@]}"
        ;;
    rpm)
        install_package "rpm" "${rpm_list[@]}"
        ;;
    apk)
        install_package "apk" "${apk_list[@]}"
        ;;
    *)
        echo "Unsupported package manager: $package_manager"
        exit 1
        ;;
esac