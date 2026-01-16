# Micromamba Dev Container Feature

This feature installs the Micromamba package manager, a tiny, pure C++ executable package manager.

## Overview

- **Installation**: Downloads the Micromamba binary directly from `micro.mamba.pm`.
- **System Requirements**: Automatically installs dependencies (`curl`, `bzip2`, `ca-certificates`, `tar`) if missing.
- **Initialization**: Configures shell integration for specified shells.

## Scripts

### `install.sh`

The main entry point for the feature.

1.  **`prepare_deps`**: Ensures `curl`, `bzip2`, `ca-certificates`, and `tar` are available. Supports various package managers (`apt`, `apk`, `dnf`, `yum`, `microdnf`, `zypper`).
2.  **`install_micromamba`**: 
    -   Determines the download URL based on the `version` option and system architecture.
    -   Downloads and extracts the `micromamba` executable to `/usr/local/bin`.
3.  **`init_shells`**:
    -   Initializes shell integration (modifies rc files) for the specified shells (`bash`, `zsh`, `fish`).
    -   Runs `micromamba shell init` as the remote user to ensure correct file permissions and home directory usage.
