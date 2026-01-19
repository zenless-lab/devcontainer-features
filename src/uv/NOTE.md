# UV Dev Container Feature

This feature installs `uv`, an extremely fast Python package installer and resolver, written in Rust.

## Overview

- **Installation**: Downloads the official `uv` installer script.
- **Dependencies**: Ensures `curl` and `ca-certificates` are installed.
- **Initialization**: Configures shell autocompletion for specified shells.

## Scripts

### `install.sh`

The main entry point for the feature.

1.  **`install_deps`**: Ensures `curl` and `ca-certificates` are available via the system package manager.
2.  **`install_uv`**:
    - Downloads and runs the installer from `https://astral.sh/uv/install.sh`.
    - Supports installing a specific version or the latest version.
3.  **`init_autocompletion`**:
    - Detects installed shells (bash, zsh, fish, elvish).
    - Sets up autocompletion based on the `completion_shell` option.
