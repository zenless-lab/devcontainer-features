# chezmoi

Installs the official chezmoi binary into /usr/local/bin.

## Usage

```json
"features": {
    "ghcr.io/zenless-lab/devcontainer-features/chezmoi:1": {
        "devMode": true
    }
}
```

## Development Mode

When `devMode` is `true`, the feature creates `/etc/profile.d/chezmoi-dev-mode.sh` with:

```sh
alias chezmoi='chezmoi --source .'
```

Use this mode when your workspace itself is the chezmoi source repository. The alias makes commands like `chezmoi add ~/.bashrc` write generated source files such as `dot_bashrc` into the current working directory.
