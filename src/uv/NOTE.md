# uv (uv)

An extremely fast Python package installer and resolver, written in Rust.

## Feature Options

| Option | Description | Value Type | Default Value |
|---|---|---|---|
| version | Select the version of uv to install. | string | latest |
| pythonVersion | Install Python versions using 'uv python install'. Comma-separated values; use 'automatic' to install the default Python with no arguments. | string | automatic |
| completionShell | Install autocompletion for a specific shell, or try to detect automatically. | string | automatic |

## Usage

```json
"features": {
    "ghcr.io/zenless-lab/devcontainer-features/uv:1": {
        "version": "latest",
        "pythonVersion": "automatic",
        "completionShell": "automatic"
    }
}
```

## Overview

- **Installation**: Downloads the official `uv` installer script.
- **Initialization**: Configures shell autocompletion for specified shells.

## Notes

`uv` installs Python interpreters outside the workspace and links them into the project `.venv` via symlinks. If you only install `uv`, those symlinks can break after each devcontainer restart. The next `uv sync` then sees a missing interpreter, deletes `.venv`, and recreates it. For ML projects with heavy dependencies like `pytorch`, that means long, repeated downloads/compiles.

Therefore, this feature installs a Python version during creation, and it should match the Python version pinned by your project. On restart, `uv` can reuse and relink the existing interpreter instead of deleting `.venv` and re-downloading dependencies.
