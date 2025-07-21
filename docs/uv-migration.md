# Migration from pyenv to uv

## Overview
This project has been migrated from pyenv to uv for Python version and dependency management. This provides better performance, reproducible environments, and simpler tooling.

## What Changed

### Before (pyenv + pip)
```bash
pyenv install 3.11.9
pyenv local 3.11.9
python -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
```

### After (uv only)
```bash
uv venv --python 3.12
uv sync --all-extras
```

## Installation & Setup

### 1. Install uv
```bash
# macOS/Linux
curl -LsSf https://astral.sh/uv/install.sh | sh

# Windows
powershell -c "irm https://astral.sh/uv/install.ps1 | iex"

# Or via pip
pip install uv
```

### 2. Initialize Project
```bash
# One-time setup
just setup

# Or manually
uv venv --python 3.12
uv sync --all-extras
```

## Key Benefits

### Performance
- **10-100x faster** dependency resolution
- **Parallel downloads** and installs
- **Intelligent caching**

### Reproducibility
- **Lock files** ensure exact versions
- **Cross-platform compatibility**
- **Deterministic builds**

### Simplicity
- **Single tool** for version + dependency management
- **No virtual environment activation** needed
- **Automatic Python installation** if needed

## Development Workflow

### Installing Dependencies
```bash
# Install dev dependencies
uv sync --all-extras

# Install specific groups
uv sync --group testing
uv sync --group lint
```

### Running Commands
```bash
# Use uv run (no activation needed)
uv run pytest
uv run mypy src/
uv run python -m mymodule

# Or activate environment
source .venv/bin/activate  # Linux/macOS
.venv\Scripts\activate     # Windows
```

### Adding Dependencies
```bash
# Add to pyproject.toml
uv add fastapi uvicorn
uv add --dev pytest mypy

# Remove dependencies
uv remove requests
```

## Migration Checklist

- [x] Updated `pyproject.toml` with comprehensive dependencies
- [x] Updated `justfile` to use Python 3.12
- [x] Updated `scripts/setup.py` to use uv instead of pyenv
- [x] Updated CI workflow to use uv
- [x] Removed `.python-version` file
- [x] Added migration documentation

## Next Steps

1. **Uninstall pyenv** (optional):
   ```bash
   # Remove pyenv installation
   rm -rf ~/.pyenv
   # Remove from shell profile (.bashrc, .zshrc, etc.)
   # Remove: export PATH="$HOME/.pyenv/bin:$PATH"
   # Remove: eval "$(pyenv init -)"
   ```

2. **Update team documentation** about the new workflow

3. **Update IDE configurations** to use `.venv/bin/python`

## Troubleshooting

### Common Issues
- **"uv not found"**: Install uv first (`pip install uv`)
- **"Python 3.12 not found"**: uv will install it automatically
- **"Virtual env not activated"**: Use `uv run` or manually activate

### IDE Setup
- **VS Code**: Select `.venv/bin/python` as interpreter
- **PyCharm**: Point to `.venv/bin/python` in project settings
