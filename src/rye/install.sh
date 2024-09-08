#!/bin/bash
set -e

echo "Activating feature 'rye'"

# Default values for direct use in the script
VERSION=${VERSION:-""}

USE_UV=${USE_UV:-true}
USE_AUTO_COMPLETION=${USE_AUTO_COMPLETION:-true}
USE_GLOBAL_PYTHON=${USE_GLOBAL_PYTHON:-true}


# Install rye for the remote user
echo "Installing rye for user: $USER"
su - $_REMOTE_USER <<EOF
    set -e
    echo "Installing rye..."

    if [ -n "$(which python)" ] && [ "$USE_GLOBAL_PYTHON" = true ]; then
        echo "Using global python3($(which python3))"
        export RYE_TOOLCHAIN="$(which python3)"
    fi

    export RYE_INSTALL_OPTION="--yes"

    if [ "$VERSION" != "latest" ]; then
        echo "Installing rye version $VERSION"
        export RYE_VERSION=$VERSION
        export RYE_NO_AUTO_INSTALL=1
    fi

    curl -sSf https://rye.astral.sh/get | bash
    # echo source "$HOME/.rye/env" >> /etc/.bashrc
    source ~/.rye/env

    echo "Configuring rye..."

    if [ "$USE_AUTO_COMPLETION" = true ]; then
        echo "Installing auto-completion..."
        mkdir -p ~/.local/share/bash-completion/completions
        if [ command -v bash &> /dev/null ]; then
            rye self completion > ~/.local/share/bash-completion/completions/rye.bash
        fi
        if [ command -v fish &> /dev/null ]; then
            rye self completion -s fish > ~/.config/fish/completions/rye.fish
        fi
        if [ command -v zsh &> /dev/null ]; then
            rye self completion -s zsh > ~/.zfunc/_rye
        fi
        # rye self completion > ~/.local/share/bash-completion/completions/rye.bash
        # rye self completion -s fish > ~/.config/fish/completions/rye.fish
        # rye self completion -s zsh > ~/.zfunc/_rye
    fi

    if [ "$USE_UV" = true ]; then
        echo "use: uv"
        rye config --set-bool behavior.use-uv=true
    else
        echo "not use: uv"
        rye config --set-bool behavior.use-uv=false
    fi
EOF
