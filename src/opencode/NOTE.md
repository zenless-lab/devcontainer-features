# OpenCode (opencode)

Installs OpenCode CLI.

## Feature Options

| Option | Description | Value Type | Default Value |
|---|---|---|---|
| opencode_version | Select the version to install. | string | latest |
| shell_init | Initialize shell completions for the specified shell(s). Comma-separated list of shells or 'automatic' to detect the current shell. | string | automatic |

## Usage

```json
"features": {
    "ghcr.io/zenless-lab/devcontainer-features/opencode:1": {
        "opencode_version": "latest",
        "shell_init": "automatic"
    }
}
```

## Overview

- **Installation**: Helper feature to install OpenCode CLI from opencode.ai.
- **Dependencies**: Installs `sudo`, `curl`, `ca-certificates`.
- **Initialization**: Configures shell completions if requested.
