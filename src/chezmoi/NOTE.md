# chezmoi

Installs the official chezmoi binary into /usr/local/bin.

## Usage

```json
"features": {
    "ghcr.io/zenless-lab/devcontainer-features/chezmoi:1": {
        "config": "[merge]\nstats = true\n",
        "configFormat": "toml"
    }
}
```

## Feature Options

| Option        | Type    | Default | Description                                                                                                                |
|--------------|---------|---------|----------------------------------------------------------------------------------------------------------------------------|
| install      | boolean | true    | If true, installs the chezmoi binary.                                                                                      |
| config       | string  | ``      | Configuration content written to `~/.config/chezmoi/chezmoi.{configFormat}`. Merged with settings in your dotfiles repo.  |
| configFormat | string  | `toml`  | Format of the written configuration file. One of: `json`, `jsonc`, `toml`, `yaml`.                                        |

## Configuration File

When `config` is non-empty, the feature writes the provided string verbatim to
`~/.config/chezmoi/chezmoi.{configFormat}`. This file is read by chezmoi on every
invocation and is merged with any configuration declared inside your dotfiles
repository, letting you inject machine-specific or container-specific settings
without modifying the shared dotfiles source.
