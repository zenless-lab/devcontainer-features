
# ZSH Common (zsh-common)

Installs and configures zsh with common plugins.

## Example Usage

```json
"features": {
    "ghcr.io/zenless-lab/devcontainer-features/zsh-common:0": {}
}
```

## Options

| Options Id | Description | Type | Default Value |
|-----|-----|-----|-----|
| set_default | Set zsh as the default shell | boolean | false |
| install_powerlevel10k | Install and configure Powerlevel10k prompt | boolean | false |
| install | Comma-separated list of plugins to install | string | - |
| skip | Comma-separated list of plugins to skip | string | - |
| accept_suggest_key | Accept the suggestion to bind the suggestion key | string | ^  |



---

_Note: This file was auto-generated from the [devcontainer-feature.json](https://github.com/zenless-lab/devcontainer-features/blob/main/src/zsh-common/devcontainer-feature.json).  Add additional notes to a `NOTES.md`._
