# uv (uv)

An extremely fast Python package installer and resolver, written in Rust.

## Feature Options

| Option | Description | Value Type | Default Value |
|---|---|---|---|
| version | Select the version of uv to install. | string | latest |
| completionShell | Install autocompletion for a specific shell, or try to detect automatically. | string | automatic |
| toolsToInstall | Comma-separated list of CLI tools to install with `uv tool install`. Set to empty string to skip tool installation. | string | ruff,pytest,ty,black,pyright,pyrefly,pre-commit,rust-just |

## Usage

```json
"features": {
    "ghcr.io/zenless-lab/devcontainer-features/uv:1": {
        "version": "latest",
        "completionShell": "automatic",
        "toolsToInstall": "ruff,pytest,ty,black,pyright,pyrefly,pre-commit,rust-just"
    }
}
```

## Overview

- **Installation**: Downloads the official `uv` installer script.
- **Tooling**: Installs selected Python CLI tools with `uv tool install`.
- **Initialization**: Configures shell autocompletion for specified shells.

## Notes

This feature installs `uv` and, by default, a curated set of Python CLI tools using `uv tool install`. It does not install Python automatically.

To skip tool installation, set `toolsToInstall` to an empty string. For example:

```json
"features": {
    "ghcr.io/zenless-lab/devcontainer-features/uv:1": {
        "toolsToInstall": ""
    }
}
```

If your project pins a Python version, install it explicitly after container creation, for example with `uv python install 3.11`.

Python interpreters, uv cache, and the default project virtual environment (`UV_PROJECT_ENVIRONMENT=/opt/uv/venv`) are persisted under `/opt/uv` via a feature volume mount. This helps avoid repeated downloads across container rebuilds and restarts.

Because project environments are created at `/opt/uv/venv` by default, project tooling should reference that environment path when selecting an interpreter.
