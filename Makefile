# ==============================================================================
# Makefile: Monorepo Orchestration for AI-Native Projects
# Built for a streamlined, one-person dev workflow.
# Uses pyenv, uv, ruff, mypy, pytest, pnpm, and Nx.
# ==============================================================================elp setup init-python-env generate-python-app generate-python-lib \
        install-pre-commit lint typecheck test build serve graph deploy-k8s-dev \
        containerize clean scaffold clean-scaffold tree domain-lib batch-domains \
        domain-stack allocation-stack payments-stack list-domain lint-domain \
        test-domain build-domain graph-domain help-domain

# ==============================================================================
# Configuration Variables - Adjust as needed
# ==============================================================================
PYTHON_VERSION ?= 3.11.9
NX_PYTHON_PLUGIN_VERSION ?= 21.0.3 # Updated to latest stable for @nxlv/python
RUST_TOOLCHAIN_UV_INSTALL ?= false # Set to true to install uv via rustup for a self-contained install
# Add your custom Nx generator details
CUSTOM_PY_GEN_PLUGIN_NAME ?= shared-python-tools
CUSTOM_PY_APP_GENERATOR ?= $(CUSTOM_PY_GEN_PLUGIN_NAME):shared-python-app
CUSTOM_PY_LIB_GENERATOR ?= $(CUSTOM_PY_GEN_PLUGIN_NAME):shared-python-lib

# Hexagonal Architecture Scaffolding Configuration
# Edit these lists to define your workspace structure
APPS := allocation-api payments-api invoicing-api
DOMAINS := allocation payments invoicing inventory shipping analytics

# Root paths (relative to Makefile)
MONOREPO_ROOT := $(CURDIR)
PYTHON_VENV_PATH := $(MONOREPO_ROOT)/.venv
ROOT_PYPROJECT_TOML := $(MONOREPO_ROOT)/pyproject.toml

# Derived variables for hexagonal architecture scaffolding
APP_DIRS := $(addprefix apps/,$(addsuffix /src,$(APPS)))
APP_FILES := $(addprefix apps/,$(addsuffix /src/main.py,$(APPS))) \
             $(addprefix apps/,$(addsuffix /project.json,$(APPS)))

# Domain/libraries – generate all required leaf dirs for hexagonal architecture
DOM_ENTITY_DIRS   := $(addprefix libs/,$(addsuffix /domain/entities,$(DOMAINS)))
DOM_AGG_DIRS      := $(addprefix libs/,$(addsuffix /domain/aggregates,$(DOMAINS)))
DOM_VALOBJ_DIRS   := $(addprefix libs/,$(addsuffix /domain/value_objects,$(DOMAINS)))
DOM_POLICY_DIRS   := $(addprefix libs/,$(addsuffix /domain/policies,$(DOMAINS)))
DOM_RULE_DIRS     := $(addprefix libs/,$(addsuffix /domain/rules,$(DOMAINS)))
DOM_APP_DIRS      := $(addprefix libs/,$(addsuffix /application,$(DOMAINS)))
DOM_ADAPTER_DIRS  := $(addprefix libs/,$(addsuffix /adapters,$(DOMAINS)))

DOM_ALL_DIRS := $(DOM_ENTITY_DIRS) $(DOM_AGG_DIRS) $(DOM_VALOBJ_DIRS) \
                $(DOM_POLICY_DIRS) $(DOM_RULE_DIRS) $(DOM_APP_DIRS) $(DOM_ADAPTER_DIRS)

# Domain stub files (__init__.py & project.json)
define GEN_DOMAIN_FILES
libs/$(1)/project.json \
libs/$(1)/domain/__init__.py \
libs/$(1)/application/__init__.py \
libs/$(1)/adapters/__init__.py \
libs/$(1)/domain/entities/__init__.py \
libs/$(1)/domain/aggregates/__init__.py \
libs/$(1)/domain/value_objects/__init__.py \
libs/$(1)/domain/policies/__init__.py \
libs/$(1)/domain/rules/__init__.py
endef

DOMAIN_FILES := $(foreach d,$(DOMAINS),$(call GEN_DOMAIN_FILES,$d))

# One-shot repo-wide folders / files
SCAFFOLD_ROOT_DIRS  := tools docker
SCAFFOLD_ROOT_FILES := docker/Dockerfile docker/docker-compose.yml

# ==============================================================================
# Help and Setup Targets
# ==============================================================================

help:
	@echo "=============================================================================="
	@echo "Nx Monorepo Management - Quick Start & Daily Workflow"
	@echo "=============================================================================="
	@echo "Usage:"
	@echo "  make setup                - Initial one-time setup of the monorepo."
	@echo "  make init-python-env      - Initializes/updates the root Python dev environment (.venv)."
	@echo ""
	@echo "  make app NAME=<name>      - Generates a new Python application (e.g., make app NAME=my-fastapi-service)"
	@echo "  make lib NAME=<name>      - Generates a new Python library (e.g., make lib NAME=my-shared-utils)"
	@echo ""
	@echo "  make scaffold             - Generate hexagonal architecture workspace structure"
	@echo "  make clean-scaffold       - Delete generated hexagonal architecture tree"
	@echo "  make tree                 - Pretty-print current workspace layout"
	@echo ""
	@echo "  make install-pre-commit   - Installs git pre-commit hooks."
	@echo ""
	@echo "  make lint                 - Lints all affected projects (JS/TS, Python)."
	@echo "  make typecheck            - Type-checks all affected projects (JS/TS, Python)."
	@echo "  make test                 - Runs tests for all affected projects."
	@echo "  make build                - Builds all affected projects (JS/TS apps/libs)."
	@echo ""
	@echo "  make serve PROJECT=<name> - Serves a specific application (e.g., React frontend, Python API)."
	@echo "                              Example: make serve PROJECT=my-react-app"
	@echo "  make graph                - Opens the Nx dependency graph visualizer."
	@echo ""
	@echo "  make help-domain          - Show domain-driven development commands"
	@echo ""
	@echo "  make infra-plan TARGET=<name>  - Runs 'terraform plan' or similar for IaC project (e.g., TARGET=vpc)."
	@echo "  make infra-apply TARGET=<name> - Runs 'terraform apply' or similar for IaC project (e.g., TARGET=vpc)."
	@echo "  make ansible-run PLAYBOOK=<name> HOSTS=<hosts> - Runs an Ansible playbook."
	@echo ""
	@echo "  make containerize PROJECT=<name> - Builds a Docker image for a given project."
	@echo ""
	@echo "  make clean                - Cleans build artifacts and caches (use with caution)."
	@echo "=============================================================================="

setup: init-nx init-python-env install-custom-py-generator install-pre-commit
	@echo "🚀 Monorepo setup complete! Run 'make help' for available commands."

init-nx:
	@python scripts/setup.py init_nx --nx-python-plugin-version=$(NX_PYTHON_PLUGIN_VERSION)

init-python-env:
	@python scripts/setup.py init_python_env --python-version=$(PYTHON_VERSION) --rust-toolchain-uv-install=$(RUST_TOOLCHAIN_UV_INSTALL) --root-pyproject-toml=$(ROOT_PYPROJECT_TOML) --monorepo-root=$(MONOREPO_ROOT)

install-custom-py-generator:
	@bash ./.make_assets/setup_helper.sh install_custom_py_generator $(CUSTOM_PY_GEN_PLUGIN_NAME)

install-pre-commit:
	@python scripts/setup.py install_pre_commit


# ==============================================================================
# Project Generation Targets
# ==============================================================================

app:
	@sh -c 'if [ -z "$(NAME)" ]; then echo "Error: Please provide a project name. Usage: make app NAME=my-new-api"; exit 1; fi'
	@echo "✨ Generating Python application '$(NAME)' with custom settings..."
	pnpm nx generate $(CUSTOM_PY_APP_GENERATOR) $(NAME) --directory=apps
	@echo "Installing project-specific Python dependencies for $(NAME)..."
	pnpm nx run $(NAME):install-deps # Automatically install deps for the new app
	@echo "🎉 Python application '$(NAME)' generated and dependencies installed successfully."

lib:
	@sh -c 'if [ -z "$(NAME)" ]; then echo "Error: Please provide a project name. Usage: make lib NAME=my-shared-lib"; exit 1; fi'
	@echo "✨ Generating Python library '$(NAME)' with custom settings..."
	pnpm nx generate $(CUSTOM_PY_LIB_GENERATOR) $(NAME) --directory=libs
	@echo "Installing project-specific Python dependencies for $(NAME)..."
	pnpm nx run $(NAME):install-deps # Automatically install deps for the new lib
	@echo "🎉 Python library '$(NAME)' generated and dependencies installed successfully."

# ==============================================================================
# Daily Workflow Targets (Using Nx Affected)
# ==============================================================================

lint:
	@echo "🔎 Linting affected projects..."
	pnpm nx affected --target=lint --base=main --parallel=3

typecheck:
	@echo "🧐 Type-checking affected projects..."
	pnpm nx affected --target=typecheck --base=main --parallel=3

test:
	@echo "🧪 Running tests for affected projects..."
	pnpm nx affected --target=test --base=main --parallel=3

build:
	@echo "📦 Building affected projects..."
	pnpm nx affected --target=build --base=main --parallel=3

serve:
	@sh -c 'if [ -z "$(PROJECT)" ]; then echo "Error: Please provide a project name to serve. Usage: make serve PROJECT=my-react-app or make serve PROJECT=my-fastapi-service"; exit 1; fi'
	@echo "🚀 Serving '$(PROJECT)'..."
	pnpm nx serve $(PROJECT)

graph:
	@echo "📊 Opening Nx dependency graph..."
	pnpm nx graph

# ==============================================================================
# Infrastructure as Code (IaC) Targets
# ==============================================================================

# Generic target for Terraform, Pulumi, etc.
# Assumes you have an Nx project named 'infrastructure' that contains sub-directories
# for different environments/stacks (e.g., 'infrastructure/terraform/vpc')
# and a 'plan' or 'apply' target defined in its project.json.
# Example usage: make infra-plan TARGET=vpc
infra-plan:
	@sh -c 'if [ -z "$(TARGET)" ]; then echo "Error: Please specify the IaC target (e.g., 'vpc', 'kubernetes-cluster'). Usage: make infra-plan TARGET=vpc"; exit 1; fi'
	@echo "🗺️ Running IaC plan for '$(TARGET)'..."
	pnpm nx run infrastructure:plan-$(TARGET) # Assumes target name is plan-<TARGET>

infra-apply:
	@sh -c 'if [ -z "$(TARGET)" ]; then echo "Error: Please specify the IaC target. Usage: make infra-apply TARGET=vpc"; exit 1; fi'
	@echo "🚀 Applying IaC changes for '$(TARGET)'..."
	pnpm nx run infrastructure:apply-$(TARGET) # Assumes target name is apply-<TARGET>

# Specific target for Ansible
# Assumes an Nx project named 'ansible-playbooks' or similar, with targets
# configured for specific playbooks.
# Example usage: make ansible-run PLAYBOOK=deploy-web-servers HOSTS=production
ansible-run:
	@sh -c 'if [ -z "$(PLAYBOOK)" ]; then echo "Error: Please specify the Ansible playbook name. Usage: make ansible-run PLAYBOOK=deploy-web-servers"; exit 1; fi'
	@echo "⚙️ Running Ansible playbook '$(PLAYBOOK)' on hosts '$(HOSTS)'..."
	pnpm nx run ansible-playbooks:run-$(PLAYBOOK) --args="--inventory $(HOSTS)" # Assumes target name is run-<PLAYBOOK>

# ==============================================================================
# Containerization Targets (Microservices Transformation)
# ==============================================================================

# Assumes that each application project (e.g., apps/my-fastapi-service) has a Dockerfile
# in its root and a 'container' target defined in its project.json to build the image.
# This target is designed to make "transforming any monorepo into a microservice architecture
# without fuss at will" a reality at the build step.
containerize:
	@sh -c 'if [ -z "$(PROJECT)" ]; then echo "Error: Please specify the project to containerize. Usage: make containerize PROJECT=my-fastapi-service"; exit 1; fi'
	@echo "🐳 Building Docker image for '$(PROJECT)'..."
	pnpm nx run $(PROJECT):container # Assumes a 'container' target in project.json
	@echo "✅ Docker image for '$(PROJECT)' built successfully."

# ==============================================================================
# Cleanup (Use with Caution!)
# ==============================================================================
clean:
	@echo "🗑️ Cleaning Nx cache, node_modules, and Python environments..."
	pnpm nx reset
	rm -rf node_modules
	rm -rf .venv
	find . -name ".nx" -type d -exec rm -rf {} +
	find . -name "dist" -type d -exec rm -rf {} +
	find . -name "__pycache__" -type d -exec rm -rf {} +
	find . -name "*.pyc" -delete
	find . -name ".pytest_cache" -type d -exec rm -rf {} +
	@echo "Cleanup complete. You may need to run 'make setup' again."

.DEFAULT_GOAL := help

# ==============================================================================
# Hexagonal Architecture Scaffolding Targets
# ==============================================================================

# Primary scaffolding targets - generate complete hexagonal architecture workspace
scaffold:
	@echo "🏗️ Generating hexagonal architecture workspace..."
	@echo "📁 Creating apps: $(APPS)"
	@echo "📁 Creating domains: $(DOMAINS)"
	@$(MAKE) -s scaffold-apps
	@$(MAKE) -s scaffold-domains
	@$(MAKE) -s scaffold-infrastructure
	@echo "✅ Hexagonal architecture workspace scaffolded."
	@echo "🏗️ Run 'make tree' to view the complete structure."

# Create app structure for all configured apps with proper FastAPI interfaces
scaffold-apps:
	@for app in $(APPS); do \
		echo "Creating hexagonal app interface: $$app"; \
		domain=$$(echo $$app | sed 's/-api//'); \
		mkdir -p "apps/$$app/src/api/v1"; \
		mkdir -p "apps/$$app/src/dependencies"; \
		mkdir -p "apps/$$app/src/models"; \
		if [ ! -f "apps/$$app/src/main.py" ]; then \
			echo "\"\"\"" > "apps/$$app/src/main.py"; \
			echo "$$app - Thin interface layer for $$domain domain" >> "apps/$$app/src/main.py"; \
			echo "This is just an HTTP adapter that exposes $$domain domain services" >> "apps/$$app/src/main.py"; \
			echo "\"\"\"" >> "apps/$$app/src/main.py"; \
			echo "from fastapi import FastAPI" >> "apps/$$app/src/main.py"; \
			echo "from .api.v1 import router as api_v1_router" >> "apps/$$app/src/main.py"; \
			echo "" >> "apps/$$app/src/main.py"; \
			echo "app = FastAPI(" >> "apps/$$app/src/main.py"; \
			echo "    title=\"$$(echo $$domain | sed 's/.*/\u&/') API\"," >> "apps/$$app/src/main.py"; \
			echo "    description=\"Hexagonal architecture interface for $$domain domain\"," >> "apps/$$app/src/main.py"; \
			echo "    version=\"1.0.0\"" >> "apps/$$app/src/main.py"; \
			echo ")" >> "apps/$$app/src/main.py"; \
			echo "" >> "apps/$$app/src/main.py"; \
			echo "app.include_router(api_v1_router, prefix=\"/api/v1\")" >> "apps/$$app/src/main.py"; \
			echo "" >> "apps/$$app/src/main.py"; \
			echo "@app.get(\"/health\")" >> "apps/$$app/src/main.py"; \
			echo "async def health_check():" >> "apps/$$app/src/main.py"; \
			echo "    return {" >> "apps/$$app/src/main.py"; \
			echo "        \"status\": \"healthy\"," >> "apps/$$app/src/main.py"; \
			echo "        \"service\": \"$$domain\"," >> "apps/$$app/src/main.py"; \
			echo "        \"architecture\": \"hexagonal\"" >> "apps/$$app/src/main.py"; \
			echo "    }" >> "apps/$$app/src/main.py"; \
			echo "" >> "apps/$$app/src/main.py"; \
			echo "if __name__ == \"__main__\":" >> "apps/$$app/src/main.py"; \
			echo "    import uvicorn" >> "apps/$$app/src/main.py"; \
			echo "    uvicorn.run(app, host=\"0.0.0.0\", port=8000)" >> "apps/$$app/src/main.py"; \
		fi; \
		if [ ! -f "apps/$$app/src/api/__init__.py" ]; then \
			touch "apps/$$app/src/api/__init__.py"; \
		fi; \
		if [ ! -f "apps/$$app/src/api/v1/__init__.py" ]; then \
			echo "\"\"\"API v1 router for $$domain domain\"\"\"" > "apps/$$app/src/api/v1/__init__.py"; \
			echo "from fastapi import APIRouter, Depends" >> "apps/$$app/src/api/v1/__init__.py"; \
			echo "from ...dependencies.$$domain import get_$${domain}_service" >> "apps/$$app/src/api/v1/__init__.py"; \
			echo "" >> "apps/$$app/src/api/v1/__init__.py"; \
			echo "router = APIRouter()" >> "apps/$$app/src/api/v1/__init__.py"; \
			echo "" >> "apps/$$app/src/api/v1/__init__.py"; \
			echo "@router.get(\"/$$domain\")" >> "apps/$$app/src/api/v1/__init__.py"; \
			echo "async def list_$${domain}s(service=Depends(get_$${domain}_service)):" >> "apps/$$app/src/api/v1/__init__.py"; \
			echo "    \"\"\"List all $${domain}s\"\"\"" >> "apps/$$app/src/api/v1/__init__.py"; \
			echo "    return await service.get_all()" >> "apps/$$app/src/api/v1/__init__.py"; \
			echo "" >> "apps/$$app/src/api/v1/__init__.py"; \
			echo "@router.post(\"/$$domain\")" >> "apps/$$app/src/api/v1/__init__.py"; \
			echo "async def create_$$domain(data: dict, service=Depends(get_$${domain}_service)):" >> "apps/$$app/src/api/v1/__init__.py"; \
			echo "    \"\"\"Create new $$domain\"\"\"" >> "apps/$$app/src/api/v1/__init__.py"; \
			echo "    return await service.create(data)" >> "apps/$$app/src/api/v1/__init__.py"; \
		fi; \
		if [ ! -f "apps/$$app/src/dependencies/__init__.py" ]; then \
			touch "apps/$$app/src/dependencies/__init__.py"; \
		fi; \
		if [ ! -f "apps/$$app/src/dependencies/$$domain.py" ]; then \
			echo "\"\"\"Dependency injection for $$domain domain\"\"\"" > "apps/$$app/src/dependencies/$$domain.py"; \
			echo "from libs.$$domain.application.$${domain}_service import $$(echo $$domain | sed 's/.*/\u&/')Service" >> "apps/$$app/src/dependencies/$$domain.py"; \
			echo "from libs.$$domain.adapters.memory_adapter import Memory$$(echo $$domain | sed 's/.*/\u&/')Adapter" >> "apps/$$app/src/dependencies/$$domain.py"; \
			echo "" >> "apps/$$app/src/dependencies/$$domain.py"; \
			echo "def get_$${domain}_service() -> $$(echo $$domain | sed 's/.*/\u&/')Service:" >> "apps/$$app/src/dependencies/$$domain.py"; \
			echo "    \"\"\"Get $$domain service with injected dependencies\"\"\"" >> "apps/$$app/src/dependencies/$$domain.py"; \
			echo "    repository = Memory$$(echo $$domain | sed 's/.*/\u&/')Adapter()" >> "apps/$$app/src/dependencies/$$domain.py"; \
			echo "    return $$(echo $$domain | sed 's/.*/\u&/')Service(repository)" >> "apps/$$app/src/dependencies/$$domain.py"; \
		fi; \
		if [ ! -f "apps/$$app/project.json" ]; then \
			echo "{ \"name\": \"$$app\", \"root\": \"apps/$$app\", \"projectType\": \"application\", \"tags\": [\"scope:$$domain\", \"type:api\"], \"targets\": { \"serve\": { \"executor\": \"@nx/python:run\", \"options\": { \"module\": \"src.main\" } } } }" > "apps/$$app/project.json"; \
		fi; \
	done

# Create domain structure for all configured domains with hexagonal architecture
scaffold-domains:
	@for domain in $(DOMAINS); do \
		echo "Creating hexagonal domain: $$domain"; \
		mkdir -p "libs/$$domain/domain/entities"; \
		mkdir -p "libs/$$domain/domain/aggregates"; \
		mkdir -p "libs/$$domain/domain/value_objects"; \
		mkdir -p "libs/$$domain/domain/policies"; \
		mkdir -p "libs/$$domain/domain/rules"; \
		mkdir -p "libs/$$domain/application"; \
		mkdir -p "libs/$$domain/adapters"; \
		touch "libs/$$domain/domain/__init__.py"; \
		touch "libs/$$domain/domain/entities/__init__.py"; \
		touch "libs/$$domain/domain/aggregates/__init__.py"; \
		touch "libs/$$domain/domain/value_objects/__init__.py"; \
		touch "libs/$$domain/domain/policies/__init__.py"; \
		touch "libs/$$domain/domain/rules/__init__.py"; \
		touch "libs/$$domain/application/__init__.py"; \
		touch "libs/$$domain/adapters/__init__.py"; \
		if [ ! -f "libs/$$domain/application/$${domain}_service.py" ]; then \
			echo "\"\"\"" > "libs/$$domain/application/$${domain}_service.py"; \
			echo "$$(echo $$domain | sed 's/.*/\u&/') Application Service - Use cases and orchestration" >> "libs/$$domain/application/$${domain}_service.py"; \
			echo "This contains the business workflows and coordinates domain objects" >> "libs/$$domain/application/$${domain}_service.py"; \
			echo "\"\"\"" >> "libs/$$domain/application/$${domain}_service.py"; \
			echo "from typing import List, Dict, Any, Optional" >> "libs/$$domain/application/$${domain}_service.py"; \
			echo "from ..adapters.$${domain}_repository_port import $$(echo $$domain | sed 's/.*/\u&/')RepositoryPort" >> "libs/$$domain/application/$${domain}_service.py"; \
			echo "from ..domain.entities.$${domain} import $$(echo $$domain | sed 's/.*/\u&/')" >> "libs/$$domain/application/$${domain}_service.py"; \
			echo "" >> "libs/$$domain/application/$${domain}_service.py"; \
			echo "class $$(echo $$domain | sed 's/.*/\u&/')Service:" >> "libs/$$domain/application/$${domain}_service.py"; \
			echo "    \"\"\"Application service that orchestrates $$domain use cases\"\"\"" >> "libs/$$domain/application/$${domain}_service.py"; \
			echo "    " >> "libs/$$domain/application/$${domain}_service.py"; \
			echo "    def __init__(self, repository: $$(echo $$domain | sed 's/.*/\u&/')RepositoryPort):" >> "libs/$$domain/application/$${domain}_service.py"; \
			echo "        self._repository = repository" >> "libs/$$domain/application/$${domain}_service.py"; \
			echo "    " >> "libs/$$domain/application/$${domain}_service.py"; \
			echo "    async def get_all(self) -> List[Dict[str, Any]]:" >> "libs/$$domain/application/$${domain}_service.py"; \
			echo "        \"\"\"Use case: Retrieve all $${domain}s\"\"\"" >> "libs/$$domain/application/$${domain}_service.py"; \
			echo "        items = await self._repository.find_all()" >> "libs/$$domain/application/$${domain}_service.py"; \
			echo "        return [item.to_dict() for item in items]" >> "libs/$$domain/application/$${domain}_service.py"; \
			echo "    " >> "libs/$$domain/application/$${domain}_service.py"; \
			echo "    async def create(self, data: Dict[str, Any]) -> Dict[str, Any]:" >> "libs/$$domain/application/$${domain}_service.py"; \
			echo "        \"\"\"Use case: Create new $$domain\"\"\"" >> "libs/$$domain/application/$${domain}_service.py"; \
			echo "        item = $$(echo $$domain | sed 's/.*/\u&/').create(**data)" >> "libs/$$domain/application/$${domain}_service.py"; \
			echo "        saved_item = await self._repository.save(item)" >> "libs/$$domain/application/$${domain}_service.py"; \
			echo "        return saved_item.to_dict()" >> "libs/$$domain/application/$${domain}_service.py"; \
			echo "    " >> "libs/$$domain/application/$${domain}_service.py"; \
			echo "    async def get_by_id(self, item_id: str) -> Optional[Dict[str, Any]]:" >> "libs/$$domain/application/$${domain}_service.py"; \
			echo "        \"\"\"Use case: Get $$domain by ID\"\"\"" >> "libs/$$domain/application/$${domain}_service.py"; \
			echo "        item = await self._repository.find_by_id(item_id)" >> "libs/$$domain/application/$${domain}_service.py"; \
			echo "        return item.to_dict() if item else None" >> "libs/$$domain/application/$${domain}_service.py"; \
		fi; \
		if [ ! -f "libs/$$domain/domain/entities/$${domain}.py" ]; then \
			echo "\"\"\"" > "libs/$$domain/domain/entities/$${domain}.py"; \
			echo "$$(echo $$domain | sed 's/.*/\u&/') Entity - Core business object" >> "libs/$$domain/domain/entities/$${domain}.py"; \
			echo "Pure domain logic with no external dependencies" >> "libs/$$domain/domain/entities/$${domain}.py"; \
			echo "\"\"\"" >> "libs/$$domain/domain/entities/$${domain}.py"; \
			echo "from dataclasses import dataclass" >> "libs/$$domain/domain/entities/$${domain}.py"; \
			echo "from datetime import datetime" >> "libs/$$domain/domain/entities/$${domain}.py"; \
			echo "from typing import Dict, Any" >> "libs/$$domain/domain/entities/$${domain}.py"; \
			echo "import uuid" >> "libs/$$domain/domain/entities/$${domain}.py"; \
			echo "" >> "libs/$$domain/domain/entities/$${domain}.py"; \
			echo "@dataclass" >> "libs/$$domain/domain/entities/$${domain}.py"; \
			echo "class $$(echo $$domain | sed 's/.*/\u&/'):" >> "libs/$$domain/domain/entities/$${domain}.py"; \
			echo "    \"\"\"Core $$domain entity with business rules\"\"\"" >> "libs/$$domain/domain/entities/$${domain}.py"; \
			echo "    id: str" >> "libs/$$domain/domain/entities/$${domain}.py"; \
			echo "    name: str" >> "libs/$$domain/domain/entities/$${domain}.py"; \
			echo "    description: str" >> "libs/$$domain/domain/entities/$${domain}.py"; \
			echo "    created_at: datetime" >> "libs/$$domain/domain/entities/$${domain}.py"; \
			echo "    updated_at: datetime" >> "libs/$$domain/domain/entities/$${domain}.py"; \
			echo "    " >> "libs/$$domain/domain/entities/$${domain}.py"; \
			echo "    @classmethod" >> "libs/$$domain/domain/entities/$${domain}.py"; \
			echo "    def create(cls, name: str, description: str = \"\") -> \"$$(echo $$domain | sed 's/.*/\u&/')\":" >> "libs/$$domain/domain/entities/$${domain}.py"; \
			echo "        \"\"\"Factory method with business validation\"\"\"" >> "libs/$$domain/domain/entities/$${domain}.py"; \
			echo "        if not name.strip():" >> "libs/$$domain/domain/entities/$${domain}.py"; \
			echo "            raise ValueError(\"Name cannot be empty\")" >> "libs/$$domain/domain/entities/$${domain}.py"; \
			echo "        " >> "libs/$$domain/domain/entities/$${domain}.py"; \
			echo "        now = datetime.utcnow()" >> "libs/$$domain/domain/entities/$${domain}.py"; \
			echo "        return cls(" >> "libs/$$domain/domain/entities/$${domain}.py"; \
			echo "            id=str(uuid.uuid4())," >> "libs/$$domain/domain/entities/$${domain}.py"; \
			echo "            name=name.strip()," >> "libs/$$domain/domain/entities/$${domain}.py"; \
			echo "            description=description.strip()," >> "libs/$$domain/domain/entities/$${domain}.py"; \
			echo "            created_at=now," >> "libs/$$domain/domain/entities/$${domain}.py"; \
			echo "            updated_at=now" >> "libs/$$domain/domain/entities/$${domain}.py"; \
			echo "        )" >> "libs/$$domain/domain/entities/$${domain}.py"; \
			echo "    " >> "libs/$$domain/domain/entities/$${domain}.py"; \
			echo "    def is_valid(self) -> bool:" >> "libs/$$domain/domain/entities/$${domain}.py"; \
			echo "        \"\"\"Business rule: Check if $$domain is valid\"\"\"" >> "libs/$$domain/domain/entities/$${domain}.py"; \
			echo "        return bool(self.name.strip())" >> "libs/$$domain/domain/entities/$${domain}.py"; \
			echo "    " >> "libs/$$domain/domain/entities/$${domain}.py"; \
			echo "    def to_dict(self) -> Dict[str, Any]:" >> "libs/$$domain/domain/entities/$${domain}.py"; \
			echo "        \"\"\"Convert to dictionary for serialization\"\"\"" >> "libs/$$domain/domain/entities/$${domain}.py"; \
			echo "        return {" >> "libs/$$domain/domain/entities/$${domain}.py"; \
			echo "            \"id\": self.id," >> "libs/$$domain/domain/entities/$${domain}.py"; \
			echo "            \"name\": self.name," >> "libs/$$domain/domain/entities/$${domain}.py"; \
			echo "            \"description\": self.description," >> "libs/$$domain/domain/entities/$${domain}.py"; \
			echo "            \"created_at\": self.created_at.isoformat()," >> "libs/$$domain/domain/entities/$${domain}.py"; \
			echo "            \"updated_at\": self.updated_at.isoformat()" >> "libs/$$domain/domain/entities/$${domain}.py"; \
			echo "        }" >> "libs/$$domain/domain/entities/$${domain}.py"; \
		fi; \
		if [ ! -f "libs/$$domain/adapters/$${domain}_repository_port.py" ]; then \
			echo "\"\"\"" > "libs/$$domain/adapters/$${domain}_repository_port.py"; \
			echo "Repository Port - Interface for $$domain data persistence" >> "libs/$$domain/adapters/$${domain}_repository_port.py"; \
			echo "Defines the contract without implementation details" >> "libs/$$domain/adapters/$${domain}_repository_port.py"; \
			echo "\"\"\"" >> "libs/$$domain/adapters/$${domain}_repository_port.py"; \
			echo "from abc import ABC, abstractmethod" >> "libs/$$domain/adapters/$${domain}_repository_port.py"; \
			echo "from typing import List, Optional" >> "libs/$$domain/adapters/$${domain}_repository_port.py"; \
			echo "from ..domain.entities.$${domain} import $$(echo $$domain | sed 's/.*/\u&/')" >> "libs/$$domain/adapters/$${domain}_repository_port.py"; \
			echo "" >> "libs/$$domain/adapters/$${domain}_repository_port.py"; \
			echo "class $$(echo $$domain | sed 's/.*/\u&/')RepositoryPort(ABC):" >> "libs/$$domain/adapters/$${domain}_repository_port.py"; \
			echo "    \"\"\"Port defining $$domain data access contract\"\"\"" >> "libs/$$domain/adapters/$${domain}_repository_port.py"; \
			echo "    " >> "libs/$$domain/adapters/$${domain}_repository_port.py"; \
			echo "    @abstractmethod" >> "libs/$$domain/adapters/$${domain}_repository_port.py"; \
			echo "    async def find_all(self) -> List[$$(echo $$domain | sed 's/.*/\u&/')]:" >> "libs/$$domain/adapters/$${domain}_repository_port.py"; \
			echo "        \"\"\"Find all $${domain}s\"\"\"" >> "libs/$$domain/adapters/$${domain}_repository_port.py"; \
			echo "        pass" >> "libs/$$domain/adapters/$${domain}_repository_port.py"; \
			echo "    " >> "libs/$$domain/adapters/$${domain}_repository_port.py"; \
			echo "    @abstractmethod" >> "libs/$$domain/adapters/$${domain}_repository_port.py"; \
			echo "    async def find_by_id(self, item_id: str) -> Optional[$$(echo $$domain | sed 's/.*/\u&/')]:" >> "libs/$$domain/adapters/$${domain}_repository_port.py"; \
			echo "        \"\"\"Find $$domain by ID\"\"\"" >> "libs/$$domain/adapters/$${domain}_repository_port.py"; \
			echo "        pass" >> "libs/$$domain/adapters/$${domain}_repository_port.py"; \
			echo "    " >> "libs/$$domain/adapters/$${domain}_repository_port.py"; \
			echo "    @abstractmethod" >> "libs/$$domain/adapters/$${domain}_repository_port.py"; \
			echo "    async def save(self, item: $$(echo $$domain | sed 's/.*/\u&/')) -> $$(echo $$domain | sed 's/.*/\u&/'):" >> "libs/$$domain/adapters/$${domain}_repository_port.py"; \
			echo "        \"\"\"Save $$domain\"\"\"" >> "libs/$$domain/adapters/$${domain}_repository_port.py"; \
			echo "        pass" >> "libs/$$domain/adapters/$${domain}_repository_port.py"; \
			echo "    " >> "libs/$$domain/adapters/$${domain}_repository_port.py"; \
			echo "    @abstractmethod" >> "libs/$$domain/adapters/$${domain}_repository_port.py"; \
			echo "    async def delete(self, item_id: str) -> bool:" >> "libs/$$domain/adapters/$${domain}_repository_port.py"; \
			echo "        \"\"\"Delete $$domain by ID\"\"\"" >> "libs/$$domain/adapters/$${domain}_repository_port.py"; \
			echo "        pass" >> "libs/$$domain/adapters/$${domain}_repository_port.py"; \
		fi; \
		if [ ! -f "libs/$$domain/adapters/memory_adapter.py" ]; then \
			echo "\"\"\"" > "libs/$$domain/adapters/memory_adapter.py"; \
			echo "Memory Adapter - In-memory implementation of $$domain repository port" >> "libs/$$domain/adapters/memory_adapter.py"; \
			echo "Useful for testing and development" >> "libs/$$domain/adapters/memory_adapter.py"; \
			echo "\"\"\"" >> "libs/$$domain/adapters/memory_adapter.py"; \
			echo "from typing import List, Optional, Dict" >> "libs/$$domain/adapters/memory_adapter.py"; \
			echo "from .$${domain}_repository_port import $$(echo $$domain | sed 's/.*/\u&/')RepositoryPort" >> "libs/$$domain/adapters/memory_adapter.py"; \
			echo "from ..domain.entities.$${domain} import $$(echo $$domain | sed 's/.*/\u&/')" >> "libs/$$domain/adapters/memory_adapter.py"; \
			echo "" >> "libs/$$domain/adapters/memory_adapter.py"; \
			echo "class Memory$$(echo $$domain | sed 's/.*/\u&/')Adapter($$(echo $$domain | sed 's/.*/\u&/')RepositoryPort):" >> "libs/$$domain/adapters/memory_adapter.py"; \
			echo "    \"\"\"In-memory implementation of $$domain repository\"\"\"" >> "libs/$$domain/adapters/memory_adapter.py"; \
			echo "    " >> "libs/$$domain/adapters/memory_adapter.py"; \
			echo "    def __init__(self):" >> "libs/$$domain/adapters/memory_adapter.py"; \
			echo "        self._data: Dict[str, $$(echo $$domain | sed 's/.*/\u&/')] = {}" >> "libs/$$domain/adapters/memory_adapter.py"; \
			echo "    " >> "libs/$$domain/adapters/memory_adapter.py"; \
			echo "    async def find_all(self) -> List[$$(echo $$domain | sed 's/.*/\u&/')]:" >> "libs/$$domain/adapters/memory_adapter.py"; \
			echo "        \"\"\"Fetch all $${domain}s from memory\"\"\"" >> "libs/$$domain/adapters/memory_adapter.py"; \
			echo "        return list(self._data.values())" >> "libs/$$domain/adapters/memory_adapter.py"; \
			echo "    " >> "libs/$$domain/adapters/memory_adapter.py"; \
			echo "    async def find_by_id(self, item_id: str) -> Optional[$$(echo $$domain | sed 's/.*/\u&/')]:" >> "libs/$$domain/adapters/memory_adapter.py"; \
			echo "        \"\"\"Find $$domain by ID\"\"\"" >> "libs/$$domain/adapters/memory_adapter.py"; \
			echo "        return self._data.get(item_id)" >> "libs/$$domain/adapters/memory_adapter.py"; \
			echo "    " >> "libs/$$domain/adapters/memory_adapter.py"; \
			echo "    async def save(self, item: $$(echo $$domain | sed 's/.*/\u&/')) -> $$(echo $$domain | sed 's/.*/\u&/'):" >> "libs/$$domain/adapters/memory_adapter.py"; \
			echo "        \"\"\"Save $$domain to memory\"\"\"" >> "libs/$$domain/adapters/memory_adapter.py"; \
			echo "        self._data[item.id] = item" >> "libs/$$domain/adapters/memory_adapter.py"; \
			echo "        return item" >> "libs/$$domain/adapters/memory_adapter.py"; \
			echo "    " >> "libs/$$domain/adapters/memory_adapter.py"; \
			echo "    async def delete(self, item_id: str) -> bool:" >> "libs/$$domain/adapters/memory_adapter.py"; \
			echo "        \"\"\"Delete $$domain by ID\"\"\"" >> "libs/$$domain/adapters/memory_adapter.py"; \
			echo "        if item_id in self._data:" >> "libs/$$domain/adapters/memory_adapter.py"; \
			echo "            del self._data[item_id]" >> "libs/$$domain/adapters/memory_adapter.py"; \
			echo "            return True" >> "libs/$$domain/adapters/memory_adapter.py"; \
			echo "        return False" >> "libs/$$domain/adapters/memory_adapter.py"; \
		fi; \
		if [ ! -f "libs/$$domain/project.json" ]; then \
			echo "{ \"name\": \"$$domain\", \"root\": \"libs/$$domain\", \"projectType\": \"library\", \"tags\": [\"scope:$$domain\", \"type:domain\", \"layer:hexagonal\"] }" > "libs/$$domain/project.json"; \
		fi; \
	done

# Create infrastructure and tooling
scaffold-infrastructure:
	@echo "Creating infrastructure and tooling..."
	@if [ ! -d "docker" ]; then mkdir docker; fi
	@if [ ! -d "tools" ]; then mkdir tools; fi
	@if [ ! -f "docker/Dockerfile" ]; then \
		echo "# Multi-stage Python container for hexagonal architecture" > "docker/Dockerfile"; \
		echo "FROM python:3.11-slim as base" >> "docker/Dockerfile"; \
		echo "WORKDIR /app" >> "docker/Dockerfile"; \
		echo "COPY pyproject.toml uv.lock ./" >> "docker/Dockerfile"; \
		echo "RUN pip install uv && uv sync --frozen" >> "docker/Dockerfile"; \
		echo "COPY . ." >> "docker/Dockerfile"; \
		echo "EXPOSE 8000" >> "docker/Dockerfile"; \
		echo "CMD [\"python\", \"-m\", \"uvicorn\", \"src.main:app\", \"--host\", \"0.0.0.0\", \"--port\", \"8000\"]" >> "docker/Dockerfile"; \
	fi
	@if [ ! -f "docker/docker-compose.yml" ]; then \
		echo "version: \"3.8\"" > "docker/docker-compose.yml"; \
		echo "services:" >> "docker/docker-compose.yml"; \
		echo "  app:" >> "docker/docker-compose.yml"; \
		echo "    build: ." >> "docker/docker-compose.yml"; \
		echo "    ports:" >> "docker/docker-compose.yml"; \
		echo "      - \"8000:8000\"" >> "docker/docker-compose.yml"; \
		echo "    environment:" >> "docker/docker-compose.yml"; \
		echo "      - ENV=development" >> "docker/docker-compose.yml"; \
		echo "    volumes:" >> "docker/docker-compose.yml"; \
		echo "      - .:/app" >> "docker/docker-compose.yml"; \
	fi

# Clean up generated scaffolding (use with caution!)
clean-scaffold:
	@echo "⚠️  Deleting generated hexagonal architecture folders..."
	@echo "This will remove: apps/, libs/, tools/, docker/"
	@read -p "Are you sure? (y/N): " -n 1 -r; \
	echo; \
	if [[ $$REPLY =~ ^[Yy]$$ ]]; then \
		rm -rf apps libs docker; \
		echo "🧹 Hexagonal architecture scaffold cleaned."; \
	else \
		echo "❌ Operation cancelled."; \
	fi

# Pretty-print current workspace tree structure
tree:
	@echo ""
	@echo "📂 Current Workspace Structure"
	@echo "==============================="
	@if command -v tree >/dev/null 2>&1; then \
		tree -I 'node_modules|.git|.nx|__pycache__|*.pyc|.pytest_cache|dist' -L 4; \
	else \
		find . -maxdepth 4 -type d 2>/dev/null \
		| grep -E -v '\.(git|nx)|node_modules|__pycache__|\.pytest_cache|dist' \
		| sort | sed 's/[^-][^\/]*\//   |/g;s/|\([^ ]\)/|-- \1/'; \
	fi
	@echo ""

docker/Dockerfile:
	@mkdir -p docker
	@if [ ! -f "$@" ]; then \
		echo "# Multi-stage Python container for hexagonal architecture" > "$@"; \
		echo "FROM python:3.11-slim as base" >> "$@"; \
		echo "WORKDIR /app" >> "$@"; \
		echo "COPY pyproject.toml uv.lock ./" >> "$@"; \
		echo "RUN pip install uv && uv sync --frozen" >> "$@"; \
		echo "COPY . ." >> "$@"; \
		echo "EXPOSE 8000" >> "$@"; \
		echo "CMD [\"python\", \"-m\", \"uvicorn\", \"src.main:app\", \"--host\", \"0.0.0.0\", \"--port\", \"8000\"]" >> "$@"; \
	fi

docker/docker-compose.yml:
	@mkdir -p docker
	@if [ ! -f "$@" ]; then \
		echo "version: \"3.8\"" > "$@"; \
		echo "services:" >> "$@"; \
		echo "  app:" >> "$@"; \
		echo "    build: ." >> "$@"; \
		echo "    ports:" >> "$@"; \
		echo "      - \"8000:8000\"" >> "$@"; \
		echo "    environment:" >> "$@"; \
		echo "      - ENV=development" >> "$@"; \
		echo "    volumes:" >> "$@"; \
		echo "      - .:/app" >> "$@"; \
	fi

# ==============================================================================
# Enhanced domain-based project generation
# ==============================================================================

domain-lib:
	@if [ -z "$(DOMAIN)" ] || [ -z "$(NAME)" ]; then \
		echo "Usage: make domain-lib DOMAIN=<domain> NAME=<name> [TYPE=application|core|infrastructure|shared] [TAGS=additional,tags]"; \
		exit 1; \
	fi
	pnpm nx g domain-lib $(DOMAIN) $(NAME) $(if $(TYPE),--type=$(TYPE)) $(if $(TAGS),--tags=$(TAGS))

# Batch generate libraries for multiple domains
batch-domains:
	@if [ -z "$(DOMAINS)" ]; then \
		echo "Usage: make batch-domains DOMAINS=allocation,payments,invoicing [TYPE=application] [SUFFIX=service]"; \
		exit 1; \
	fi
	pnpm nx g batch-domains $(DOMAINS) $(if $(TYPE),--type=$(TYPE)) $(if $(SUFFIX),--suffix=$(SUFFIX))

# Domain-specific shortcuts
allocation-stack:
	@echo "Creating allocation domain stack..."
	$(MAKE) domain-lib DOMAIN=allocation NAME=api TYPE=application
	$(MAKE) domain-lib DOMAIN=allocation NAME=models TYPE=core
	$(MAKE) domain-lib DOMAIN=allocation NAME=database TYPE=infrastructure

payments-stack:
	@echo "Creating payments domain stack..."
	$(MAKE) domain-lib DOMAIN=payments NAME=api TYPE=application
	$(MAKE) domain-lib DOMAIN=payments NAME=models TYPE=core
	$(MAKE) domain-lib DOMAIN=payments NAME=gateway TYPE=infrastructure

# Generate full microservice stack for a domain
domain-stack:
	@if [ -z "$(DOMAIN)" ]; then \
		echo "Usage: make domain-stack DOMAIN=<domain>"; \
		exit 1; \
	fi
	@echo "Creating full stack for $(DOMAIN) domain..."
	$(MAKE) domain-lib DOMAIN=$(DOMAIN) NAME=api TYPE=application TAGS=layer:api
	$(MAKE) domain-lib DOMAIN=$(DOMAIN) NAME=models TYPE=core TAGS=layer:domain
	$(MAKE) domain-lib DOMAIN=$(DOMAIN) NAME=database TYPE=infrastructure TAGS=layer:data
	$(MAKE) domain-lib DOMAIN=$(DOMAIN) NAME=shared TYPE=shared TAGS=layer:shared

# List projects by domain
list-domain:
	@if [ -z "$(DOMAIN)" ]; then \
		echo "Usage: make list-domain DOMAIN=<domain>"; \
		exit 1; \
	fi
	@echo "Projects in $(DOMAIN) domain:"
	@if command -v jq >/dev/null 2>&1; then \
		pnpm nx show projects --json 2>/dev/null | jq -r '.[] | select(test("^$(DOMAIN)-"))' | sort 2>/dev/null || true; \
	fi
	@find libs apps -name "$(DOMAIN)-*" -type d 2>/dev/null | sed 's|.*/||g' | sort || echo "No projects found for domain: $(DOMAIN)"

# Run tasks by domain scope
lint-domain:
	@if [ -z "$(DOMAIN)" ]; then \
		echo "Usage: make lint-domain DOMAIN=<domain>"; \
		exit 1; \
	fi
	@echo "Running lint for $(DOMAIN) domain..."
	@if pnpm nx run-many --target=lint --projects=tag:scope:$(DOMAIN) 2>/dev/null; then \
		echo "✅ Lint completed for $(DOMAIN) domain"; \
	else \
		echo "⚠️  No projects found with scope:$(DOMAIN) tag. Try 'make list-domain DOMAIN=$(DOMAIN)' to see available projects."; \
	fi

test-domain:
	@if [ -z "$(DOMAIN)" ]; then \
		echo "Usage: make test-domain DOMAIN=<domain>"; \
		exit 1; \
	fi
	@echo "Running tests for $(DOMAIN) domain..."
	@if pnpm nx run-many --target=test --projects=tag:scope:$(DOMAIN) 2>/dev/null; then \
		echo "✅ Tests completed for $(DOMAIN) domain"; \
	else \
		echo "⚠️  No projects found with scope:$(DOMAIN) tag. Try 'make list-domain DOMAIN=$(DOMAIN)' to see available projects."; \
	fi

build-domain:
	@if [ -z "$(DOMAIN)" ]; then \
		echo "Usage: make build-domain DOMAIN=<domain>"; \
		exit 1; \
	fi
	@echo "Building $(DOMAIN) domain..."
	@if pnpm nx run-many --target=build --projects=tag:scope:$(DOMAIN) 2>/dev/null; then \
		echo "✅ Build completed for $(DOMAIN) domain"; \
	else \
		echo "⚠️  No projects found with scope:$(DOMAIN) tag. Try 'make list-domain DOMAIN=$(DOMAIN)' to see available projects."; \
	fi

# Graph visualization by domain
graph-domain:
	@if [ -z "$(DOMAIN)" ]; then \
		echo "Usage: make graph-domain DOMAIN=<domain>"; \
		exit 1; \
	fi
	@echo "Opening dependency graph for $(DOMAIN) domain..."
	@if ! pnpm nx graph --focus=tag:scope:$(DOMAIN) 2>/dev/null; then \
		echo "⚠️  No projects found with scope:$(DOMAIN) tag. Opening full graph..."; \
		pnpm nx graph; \
	fi

# Help for domain commands
help-domain:
	@echo "🎯 Domain-Driven Development Commands:"
	@echo ""
	@echo "  make domain-lib DOMAIN=<domain> NAME=<name> [TYPE=application|core|infrastructure|shared] [TAGS=extra,tags]"
	@echo "    Create a single library within a domain"
	@echo ""
	@echo "  make batch-domains DOMAINS=allocation,payments,invoicing [TYPE=application] [SUFFIX=service]"
	@echo "    Create libraries for multiple domains at once"
	@echo ""
	@echo "  make domain-stack DOMAIN=<domain>"
	@echo "    Create full microservice stack (api, models, database, shared) for a domain"
	@echo ""
	@echo "  make allocation-stack | payments-stack"
	@echo "    Pre-configured domain stacks"
	@echo ""
	@echo "  make list-domain DOMAIN=<domain>"
	@echo "    List all projects within a domain"
	@echo ""
	@echo "  make lint-domain|test-domain|build-domain DOMAIN=<domain>"
	@echo "    Run tasks for all projects in a domain"
	@echo ""
	@echo "  make graph-domain DOMAIN=<domain>"
	@echo "    Visualize dependency graph for a domain"
	@echo ""
	@echo "  make scaffold"
	@echo "    Generate complete hexagonal architecture workspace with configured APPS and DOMAINS"
	@echo ""
	@echo "  make clean-scaffold"
	@echo "    Delete generated hexagonal architecture structure (use with caution!)"
	@echo ""
	@echo "  make tree"
	@echo "    Display current workspace structure"
