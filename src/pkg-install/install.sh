#!/bin/bash

# Read options
ALL_PACKAGES=${ALL:-""}
APT_PACKAGES=${APT:-""}
YUM_PACKAGES=${YUM:-""}
DNF_PACKAGES=${DNF:-""}
PACMAN_PACKAGES=${PACMAN:-""}
ZYPPER_PACKAGES=${ZYPPER:-""}
RPM_PACKAGES=${RPM:-""}
APK_PACKAGES=${APK:-""}

USE_APT=${USE_APT:-true}
USE_YUM=${USE_YUM:-true}
USE_DNF=${USE_DNF:-true}
USE_PACMAN=${USE_PACMAN:-true}
USE_ZYPPER=${USE_ZYPPER:-true}
USE_RPM=${USE_RPM:-true}
USE_APK=${USE_APK:-true}

# Construct arguments for multi_install.sh
BEFORE_DOUBLE_DASH=($ALL_PACKAGES)
AFTER_DOUBLE_DASH=()

# Add packages to AFTER_DOUBLE_DASH with appropriate prefixes
for pkg in $APT_PACKAGES; do
    AFTER_DOUBLE_DASH+=("a+$pkg")
done
for pkg in $YUM_PACKAGES; do
    AFTER_DOUBLE_DASH+=("y+$pkg")
done
for pkg in $DNF_PACKAGES; do
    AFTER_DOUBLE_DASH+=("d+$pkg")
done
for pkg in $PACMAN_PACKAGES; do
    AFTER_DOUBLE_DASH+=("p+$pkg")
done
for pkg in $ZYPPER_PACKAGES; do
    AFTER_DOUBLE_DASH+=("z+$pkg")
done
for pkg in $RPM_PACKAGES; do
    AFTER_DOUBLE_DASH+=("r+$pkg")
done
for pkg in $APK_PACKAGES; do
    AFTER_DOUBLE_DASH+=("k+$pkg")
done

# Construct block list for multi_install.sh
BLOCK_LIST=()
if [ "$USE_APT" == false ]; then
    BLOCK_LIST+=("apt")
fi
if [ "$USE_YUM" == false ]; then
    BLOCK_LIST+=("yum")
fi
if [ "$USE_DNF" == false ]; then
    BLOCK_LIST+=("dnf")
fi
if [ "$USE_PACMAN" == false ]; then
    BLOCK_LIST+=("pacman")
fi
if [ "$USE_ZYPPER" == false ]; then
    BLOCK_LIST+=("zypper")
fi
if [ "$USE_RPM" == false ]; then
    BLOCK_LIST+=("rpm")
fi
if [ "$USE_APK" == false ]; then
    BLOCK_LIST+=("apk")
fi

# Call multi_install.sh with constructed arguments
echo "./multi_install.sh ${BEFORE_DOUBLE_DASH[@]} -b=\"$(IFS=,; echo "${BLOCK_LIST[*]}")\" -- ${AFTER_DOUBLE_DASH[@]}"
./multi_install.sh "${BEFORE_DOUBLE_DASH[@]}" -b="$(IFS=,; echo "${BLOCK_LIST[*]}")" -- "${AFTER_DOUBLE_DASH[@]}"