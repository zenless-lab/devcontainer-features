# Gemini CLI (gemini-cli)

Installs Google Gemini CLI.

## Feature Options

| Option | Description | Value Type | Default Value |
|---|---|---|---|
| geminiCliVersion | Select the Gemini CLI version to install. | string | latest |

## Usage

```json
"features": {
    "ghcr.io/zenless-lab/devcontainer-features/gemini-cli:1": {
        "geminiCliVersion": "latest"
    }
}
```

## Overview

- **Installation**: Installs pnpm, uses pnpm to install Node.js, then installs `@google/gemini-cli`.
- **PATH**: Exports `PNPM_HOME` via `/etc/profile.d/pnpm.sh` so `pnpm`, `node`, and `gemini` are available in shells.
