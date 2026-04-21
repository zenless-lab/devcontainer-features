# Codex CLI (codex)

Installs OpenAI Codex CLI.

## Feature Options

| Option | Description | Value Type | Default Value |
|---|---|---|---|
| codexVersion | Select the Codex version to install. | string | latest |

## Usage

```json
"features": {
    "ghcr.io/zenless-lab/devcontainer-features/codex:1": {
        "codexVersion": "latest"
    }
}
```

## Overview

- **Dependency**: Uses `dependsOn` to pull in `ghcr.io/devcontainers/features/node:1` and `ghcr.io/zenless-lab/devcontainer-features/pkg:2` (for `acl` and `sudo`).
- **Installation**: Installs `@openai/codex` globally with `npm install -g`.
- **Shared cache volume**: Mounts a named volume to `/opt/codex`.
- **Credential and config persistence**: Stores Codex auth (`auth.json`) and config (`config.toml`) files in the shared cache volume and symlinks them into `${HOME}/.codex`.
- **Runtime access control**: Runs a post-create ACL script to grant the current container user write access to the shared cache files.

## How It Works

During container build:

1. `/opt/codex` (shared volume) is created and made world-accessible.
2. `~/.codex` is created and owned by `_REMOTE_USER`.
3. `/opt/codex/auth.json` is initialized to `{}` if it does not already exist.
4. `/opt/codex/config.toml` is created if not present.
5. Symlinks are created from `~/.codex/auth.json` and `~/.codex/config.toml` to the shared volume files.
6. An ACL helper script is written to `/usr/local/share/acl-scripts/codex-acls.sh`.

After container creation (`postCreateCommand`):

- The ACL helper script grants the remote user read/write ACL permissions on the shared credential and config files.
