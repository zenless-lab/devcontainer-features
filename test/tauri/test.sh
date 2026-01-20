#!/bin/bash

set -e

source dev-container-features-test-lib

# install pnpm and rustup
wget -qO- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
wget -qO- https://get.pnpm.io/install.sh | ENV="$HOME/.bashrc" SHELL="$(which bash)" bash -
export PATH="$HOME/.local/share/pnpm:$PATH"
nvm install --lts
nvm use --lts

curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
export PATH="$HOME/.cargo/bin:$PATH"

echo "Creating Tauri App..."
pnpm create tauri-app test-tauri-app --template vanilla --manager pnpm --yes

cd test-tauri-app

echo "Installing dependencies..."
pnpm install

echo "Building Tauri App..."
pnpm tauri build

check "binary exists" ls src-tauri/target/release/test-tauri-app

reportResults
