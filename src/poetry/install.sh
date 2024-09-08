#!/bin/bash
set -e

echo "Activating feature 'poetry'"

# Default values for direct use in the script
VERSION=${VERSION:-"latest"}

REMOTE_USER_HOME=$(eval echo ~$_REMOTE_USER)

# Install pipx if not already installed
su - $_REMOTE_USER <<EOF
    if command -v pipx &> /dev/null; then
        echo "pipx is already installed."
    else
        echo "Installing pipx..."
        python3 -m pip install --user pipx
        python3 -m pipx ensurepath
    fi
EOF

# Install Poetry using pipx
if [ "$VERSION" = "latest" ]; then
    echo "Installing the latest version of Poetry..."
    echo "User: $_REMOTE_USER"
    su - $_REMOTE_USER -c "pipx install poetry" 
else
    echo "Installing Poetry version $VERSION..."
    su - $_REMOTE_USER -c "pipx install poetry==$VERSION"
fi

echo "Poetry installation completed."