# Gemini CLI (gemini-cli)

Installs Google Gemini CLI.

## Feature Options

| Option | Description | Value Type | Default Value |
|---|---|---|---|
| geminiCliVersion | Select the Gemini CLI version to install. | string | latest |
| sandbox | Set the default `GEMINI_SANDBOX` value exported by the feature profile script. | string | false |

## Usage

```json
"features": {
    "ghcr.io/zenless-lab/devcontainer-features/gemini-cli:2": {
        "geminiCliVersion": "latest",
        "sandbox": "docker"
    }
}
```

## Overview

- **Dependency**: Uses `dependsOn` to pull in `ghcr.io/devcontainers/features/node:1` instead of installing Node.js itself.
- **Installation**: Reuses the `pnpm` installed by the Node feature, then installs `@google/gemini-cli` globally with `pnpm add -g`.
- **PATH**: Configures `pnpm` global installs to place the Gemini CLI binary in `/usr/local/bin`, which is already on the default shell PATH.
- **Sandbox default**: Writes `/etc/profile.d/gemini-cli.sh` to export `GEMINI_SANDBOX=false` by default, or `docker` / `runsc` when configured.
- **Shared Gemini state**: Writes `GEMINI_CLI_HOME=/gemini-cli` to `/etc/profile.d/gemini-cli.sh`, so Gemini CLI stores its user-level state in `/gemini-cli/.gemini`.

## Shared Credentials

Gemini CLI creates its `.gemini` directory under `GEMINI_CLI_HOME`. This feature fixes `GEMINI_CLI_HOME` to `/gemini-cli`, so the effective storage location becomes `/gemini-cli/.gemini`.

If you want multiple devcontainers on the same machine to reuse the same Gemini CLI credentials and local state, mount a host directory to `/gemini-cli`.

Example:

```json
{
    "mounts": [
        "source=${localEnv:HOME}/.cache/devcontainer-gemini-cli,target=/usr/local/share/gemini-cli,type=bind"
    ],
    "features": {
        "ghcr.io/zenless-lab/devcontainer-features/gemini-cli:2": {}
    }
}
```

With this mount, every devcontainer that uses the same host path will see the same `/usr/local/share/gemini-cli/.gemini` directory.
