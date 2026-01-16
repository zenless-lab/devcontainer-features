#!/bin/bash
set -e

source dev-container-features-test-lib

check "distro is rockylinux" grep -q "rockylinux" /etc/os-release
check "micromamba binary exists" ls /usr/local/bin/micromamba
check "micromamba version" micromamba --version

reportResults
