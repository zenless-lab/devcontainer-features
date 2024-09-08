#!/bin/bash

set -e

VERSION=${VERSION:-"latest"}
USE_AUTO_ACTIVATION=${USE_AUTO_ACTIVATION:-false}
USE_PYPY=${USE_PYPY:-false}
ALLOW_UPDATE=${ALLOW_UPDATE:-true}

if [ command -v fish &> /dev/null ]; then
    INIT_ZSH=${INIT_ZSH:-false}
else
    INIT_ZSH=${INIT_ZSH:-true}
fi


if $USE_PYPY; then
    script_name=Miniforge-pypy3-$(uname)-$(uname -m).sh
else
    script_name=Miniforge3-$(uname)-$(uname -m).sh
fi

if [ "$VERSION" = "latest" ]; then
    url="https://github.com/conda-forge/miniforge/releases/latest/download/${script_name}"
else
    url="https://github.com/conda-forge/miniforge/releases/download/${VERSION}/${script_name}"
fi

echo "Installing Miniforge3 for user: $USER"
su - $_REMOTE_USER <<EOF
    set -e

    echo "Installing Miniforge3... ($url)"
    curl -L -O $url

    if $ALLOW_UPDATE; then
        echo "Updating conda..."
        bash $script_name -b -u
    else
        echo "Installing conda..."
        bash $script_name -b
    fi

    source ~/miniforge3/bin/activate
    python -m conda init
    if [ -f "$PREFIX/bin/mamba" ]; then
        python -m mamba.mamba init
    fi

    if $INIT_ZSH; then
        echo "Initializing zsh..."
        python -m conda init zsh
        if [ -f "$PREFIX/bin/mamba" ]; then
            python -m mamba.mamba init zsh
        fi
    fi
    
    conda config --set auto_activate_base $USE_AUTO_ACTIVATION

    rm $script_name
EOF
