# Mamba (mamba)

Installs Mamba, a fast, robust, and cross-platform package manager. It is a reimplementation of the conda package manager in C++.

## Feature Options

| Option | Description | Value Type | Default Value |
|---|---|---|---|
| version | Select the version of Mamba to install. | string | latest |
| init_shells | Select the shell(s) to initialize, separated by commas. | string | bash |

## Usage

```json
"features": {
    "ghcr.io/zenless-lab/devcontainer-features/mamba:1": {
        "version": "latest",
        "init_shells": "bash"
    }
}
```

## Overview

- **Installation**: Downloads the Miniforge installer script.
- **User Scope**: Installs for the remote user (or root if not specified).
- **Initialization**: Configures shell integration for specified shells.
