#!/bin/bash

# Helper script for Makefile setup targets to ensure cross-platform compatibility.

# Exit immediately if a command exits with a non-zero status.
set -e

# Function to initialize Nx workspace
init_nx() {
    echo "🏗️ Initializing Nx workspace with pnpm..."
    if [ ! -f "pnpm-lock.yaml" ]; then
        npx create-nx-workspace@latest . --no-nx-cloud --preset=react-standalone --pm=pnpm
        pnpm add -D @nxlv/python@$NX_PYTHON_PLUGIN_VERSION
    else
        echo "Nx workspace already initialized. Skipping."
    fi
    echo "✅ Nx workspace ready."
}

# Function to set up Python environment
init_python_env() {
    echo "🐍 Setting up Python environment with pyenv and uv..."
    if ! command -v pyenv &> /dev/null; then
        echo "pyenv not found. Please install pyenv first: https://github.com/pyenv/pyenv#installation"
        exit 1
    fi
    pyenv install $PYTHON_VERSION || true # Install if not present
    pyenv local $PYTHON_VERSION # Set local Python version
    eval "$(pyenv init -)" # Re-initialize pyenv in current shell
    echo "Checking for uv installation..."
    if ! command -v uv &> /dev/null; then
        if [ "$RUST_TOOLCHAIN_UV_INSTALL" = "true" ]; then
            echo "Installing uv via cargo (Rust toolchain required)..."
            cargo install uv
        else
            echo "Installing uv via pip..."
            pip install uv
        fi
    else
        echo "uv already installed. Skipping."
    fi
    echo "Creating/updating root pyproject.toml..."
    if [ ! -f "$ROOT_PYPROJECT_TOML" ]; then
        echo "[project]" > "$ROOT_PYPROJECT_TOML"
        echo "name = \"monorepo-dev-env\"" >> "$ROOT_PYPROJECT_TOML"
        echo "version = \"0.0.1\"" >> "$ROOT_PYPROJECT_TOML"
        echo "" >> "$ROOT_PYPROJECT_TOML"
        echo "[project.optional-dependencies]" >> "$ROOT_PYPROJECT_TOML"
        echo "dev = [" >> "$ROOT_PYPROJECT_TOML"
        echo "    \"ruff\",