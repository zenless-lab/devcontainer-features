# Gemini CLI (gemini-cli)

Installs Google Gemini CLI.

## Feature Options

| Option | Description | Value Type | Default Value |
|---|---|---|---|
| geminiCliVersion | Select the Gemini CLI version to install. | string | latest |
| sandbox | Set the default `GEMINI_SANDBOX` value exported by the feature profile script. | string | false |
| geminiCliHome | Set `GEMINI_CLI_HOME` and pre-create its `.gemini` directory. Leave empty to avoid configuring `GEMINI_CLI_HOME`. | string |  |

## Usage

```json
"features": {
    "ghcr.io/zenless-lab/devcontainer-features/gemini-cli:2": {
        "geminiCliVersion": "latest",
        "sandbox": "docker",
        "geminiCliHome": "/gemini-cli"
    }
}
```

## Overview

- **Dependency**: Uses `dependsOn` to pull in `ghcr.io/devcontainers/features/node:1` instead of installing Node.js itself.
- **Installation**: Reuses the `pnpm` installed by the Node feature, then installs `@google/gemini-cli` globally with `pnpm add -g`.
- **PATH**: Configures `pnpm` global installs to place the Gemini CLI binary in `/usr/local/bin`, which is already on the default shell PATH.
- **Sandbox default**: Writes `/etc/profile.d/gemini-cli.sh` to export `GEMINI_SANDBOX=false` by default, or `docker` / `runsc` when configured.
- **Optional shared Gemini state**: Only writes `GEMINI_CLI_HOME` to `/etc/profile.d/gemini-cli.sh` when `geminiCliHome` is configured.

## Shared Credentials

Gemini CLI creates its `.gemini` directory under `GEMINI_CLI_HOME`. By default this feature does not set `GEMINI_CLI_HOME`, so Gemini CLI falls back to its own default location.

If you want multiple devcontainers on the same machine to reuse the same Gemini CLI credentials and local state, set `geminiCliHome` and mount a host directory to the same path.

Example:

```json
{
    "mounts": [
        "source=${localEnv:HOME}/.cache/devcontainer-gemini-cli,target=/gemini-cli,type=bind"
    ],
    "features": {
        "ghcr.io/zenless-lab/devcontainer-features/gemini-cli:2": {
            "geminiCliHome": "/gemini-cli"
        }
    }
}
```

With this mount, every devcontainer that uses the same host path will see the same `/gemini-cli/.gemini` directory.
