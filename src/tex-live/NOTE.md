# TeX Live (tex-live)

Installs TeX Live, a comprehensive TeX system.

## Feature Options

| Option | Description | Value Type | Default Value |
|---|---|---|---|
| scheme | Select the TeX Live scheme to install. | string | medium |
| paper | Select the default paper size. | string | a4 |
| docInstall | Install documentation. | boolean | true |
| srcInstall | Install source files. | boolean | true |
| repoUrl | Custom CTAN repository URL. | string | automatic |

## Usage

```json
"features": {
    "ghcr.io/zenless-lab/devcontainer-features/tex-live:1": {
        "scheme": "full",
        "paper": "a4",
        "docInstall": true,
        "srcInstall": true
    }
}
```
