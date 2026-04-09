
# chezmoi (chezmoi)

Installs chezmoi and optionally writes a configuration file.

## Example Usage

```json
"features": {
    "ghcr.io/zenless-lab/devcontainer-features/chezmoi:1": {}
}
```

## Options

| Options Id | Description | Type | Default Value |
|-----|-----|-----|-----|
| install | If true, installs the chezmoi binary. | boolean | true |
| config | Configuration content to write to ~/.config/chezmoi/chezmoi.{configFormat}. When non-empty, the file is created so it can be merged with settings defined in your dotfiles repository. | string | - |
| configFormat | Format of the configuration file written when 'config' is non-empty. One of: json, jsonc, toml, yaml. | string | toml |



---

_Note: This file was auto-generated from the [devcontainer-feature.json](https://github.com/zenless-lab/devcontainer-features/blob/main/src/chezmoi/devcontainer-feature.json).  Add additional notes to a `NOTES.md`._
