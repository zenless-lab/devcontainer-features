#!/bin/bash
set -e

remote_user_home=$(eval echo ~$_REMOTE_USER)
sh -c "$(curl -fsSL https://starship.rs/install.sh)" "" --yes

# Setup starship config
# Bash
if command -v bash &> /dev/null; then
    echo "Found bash, setting up starship..."
    echo 'eval "$(starship init bash)"' >> $remote_user_home/.bashrc
fi
# Fish
if command -v fish &> /dev/null; then
    echo 'Found fish, setting up starship...'
    echo 'starship init fish | source' >> $remote_user_home/.config/fish/config.fish
fi
# Zsh
if command -v zsh &> /dev/null; then
    echo 'Found zsh, setting up starship...'
    echo 'eval "$(starship init zsh)"' >> $remote_user_home/.zshrc
fi
