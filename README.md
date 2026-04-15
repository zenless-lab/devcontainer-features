# Dev Container Features

This repository contains a collection of dev container Features.

## Available Features

| Feature | Id | Description |
|---|---|---|
| [chezmoi](src/chezmoi) | `chezmoi` | Installs chezmoi and optionally enables workspace development mode. |
| [Gemini CLI](src/gemini-cli) | `gemini-cli` | Installs Google Gemini CLI. |
| [HEASoft](src/heasoft) | `heasoft` | Installs HEASoft, the HEASARC high-energy astrophysics software suite. |
| [Mamba](src/mamba) | `mamba` | Installs Mamba, a fast, robust, and cross-platform package manager. |
| [Micromamba](src/micromamba) | `micromamba` | Installs Micromamba, a tiny, pure C++ executable package manager. |
| [OpenCode](src/opencode) | `opencode` | Installs OpenCode CLI. |
| [pre-commit Hook](src/pre-commit) | `pre-commit` | Installs pre-commit via uv and auto-runs pre-commit install in supported shells. |
| [System Packages](src/pkg) | `pkg` | Installs system packages on various Linux distributions. |
| [Tauri Dependencies](src/tauri) | `tauri` | Installs system dependencies required for Tauri v2 development. |
| [TeX Live](src/tex-live) | `tex-live` | Installs TeX Live, a comprehensive TeX system. |
| [uv](src/uv) | `uv` | An extremely fast Python package installer and resolver, written in Rust. |

## Usage

To use a feature, add it to the `features` object in your `devcontainer.json`.

```jsonc
{
    "image": "mcr.microsoft.com/devcontainers/base:ubuntu",
    "features": {
        "ghcr.io/zenless-lab/devcontainer-features/pkg:1": {
            "pkg": "git,curl"
        },
        "ghcr.io/zenless-lab/devcontainer-features/uv:1": {}
    }
}
```

## Distributing Features

### Versioning

Features are individually versioned by the `version` attribute in a Feature's `devcontainer-feature.json`.  Features are versioned according to the semver specification. More details can be found in [the dev container Feature specification](https://containers.dev/implementors/features/#versioning).

### Publishing

Features are hosted on GitHub Container Registry (GHCR).

This repo contains a **GitHub Action** [workflow](.github/workflows/release.yaml) that will publish each Feature to GHCR.

By default, each Feature will be prefixed with the `zenless-lab/devcontainer-features` namespace.  For example, the features in this repository can be referenced in a `devcontainer.json` with:

```
ghcr.io/zenless-lab/devcontainer-features/mamba:1
ghcr.io/zenless-lab/devcontainer-features/pkg:1
```

### Repo Structure

```
├── src
│   ├── gemini-cli
│   ├── heasoft
│   ├── mamba
│   ├── micromamba
│   ├── opencode
│   ├── pre-commit
│   ├── pkg
│   ├── tauri
│   ├── tex-live
│   ├── uv
...
```
