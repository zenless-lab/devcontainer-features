# TeX Live (tex-live)

Installs TeX Live, a comprehensive TeX system.

## Feature Options

| Option | Description | Value Type | Default Value |
|---|---|---|---|
| scheme | Select the TeX Live scheme to install. | string | full |
| paper | Select the default paper size. | string | a4 |
| doc_install | Install documentation. | boolean | true |
| src_install | Install source files. | boolean | true |
| repo_url | Custom CTAN repository URL. | string | automatic |

## Usage

```json
"features": {
    "ghcr.io/zenless-lab/devcontainer-features/tex-live:1": {
        "scheme": "full",
        "paper": "a4",
        "doc_install": true,
        "src_install": true
    }
}
```
