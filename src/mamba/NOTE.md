# Mamba Dev Container Feature

This feature installs the Mamba package manager using Miniforge.

## Overview

- **Installation**: Downloads the Miniforge installer script.
- **User Scope**: Installs for the remote user (or root if not specified).
- **Initialization**: Configures shell integration for specified shells.

## Scripts

### `install.sh`

The main entry point for the feature.

1.  **`prepare_deps`**: Ensures `wget` is available.
2.  **`install_mamba`**: 
    - Determines the download URL based on the `version` option.
    - Runs the Miniforge installer in batch mode.
3.  **`init_shells`**:
    - Detects if the installed version supports the new `shell init` command (Miniforge >= 25.1.1-1).
    - Iterates through `init_shells` provided in options.
    - Executes initialization commands (`mamba init` or `mamba shell init -s`) for each shell as the target user.

## Configuration

- `version`: Specify the Miniforge version (default: `latest`).
- `init_shells`: Comma-separated list of shells to initialize (default: `bash`). Supported: `bash`, `zsh`, `fish`, `tcsh`, `xonsh`, `powershell`.
