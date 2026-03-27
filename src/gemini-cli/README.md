
# Gemini CLI (gemini-cli)

Installs Google Gemini CLI.

## Example Usage

```json
"features": {
    "ghcr.io/zenless-lab/devcontainer-features/gemini-cli:2": {}
}
```

## Options

| Options Id | Description | Type | Default Value |
|-----|-----|-----|-----|
| geminiCliVersion | Select the Gemini CLI version to install. | string | latest |
| sandbox | Set the default GEMINI_SANDBOX value exported by the feature profile script. | string | false |
| geminiCliHome | Set GEMINI_CLI_HOME and pre-create its .gemini directory. Leave empty to avoid configuring GEMINI_CLI_HOME. | string | - |



---

_Note: This file was auto-generated from the [devcontainer-feature.json](https://github.com/zenless-lab/devcontainer-features/blob/main/src/gemini-cli/devcontainer-feature.json).  Add additional notes to a `NOTES.md`._
