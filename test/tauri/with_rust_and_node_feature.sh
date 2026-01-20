#!/bin/bash

set -e

source dev-container-features-test-lib

echo "Creating Tauri App..."
pnpm create tauri-app test-tauri-app --template vanilla --manager pnpm --yes

cd test-tauri-app

echo "Installing dependencies..."
pnpm install

echo "Building Tauri App..."
pnpm tauri build

check "binary exists" ls src-tauri/target/release/test-tauri-app

reportResults
