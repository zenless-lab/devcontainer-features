
# chezmoi (chezmoi)

Installs chezmoi and optionally enables workspace development mode.

## Example Usage

```json
"features": {
    "ghcr.io/zenless-lab/devcontainer-features/chezmoi:1": {}
}
```

## Options

| Options Id | Description | Type | Default Value |
|-----|-----|-----|-----|
| devMode | If true, writes a chezmoi config file so chezmoi uses the current working directory as the source directory. | boolean | false |



---

_Note: This file was auto-generated from the [devcontainer-feature.json](https://github.com/zenless-lab/devcontainer-features/blob/main/src/chezmoi/devcontainer-feature.json).  Add additional notes to a `NOTES.md`._
