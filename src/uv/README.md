
# uv (uv)

An extremely fast Python package installer and resolver, written in Rust.

## Example Usage

```json
"features": {
    "ghcr.io/zenless-lab/devcontainer-features/uv:1": {}
}
```

## Options

| Options Id | Description | Type | Default Value |
|-----|-----|-----|-----|
| version | Select the version of uv to install. | string | latest |
| completionShell | Install autocompletion for a specific shell, or try to detect automatically. | string | automatic |
| toolsToInstall | Comma-separated list of CLI tools to install with uv tool install. Set to empty string to skip tool installation. | string | ruff,pytest,ty,black,pyright,pre-commit,rust-just |

## Customizations

### VS Code Extensions

- `ms-python.python`
- `tamasfe.even-better-toml`



---

_Note: This file was auto-generated from the [devcontainer-feature.json](https://github.com/zenless-lab/devcontainer-features/blob/main/src/uv/devcontainer-feature.json).  Add additional notes to a `NOTES.md`._
