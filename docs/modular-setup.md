# Modular Setup Guide

## Overview

The AI-Native Monorepo now supports modular installation, allowing you to install only what you need when you need it. This keeps installations lightweight and fast.

## Quick Start

### 1. Core Setup (Lightweight)

```bash
# Install only essentials (ruff, mypy, pytest, pre-commit)
just setup
```

**Includes:**

- Essential development tools (ruff, mypy, pre-commit)
- Basic testing (pytest, pytest-cov)
- Utilities (python-dotenv, uv)

### 2. Component Installation

```bash
# Add AI/ML capabilities
just setup-ai

# Add cloud tools
just setup-cloud

# Add analytics tools
just setup-analytics

# Add extended dev tools
just setup-dev

# Add database support
just setup-database

# Add web/API support
just setup-web

# Add Supabase integration
just setup-supabase
```

### 3. Full Installation

```bash
# Install everything at once
just setup-full
```

## Available Components

### 🤖 AI/ML (`just setup-ai`)

- **PyTorch** - Deep learning framework
- **Transformers** - Hugging Face transformers
- **Scikit-learn** - Machine learning library
- **Datasets** - Data loading and processing
- **Accelerate** - Distributed training
- **MLflow** - ML lifecycle management
- **Wandb** - Experiment tracking

### ☁️ Cloud (`just setup-cloud`)

- **Docker** - Containerization
- **Kubernetes** - Container orchestration
- **Ansible** - Infrastructure automation
- **Boto3** - AWS SDK
- **Google Cloud** - GCP SDK
- **Azure** - Azure SDK
- **Pulumi** - Infrastructure as code

### 📊 Analytics (`just setup-analytics`)

- **Pandas** - Data manipulation
- **NumPy** - Numerical computing
- **Matplotlib/Seaborn** - Data visualization
- **Plotly** - Interactive visualizations
- **Jupyter** - Interactive notebooks
- **SciPy** - Scientific computing
- **Polars** - Fast DataFrames

### 🛠️ Development (`just setup-dev`)

- **Extended testing** (pytest-mock, pytest-xdist, hypothesis)
- **Security tools** (bandit, safety)
- **Coverage reporting** (coverage)
- **CLI tools** (typer, rich)

### 🗄️ Database (`just setup-database`)

- **PostgreSQL** (psycopg2-binary, SQLModel)
- **Redis** - In-memory database
- **MongoDB** (pymongo)
- **Alembic** - Database migrations

### 🌐 Web/API (`just setup-web`)

- **FastAPI** - Modern web framework
- **Uvicorn** - ASGI server
- **Pydantic** - Data validation
- **HTTPX** - HTTP client
- **Jinja2** - Template engine

## Usage Examples

### Scenario 1: Web API Development

```bash
# Start with core
just setup

# Add web framework
just setup-web

# Add database support
just setup-database

# Optional: Add development tools
just setup-dev
```

### Scenario 2: Machine Learning Project

```bash
# Start with core
just setup

# Add AI/ML tools
just setup-ai

# Add analytics for data processing
just setup-analytics

# Optional: Add cloud tools for deployment
just setup-cloud
```

### Scenario 3: Full-Stack Development

```bash
# Install everything
just setup-full
```

## Environment Management

### Clean Installation

```bash
# Clean environment and reinstall core
just reinstall

# Clean environment and reinstall everything
just reinstall-full

# Just clean the environment
just clean-env
```

### Adding Components Later

You can always add more components to an existing installation:

```bash
# Already have core setup, now add AI tools
just setup-ai

# Add cloud tools later
just setup-cloud
```

## Benefits

### 🚀 **Speed**

- Core setup takes seconds instead of minutes
- Only install what you need

### 💾 **Disk Space**

- AI/ML packages can be 2-3GB
- Core installation is < 100MB

### 🔧 **Flexibility**

- Start minimal, grow as needed
- Different team members can have different setups

### 🎯 **Purpose-Built**

- Backend developers: `setup + setup-web + setup-database`
- ML engineers: `setup + setup-ai + setup-analytics`
- DevOps: `setup + setup-cloud + setup-dev`

## Migration from Old Setup

If you have an existing installation:

```bash
# Clean and start fresh
just clean-env
just setup

# Add what you need
just setup-ai      # If doing ML work
just setup-web     # If building APIs
just setup-cloud   # If deploying to cloud
```

## Help

```bash
# Show all setup options
just help-setup

# Show all available commands
just help
```
