# Gemini CLI (gemini-cli)

Installs Google Gemini CLI.

## Feature Options

| Option | Description | Value Type | Default Value |
|---|---|---|---|
| geminiCliVersion | Select the Gemini CLI version to install. | string | latest |

## Usage

```json
"features": {
    "ghcr.io/zenless-lab/devcontainer-features/gemini-cli:2": {
        "geminiCliVersion": "latest"
    }
}
```

## Overview

- **Dependency**: Uses `dependsOn` to pull in `ghcr.io/devcontainers/features/node:1`.
- **Installation**: Installs `@google/gemini-cli` globally with `npm install -g`.
- **Shared cache volume**: Mounts a named volume to `/opt/gemini-cli`.
- **Credential and config persistence**: Stores Gemini credential/config files in the shared cache volume and symlinks them into `${HOME}/.gemini`.
- **Runtime access control**: Runs a post-create ACL script to grant the current container user write access to the shared cache files.

## Shared Credentials and Global Config

This feature now stores Gemini credential/config files in a shared cache volume:

- `/opt/gemini-cli/oauth_creds.json`
- `/opt/gemini-cli/google_accounts.json`
- `/opt/gemini-cli/settings.json`

When a devcontainer starts, the feature applies ACL entries for the current container user. This allows different containers to reuse the same login session and global Gemini CLI settings, similar to local-machine behavior.

## Intentionally Excluded from Shared Cache

The following data is intentionally not included in the shared cache:

- `projects.json`
- `GEMINI.md`
- `skills/`

Reasons:

- `projects.json` stores workspace absolute paths, which are not portable across different containers. Rebuilding this state is usually a one-time trust click.
- `GEMINI.md` and `skills/` can be modified by agents. Sharing them across projects may increase cross-project data leakage risk.
