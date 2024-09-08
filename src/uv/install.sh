#!/bin/bash
set -e

echo "Activating feature 'uv'"

# Default values for direct use in the script
USE_AUTO_COMPLETION=${USE_AUTO_COMPLETION:-true}

REMOTE_USER_HOME=$(eval echo ~$_REMOTE_USER)


# Install uv for the remote user
echo "Installing uv for user: $USER"
su - $_REMOTE_USER <<EOF
    set -e
    echo "Installing uv..."

    curl -LsSf https://astral.sh/uv/install.sh | sh

    source $REMOTE_USER_HOME/.cargo/env

    if [ "$USE_AUTO_COMPLETION" = true ]; then
        echo "Configuring auto-completion..."
        if [ command -v bash &> /dev/null ]; then
            echo 'eval "\$(uv generate-shell-completion bash)"' >> $REMOTE_USER_HOME/.bashrc
        fi

        if [ command -v fish &> /dev/null ]; then
            echo 'eval "\$(uv generate-shell-completion zsh)"' >> $REMOTE_USER_HOME/.zshrc
        fi
        if [ command -v zsh &> /dev/null ]; then
            echo 'uv generate-shell-completion fish | source' >> $REMOTE_USER_HOME/.config/fish/config.fish
        fi
    fi
EOF
