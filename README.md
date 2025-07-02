# AI-Native Monorepo Starter Kit

## 🚀 Overview

This repository provides a robust, pre-configured Nx monorepo designed for building **AI-native applications** with a polyglot stack. It's tailored for individual developers or small teams seeking high productivity, automation, and a "batteries-included" experience without the usual configuration headaches.

We've integrated a modern Python toolchain (`uv`, `ruff`, `mypy`, `pytest`, `pyenv`) and orchestrated it seamlessly with Nx for a streamlined developer workflow, automated CI/CD, and simplified microservices transformation. This setup minimizes "fuss" so you can focus on building your core AI products.

-----

## ✨ Features

  * **Nx Monorepo:** Centralized codebase for React frontends, Python backends, and infrastructure-as-code.
  * **Python Toolchain:**
      * **`uv`**: Blazing-fast dependency management and virtual environment orchestration.
      * **`ruff`**: High-performance Python linter and formatter.
      * **`mypy`** (or Pyre): Strict static type checking for Python.
      * **`pytest`**: Robust testing framework with coverage.
      * **`pyenv`**: Seamless Python version management.
  * **Automated Setup:** A single `make setup` command handles environment bootstrapping, Nx plugin generation, and pre-commit hook installation.
  * **Simplified Project Generation:** Use `make app` and `make lib` for instantly configured Python applications and libraries.
  * **Intelligent Task Execution:** Leverages Nx's affected commands for fast, incremental linting, testing, and building across your monorepo.
  * **Pre-commit Hooks:** Enforces code quality locally before commits, preventing CI failures.
  * **CI/CD Ready:** Designed for straightforward integration with platforms like GitHub Actions.
  * **IaC Integration:** High-level `make` commands for orchestrating Terraform, Pulumi, and Ansible within the monorepo.
  * **Microservice Transformation:** Simplified `make containerize` command to build Docker images for any application.

-----

## 🛠️ Prerequisites

Before you clone and conquer, ensure you have these essentials installed:

  * **Git:** Version control is fundamental.
  * **Node.js & pnpm:** Node.js LTS (e.g., v20) and `pnpm` (install via `npm install -g pnpm`).
  * **Pyenv:** Follow the official installation guide: [https://github.com/pyenv/pyenv\#installation](https://www.google.com/search?q=https://github.com/pyenv/pyenv%23installation). **Crucially, add `pyenv` initialization to your shell's config (`.bashrc`, `.zshrc`, etc.) and restart your terminal.**
  * **GNU Make:** Usually pre-installed on Linux/macOS. For Windows, consider WSL or Chocolatey to install.

-----

## 🚀 Getting Started

Follow these steps to get your AI-Native Monorepo up and running:

1.  **Clone the Repository:**

    ```bash
    git clone https://github.com/your-username/your-ai-monorepo-starter.git # Replace with your repo URL
    cd your-ai-monorepo-starter
    ```

2.  **Run the One-Time Setup:**
    This `make` command automates everything: Nx initialization, Python environment setup (pyenv, uv), custom Nx generator creation, and pre-commit hook installation.

    ```bash
    make setup
    ```

      * *Initial run might take a few minutes as it downloads dependencies and sets up environments.*
      * *If `uv` installation via `pip` fails, you might need to install Rust toolchain first and set `RUST_TOOLCHAIN_UV_INSTALL ?= true` in the Makefile, then retry `make setup`.*

-----

## ⚡ Daily Workflow

Here's how to interact with your monorepo for daily development:

### 🆕 Project Generation

  * **New Python Application:**

    ```bash
    make app NAME=my-fastapi-service
    ```

    *This command automatically generates the app, configures it with `ruff`, `mypy`, `pytest`, and installs its initial dependencies using `uv`.*

  * **New Python Library:**

    ```bash
    make lib NAME=my-shared-data-models
    ```

    *This command works similarly for Python libraries.*

### 🏃 Running Tasks

  * **Lint all affected projects:**

    ```bash
    make lint
    ```

  * **Type-check all affected projects:**

    ```bash
    make typecheck
    ```

  * **Run tests for all affected projects:**

    ```bash
    make test
    ```

  * **Build all affected projects (JS/TS apps/libs):**

    ```bash
    make build
    ```

  * **Serve a specific application (e.g., React frontend or Python API):**

    ```bash
    make serve PROJECT=my-react-app
    make serve PROJECT=my-fastapi-service
    ```

  * **Visualize the Nx dependency graph:**

    ```bash
    make graph
    ```

### 🌍 Infrastructure-as-Code (IaC)

  * **Run a plan for an IaC target (e.g., Terraform VPC stack):**

    ```bash
    make infra-plan TARGET=vpc
    ```

    *Requires an Nx project named `infrastructure` with a `plan-<TARGET>` task.*

  * **Apply changes for an IaC target (e.g., Kubernetes cluster):**

    ```bash
    make infra-apply TARGET=kubernetes-cluster
    ```

    *Requires an Nx project named `infrastructure` with an `apply-<TARGET>` task.*

  * **Run an Ansible playbook:**

    ```bash
    make ansible-run PLAYBOOK=deploy-edge-nodes HOSTS=production-cluster
    ```

    *Requires an Nx project named `ansible-playbooks` with a `run-<PLAYBOOK>` task.*

### 📦 Containerization (Microservices)

  * **Build a Docker image for any application:**
    ```bash
    make containerize PROJECT=my-fastapi-service
    ```
    *Requires a `Dockerfile` in the project's root and a `container` target in its `project.json`.*

-----

## 🧹 Cleanup

  * **Clean build artifacts and caches:**
    ```bash
    make clean
    ```
    *Use with caution\! This removes `node_modules`, `.venv`, and Nx caches. You'll need to run `make setup` again to restore the environment.*

-----

## ⚙️ Customization & Advanced Usage

  * **`Makefile` Variables:** Adjust `PYTHON_VERSION`, `NX_PYTHON_PLUGIN_VERSION`, and `RUST_TOOLCHAIN_UV_INSTALL` directly in the `Makefile` if needed.
  * **Custom Nx Generators:** The `libs/shared-python-tools` plugin contains the `generator.ts` files that define how new Python projects are structured and configured. Feel free to modify them to fit specific architectural patterns or add new default dependencies/tools.
  * **`pyproject.toml`:** For project-specific Python dependencies, edit the `pyproject.toml` inside your individual `apps/<project-name>` or `libs/<project-name>` directories, then run `pnpm nx run <project-name>:install-deps` (or use `make app`/`make lib` for new projects which does it automatically).
  * **`project.json`:** Each Nx project (including your Python and IaC ones) has a `project.json`. This is where specific tasks (like `container`, `infra-plan`, `infra-apply`) are defined using `nx:run-commands`. You'll customize these as you build out your IaC and microservice projects.

-----

## 🤝 Contributing

This is designed as a personal starter kit, but feedback or suggestions for improvements are always welcome\!

-----
