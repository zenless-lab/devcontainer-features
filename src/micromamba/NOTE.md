# Micromamba (micromamba)

Installs Micromamba, a tiny, pure C++ executable package manager. It is a statically linked version of Mamba.

## Feature Options

| Option | Description | Value Type | Default Value |
|---|---|---|---|
| version | Select the version of Micromamba to install. | string | latest |
| initShells | Select the shell(s) to initialize, separated by commas. | string | bash |

## Usage

```json
"features": {
    "ghcr.io/zenless-lab/devcontainer-features/micromamba:1": {
        "version": "latest",
        "initShells": "bash"
    }
}
```

## Overview

- **Installation**: Downloads the Micromamba binary directly from `micro.mamba.pm`.
- **System Requirements**: Automatically installs dependencies (`curl`, `bzip2`, `ca-certificates`, `tar`) if missing.
- **Initialization**: Configures shell integration for specified shells.
