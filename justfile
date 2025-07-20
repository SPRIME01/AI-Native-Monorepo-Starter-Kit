# ╔═══════════════════════════════════════════════════════════════╗
# ║                AI-Native Monorepo Orchestration               ║
# ║  Hexagonal/DDD Nx workspace with Python, ML, and Cloud       ║
# ║  Built bububuilbuild-build-services: # Build all deployable services
    @echo "🐳 Building deployable services..."
    @python3 -c "import subprocess, os; services = [d.name for d in os.scandir('apps') if d.is_dir() and d.name.endswith('-svc')]; subprocess.run(['npx', 'nx', 'run-many', '--target=build', '--projects=tag:deployable:true', '--parallel=3']) if services else print('ℹ️  No deployable services found. Use \\'just service-split CTX=<name>\\' to create some.')": # Build all deployable services
    @echo "🐳 Building deployable services..."
    @python3 -c "import subprocess, os; services = [d.name for d in os.scandir('apps') if d.is_dir() and d.name.endswith('-svc')]; subprocess.run(['npx', 'nx', 'run-many', '--target=build', '--projects=tag:deployable:true', '--parallel=3']) if services else print('ℹ️  No deployable services found. Use \\'just service-split CTX=<name>\\' to create some.')"

lint: # Lint all affected projects
    @echo "🔎 Linting affected projects..."
    {{NX}} affected --target=lint --base=main --parallel=3n3 -c "import subprocess, os; services = [d.name for d in os.scandir('apps') if d.is_dir() and d.name.endswith('-svc')]; subprocess.run(['npx', 'nx', 'run-many', '--target=build', '--projects=tag:deployable:true', '--parallel=3']) if services else print('ℹ️  No deployable services found. Use \\'just service-split CTX=<name>\\' to create some.')"es: # Build all deployable services
    @echo "🐳 Building deployable services..."
    @python3 -c "import subprocess, os; services = [d.name for d in os.scandir('apps') if d.is_dir() and d.name.endswith('-svc')]; subprocess.run(['npx', 'nx', 'run-many', '--target=build', '--projects=tag:deployable:true', '--parallel=3']) if services else print('ℹ️  No deployable services found. Use \\'just service-split CTX=<name>\\' to create some.')"

lint: # Lint all affected projectses: # Build all deployable services
    @echo "🐳 Building deployable services..."
    @python3 -c "import subprocess, os; services = [d.name for d in os.scandir('apps') if d.is_dir() and d.name.endswith('-svc')]; subprocess.run(['npx', 'nx', 'run-many', '--target=build', '--projects=tag:deployable:true', '--parallel=3']) if services else print('ℹ️  No deployable services found. Use \\'just service-split CTX=<name>\\' to create some.')"ices: # Build all deployable services
    @echo "🐳 Building deployable services..."
    @python3 -c "import subprocess, os; services = [d.name for d in os.scandir('apps') if d.is_dir() and d.name.endswith('-svc')]; subprocess.run(['npx', 'nx', 'run-many', '--target=build', '--projects=tag:deployable:true', '--parallel=3']) if services else print('ℹ️  No deployable services found. Use \\'just service-split CTX=<name>\\' to create some.')"amlined one-person dev workflow               ║
# ║  🔄 Reversible Microservice Architecture Support             ║
# ╚═══════════════════════════════════════════════════════════════╝

# Cross-platform shell configuration
set shell := if os() == "windows" { ["powershell.exe", "-c"] } else { ["bash", "-c"] }

# Tool shortcuts and defaults
NX := "npx nx"
CTX := ""                                     # Context name for DDD operations
PROJECT := ""                                 # Project name for operations
TARGET := ""                                  # Target name for infrastructure
PLAYBOOK := ""                                # Ansible playbook name
HOSTS := ""                                   # Ansible hosts
PCT := ""                                     # Percentage for canary deployments
TRANSPORT := "fastapi"                        # Transport layer for microservices
NAMESPACE := "default"                        # Kubernetes namespace
SCALE_TARGET := "70"                          # HPA CPU target percentage

# ==============================================================================
# Configuration Variables - Adjust as needed
# ==============================================================================
PYTHON_VERSION := "3.11.9"
NX_PYTHON_PLUGIN_VERSION := "21.0.3"
RUST_TOOLCHAIN_UV_INSTALL := "false"
CUSTOM_PY_GEN_PLUGIN_NAME := "shared-python-tools"
CUSTOM_PY_APP_GENERATOR := "{{CUSTOM_PY_GEN_PLUGIN_NAME}}:shared-python-app"
CUSTOM_PY_LIB_GENERATOR := "{{CUSTOM_PY_GEN_PLUGIN_NAME}}:shared-python-lib"

# Service Architecture Configuration
SERVICE_GENERATOR := "@org/context-to-service"
SERVICE_REMOVER := "@org/remove-service-shell"
CONTAINER_REGISTRY := "ghcr.io/your-org"
SERVICE_BASE_PORT := "8000"

# Hexagonal Architecture Scaffolding Configuration
APPS := ""
DOMAINS := ""

# Root paths
MONOREPO_ROOT := "."
PYTHON_VENV_PATH := MONOREPO_ROOT + "/.venv"
ROOT_PYPROJECT_TOML := MONOREPO_ROOT + "/pyproject.toml"

# ==============================================================================
# Help System - Auto-generated from target comments
# ==============================================================================

def: help

help: # Show this help menu
    @echo "Available targets:"
    @just --list
    @echo ""
    @echo "🔄 Service Architecture Examples:"
    @echo "  just service-split CTX=accounting TRANSPORT=fastapi"
    @echo "  just service-merge CTX=accounting"
    @echo "  just deploy-services"
    @echo "  just scale-service CTX=accounting REPLICAS=3"
    @echo ""
    @echo "🏗️ Development Examples:"
    @echo "  just context-new CTX=orders      # Create DDD context"
    @echo "  just train                       # Train ML models"
    @echo "  just ci                          # Run CI pipeline"

# ==============================================================================
# Initial Setup and Environment Management
# ==============================================================================

setup: init-nx init-python-env install-custom-py-generator install-service-generators install-pre-commit # Initial one-time setup of the monorepo
    @echo "🚀 Monorepo setup complete! Run 'just help' for available commands."

init-nx: # Initialize Nx workspace
    @python3 scripts/setup.py init_nx --nx-python-plugin-version={{NX_PYTHON_PLUGIN_VERSION}}

init-python-env: # Initialize/update Python environment (.venv)
    @python3 scripts/setup.py init_python_env --python-version={{PYTHON_VERSION}} --root-pyproject-toml={{ROOT_PYPROJECT_TOML}} --monorepo-root={{MONOREPO_ROOT}}

install-custom-py-generator: # Install custom Python generators
    @echo "🔧 Installing custom Python generators..."
    @python3 scripts/setup.py install_custom_py_generator --custom-py-gen-plugin-name={{CUSTOM_PY_GEN_PLUGIN_NAME}}

install-service-generators: # Install service architecture generators
    @echo "🔧 Installing service architecture generators..."
    @pnpm install @org/nx-service-generators || echo "⚠️  Service generators not yet available, will use built-in implementations"

install-pre-commit: # Install git pre-commit hooks
    @python3 scripts/setup.py install_pre_commit

# ==============================================================================
# Project Generation - Apps, Libraries, and DDD Contexts
# ==============================================================================

app NAME: # Generate Python application
    @echo "✨ Generating Python application '{{NAME}}' with custom settings..."
    pnpm nx generate {{CUSTOM_PY_APP_GENERATOR}} {{NAME}} --directory=apps
    @echo "Installing project-specific Python dependencies for {{NAME}}..."
    pnpm nx run {{NAME}}:install-deps
    @echo "🎉 Python application '{{NAME}}' generated and dependencies installed successfully."

lib NAME: # Generate Python library
    @echo "✨ Generating Python library '{{NAME}}' with custom settings..."
    pnpm nx generate {{CUSTOM_PY_LIB_GENERATOR}} {{NAME}} --directory=libs
    @echo "Installing project-specific Python dependencies for {{NAME}}..."
    pnpm nx run {{NAME}}:install-deps
    @echo "🎉 Python library '{{NAME}}' generated and dependencies installed successfully."

context-new CTX: # Create DDD context with hexagonal architecture
    @echo "🏛️ Creating DDD context '{{CTX}}' with hexagonal architecture..."
    @echo "📦 Creating domain layer..."
    {{NX}} g lib {{CTX}} --directory=libs/{{CTX}}/domain --tags=context:{{CTX}},layer:domain,deployable:false
    @echo "⚙️ Creating application layer..."
    {{NX}} g lib {{CTX}} --directory=libs/{{CTX}}/application --tags=context:{{CTX}},layer:application,deployable:false
    @echo "🔌 Creating infrastructure layer..."
    {{NX}} g lib {{CTX}} --directory=libs/{{CTX}}/infrastructure --tags=context:{{CTX}},layer:infrastructure,deployable:false
    @echo "✅ Context {{CTX}} created with hexagonal architecture and deployable:false tags."
    @echo "💡 Use 'just service-split CTX={{CTX}}' to extract as microservice when needed."

# ==============================================================================
# 🔄 Reversible Microservice Architecture Management
# ==============================================================================

service-split CTX TRANSPORT='fastapi': # Extract context to microservice
    @echo "🔧 Extracting context '{{CTX}}' to microservice with {{TRANSPORT}} transport..."
    @echo "📋 Checking if context exists..."
    @python3 scripts/justfile_helper.py check-context --ctx {{CTX}} || (echo "❌ Context {{CTX}} not found. Run 'just context-new CTX={{CTX}}' first." && exit 1)
    @echo "🏗️ Creating microservice application structure..."
    @python3 scripts/justfile_helper.py create-service-app --ctx {{CTX}} --transport {{TRANSPORT}}
    @echo "🐳 Generating container configuration..."
    @python3 scripts/justfile_helper.py create-service-container --ctx {{CTX}}
    @echo "☸️ Generating Kubernetes manifests..."
    @python3 scripts/justfile_helper.py create-service-k8s --ctx {{CTX}}
    @echo "🏷️ Updating deployment tags..."
    @python3 scripts/justfile_helper.py update-service-tags --ctx {{CTX}} --deployable true
    @echo "✅ Context {{CTX}} extracted to microservice at apps/{{CTX}}-svc/"
    @echo "💡 Deploy with: just deploy-service CTX={{CTX}}"

service-merge CTX: # Merge microservice back to monolith
    @echo "🔄 Merging microservice '{{CTX}}' back to monolith..."
    @echo "📋 Checking if service exists..."
    @python3 scripts/justfile_helper.py check-service --ctx {{CTX}} || (echo "❌ Service {{CTX}}-svc not found. Nothing to merge." && exit 1)
    @echo "🗑️ Removing service application..."
    @python3 scripts/justfile_helper.py remove-service --ctx {{CTX}}
    @echo "🏷️ Updating deployment tags..."
    @python3 scripts/justfile_helper.py update-service-tags --ctx {{CTX}} --deployable false
    @echo "✅ Service {{CTX}} merged back to monolith."
    @echo "💡 Context libs/{{CTX}} remains unchanged - zero code impact!"

service-status: # Show deployment status of all contexts
    @python3 scripts/justfile_helper.py service-status

service-list: # List all deployable services
    @python3 scripts/justfile_helper.py service-list

# ==============================================================================
# AI/ML Model Lifecycle Management
# ==============================================================================

model-new CTX: # Generate new ML model library
    @echo "🤖 Creating ML model library '{{CTX}}'..."
    {{NX}} g lib {{CTX}} --directory=libs/models --tags=context:{{CTX}},type:model,deployable:false
    @echo "✅ ML model library {{CTX}} created."

train: # Train all affected ML models
    @echo "🧠 Training affected ML models..."
    {{NX}} affected --target=train --parallel

evaluate: # Evaluate affected ML models
    @echo "📊 Evaluating affected ML models..."
    {{NX}} affected --target=evaluate --parallel

register: # Register affected models in model registry
    @echo "📝 Registering affected models..."
    {{NX}} affected --target=register --parallel

promote CTX CH: # Promote model to environment
    @echo "🚀 Promoting model {{CTX}} to {{CH}}..."
    {{NX}} run libs/models/{{CTX}}:promote --to={{CH}}

canary PCT: # Canary deploy API with traffic percentage
    @echo "🐦 Canary deploying API with {{PCT}}% traffic..."
    {{NX}} run apps/api:deploy --percent {{PCT}}

# ==============================================================================
# Development Workflow - Quality Gates and CI/CD
# ==============================================================================

dev: # Start affected apps in development mode with watch
    @echo "🚀 Starting development servers..."
    {{NX}} run-many --target=serve --all --parallel

ci: # Run complete CI pipeline with service filtering
    @echo "🔄 Running CI pipeline..."
    @echo "📝 Formatting check..."
    {{NX}} format:check
    @echo "🔍 Linting affected projects..."
    {{NX}} affected -t lint --parallel=3
    @echo "🧪 Testing affected projects..."
    {{NX}} affected -t test --parallel=3
    @echo "🧪 Running e2e tests..."
    @just e2e-test
    @echo "📦 Building affected projects..."
    {{NX}} affected -t build --parallel=3
    @echo "🐳 Building deployable services..."
    @just build-services
    @echo "✅ CI pipeline completed successfully!"

ci-services: # Run CI only for deployable services
    @echo "🔄 Running CI pipeline for deployable services..."
    {{NX}} affected --target=lint,test,build --projects="tag:deployable:true" --parallel=3

build-services: # Build all deployable services
    @echo "🐳 Building deployable services..."
    @python3 -c "import subprocess, os; services = [d.name for d in os.scandir('apps') if d.is_dir() and d.name.endswith('-svc')]; subprocess.run(['npx', 'nx', 'run-many', '--target=build', '--projects=tag:deployable:true', '--parallel=3']) if services else print('ℹ️  No deployable services found. Use \\'just service-split CTX=<name>\\' to create some.')"

lint: # Lint all affected projects
    @echo "🔎 Linting affected projects..."
    {{NX}} affected --target=lint --base=main --parallel=3

test: # Run tests for all affected projects
    @echo "🧪 Running tests for affected projects..."
    {{NX}} affected --target=test --base=main --parallel=3

e2e-test: # Run e2e tests
    @echo "🧪 Running e2e tests for vector-db..."
    {{NX}} e2e e2e-vector-db

build: # Build all affected projects
    @echo "📦 Building affected projects..."
    {{NX}} affected --target=build --base=main --parallel=3

serve PROJECT: # Serve specific application
    @echo "🚀 Serving '{{PROJECT}}'..."
    {{NX}} serve {{PROJECT}}

graph: # Open Nx dependency graph visualizer
    @echo "📊 Opening Nx dependency graph..."
    {{NX}} graph

# ==============================================================================
# 🐳 Container and Kubernetes Management
# ==============================================================================

containerize PROJECT: # Build Docker image for project
    @echo "🐳 Building Docker image for '{{PROJECT}}'..."
    {{NX}} run {{PROJECT}}:container
    @echo "✅ Docker image for '{{PROJECT}}' built successfully."

build-service-images: # Build Docker images for all deployable services
    @echo "🐳 Building Docker images for all deployable services..."
    @python3 -c " \
import subprocess, os; \
services = [d.name for d in os.scandir('apps') if d.is_dir() and d.name.endswith('-svc')]; \
[print(f'🔨 Building image for {svc}...') or subprocess.run(['npx', 'nx', 'run', f'{svc}:docker'], check=False) for svc in services] if services else print('ℹ️  No services found to build')"

deploy-service CTX: # Deploy specific service to Kubernetes
    @echo "🚀 Deploying service {{CTX}} to Kubernetes..."
    @python3 scripts/justfile_helper.py check-service --ctx {{CTX}} || (echo "❌ Service {{CTX}}-svc not found. Run 'just service-split CTX={{CTX}}' first." && exit 1)
    @echo "🐳 Building service image..."
    {{NX}} run {{CTX}}-svc:docker
    @echo "☸️ Applying Kubernetes manifests..."
    kubectl apply -f apps/{{CTX}}-svc/k8s/ --namespace={{NAMESPACE}}
    @echo "✅ Service {{CTX}} deployed successfully!"

deploy-services: # Deploy all deployable services to Kubernetes
    @echo "🚀 Deploying all deployable services to Kubernetes..."
    @python3 -c " \
import subprocess, os; \
services = [d.name for d in os.scandir('apps') if d.is_dir() and d.name.endswith('-svc')]; \
[print(f'🚀 Deploying {svc}...') or subprocess.run(['just', 'deploy-service', f'CTX={svc[:-4]}'], check=False) for svc in services] if services else print('ℹ️  No services found to deploy')"

scale-service CTX REPLICAS: # Scale service replicas
    @echo "📈 Scaling service {{CTX}} to {{REPLICAS}} replicas..."
    kubectl scale deployment {{CTX}}-svc --replicas={{REPLICAS}} --namespace={{NAMESPACE}}
    @echo "✅ Service {{CTX}} scaled to {{REPLICAS}} replicas."

service-logs CTX: # View service logs
    @echo "📄 Viewing logs for service {{CTX}}..."
    kubectl logs -l app={{CTX}}-svc --namespace={{NAMESPACE}} --tail=100 -f

# ==============================================================================
# Infrastructure as Code (IaC) - Terraform, Ansible, and Cloud
# ==============================================================================

infra-plan TARGET: # Run terraform plan
    @echo "🗺️ Running IaC plan for '{{TARGET}}'..."
    {{NX}} run infrastructure:plan-{{TARGET}}

infra-apply TARGET: # Apply terraform changes
    @echo "🚀 Applying IaC changes for '{{TARGET}}'..."
    {{NX}} run infrastructure:apply-{{TARGET}}

ansible-run PLAYBOOK HOSTS: # Run Ansible playbook
    @echo "⚙️ Running Ansible playbook '{{PLAYBOOK}}' on hosts '{{HOSTS}}'..."
    {{NX}} run ansible-playbooks:run-{{PLAYBOOK}} --args="--inventory {{HOSTS}}"

# ==============================================================================
# Workspace Management and Diagnostics
# ==============================================================================

cache-clear: # Clear Nx cache
    @echo "🧹 Clearing Nx cache..."
    {{NX}} reset

doctor: # Verify workspace constraints and generate dependency graph
    @echo "🩺 Running workspace diagnostics..."
    {{NX}} graph --file=diag.html && echo "📊 Dependency graph saved to diag.html"
    @echo "📋 Checking service architecture integrity..."
    @just service-status

tree: # Pretty-print current workspace layout
    @echo "📁 Current workspace structure:"
    @python3 -c " \
import os, subprocess; \
try: subprocess.run(['tree', '-I', 'node_modules|__pycache__|*.pyc|.pytest_cache|.nx|dist', '-L', '3'], check=True) \
except: [print(f'./{p}') for p in sorted([os.path.relpath(r, '.') for r, d, f in os.walk('.') if not any(x in r for x in ['node_modules', '__pycache__', '.nx', 'dist'])][1:51])]"

clean: # Clean build artifacts and caches (use with caution)
    @echo "🗑️ Cleaning Nx cache, node_modules, and Python environments..."
    @python3 scripts/justfile_helper.py clean --targets nx node_modules python venv
    @echo "✅ Cleanup complete. You may need to run 'just setup' again."
