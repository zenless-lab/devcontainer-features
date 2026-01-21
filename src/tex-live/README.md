
# TeX Live (tex-live)

Installs TeX Live, a comprehensive TeX system.

## Example Usage

```json
"features": {
    "ghcr.io/zenless-lab/devcontainer-features/tex-live:1": {}
}
```

## Options

| Options Id | Description | Type | Default Value |
|-----|-----|-----|-----|
| scheme | Select the TeX Live scheme to install. | string | medium |
| paper | Select the default paper size. | string | a4 |
| doc_install | Install documentation. | boolean | true |
| src_install | Install source files. | boolean | true |
| repo_url | Custom CTAN repository URL. | string | automatic |



---

_Note: This file was auto-generated from the [devcontainer-feature.json](https://github.com/zenless-lab/devcontainer-features/blob/main/src/tex-live/devcontainer-feature.json).  Add additional notes to a `NOTES.md`._
