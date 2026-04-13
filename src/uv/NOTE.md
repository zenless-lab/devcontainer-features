# uv (uv)

An extremely fast Python package installer and resolver, written in Rust.

## Feature Options

| Option | Description | Value Type | Default Value |
|---|---|---|---|
| version | Select the version of uv to install. | string | latest |
| completionShell | Install autocompletion for a specific shell, or try to detect automatically. | string | automatic |

## Usage

```json
"features": {
    "ghcr.io/zenless-lab/devcontainer-features/uv:1": {
        "version": "latest",
        "completionShell": "automatic"
    }
}
```

## Overview

- **Installation**: Downloads the official `uv` installer script.
- **Initialization**: Configures shell autocompletion for specified shells.

## Notes

This feature installs `uv` only. It does not install Python automatically.

If your project pins a Python version, install it explicitly after container creation, for example with `uv python install 3.11`.

Python interpreters, uv cache, and the default project virtual environment (`UV_PROJECT_ENVIRONMENT=/opt/uv/venv`) are persisted under `/opt/uv` via a feature volume mount. This helps avoid repeated downloads across container rebuilds and restarts.

Because project environments are created at `/opt/uv/venv` by default, project tooling should reference that environment path when selecting an interpreter.
