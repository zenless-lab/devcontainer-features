# pre-commit Hook (pre-commit)

Installs `pre-commit` by depending on the `uv` feature and runs `pre-commit install` during content update.

## Feature Options

This feature has no options.

## Usage

```json
"features": {
    "ghcr.io/zenless-lab/devcontainer-features/pre-commit:0": {}
}
```

## Overview

- **Dependency**: Uses `dependsOn` to install `ghcr.io/zenless-lab/devcontainer-features/uv:1` with `toolsToInstall=pre-commit`.
- **Behavior**: Uses `updateContentCommand` to run `pre-commit install --allow-missing-config` directly in the workspace.

## Notes

The hook file is expected at `.git/hooks/pre-commit` after container creation.
