# uv (uv)

An extremely fast Python package installer and resolver, written in Rust.

## Feature Options

| Option | Description | Value Type | Default Value |
|---|---|---|---|
| version | Select the version of uv to install. | string | latest |
| completion_shell | Install autocompletion for a specific shell, or try to detect automatically. | string | automatic |

## Usage

```json
"features": {
    "ghcr.io/zenless-lab/devcontainer-features/uv:1": {
        "version": "latest",
        "completion_shell": "automatic"
    }
}
```

## Overview

- **Installation**: Downloads the official `uv` installer script.
- **Initialization**: Configures shell autocompletion for specified shells.
