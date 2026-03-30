# Tauri Dependencies (tauri)

Installs system dependencies required for Tauri v2 development.

## Feature Options

This feature has no options.

## Usage

```json
"features": {
    "ghcr.io/zenless-lab/devcontainer-features/tauri:1": {}
}
```

## Overview

- **Installation**: Uses `dependsOn` to pull in the repo's `pkg:2` feature for system libraries and the upstream `rust` and `node` features for toolchains.
- **Dependencies**: Installs packages like `webkit2gtk`, `openssl`, `curl`, `wget`, `file`, `libappindicator`, `librsvg`, and `xdg-utils`, then provides Rust and Node.js automatically.
