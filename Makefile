# ╔═══════════════════════════════════════════════════════════════╗
# ║                AI-Native Monorepo Orchestration               ║
# ║  Hexagonal/DDD Nx workspace with Python, ML, and Cloud       ║
# ║  Built for streamlined one-person dev workflow               ║
# ║  🔄 Reversible Microservice Architecture Support             ║
# ╚═══════════════════════════════════════════════════════════════╝

# Shell configuration for better error handling and consistency
SHELL := /bin/bash
.ONESHELL:
.DEFAULT_GOAL := help

# Tool shortcuts and defaults
NX ?= npx nx
CTX ?=                                      # Context name for DDD operations
PROJECT ?=                                  # Project name for operations
TARGET ?=                                   # Target name for infrastructure
PLAYBOOK ?=                                 # Ansible playbook name
HOSTS ?=                                    # Ansible hosts
PCT ?=                                      # Percentage for canary deployments
TRANSPORT ?= fastapi                        # Transport layer for microservices
NAMESPACE ?= default                        # Kubernetes namespace
SCALE_TARGET ?= 70                          # HPA CPU target percentage

# ==============================================================================
# Environment Variable Validation Utility
# ==============================================================================
define need
  @: "$$${$(1)?}" || (echo "❌ env $(1) missing" && exit 1)
endef

# ==============================================================================
# Configuration Variables - Adjust as needed
# ==============================================================================
PYTHON_VERSION ?= 3.11.9
NX_PYTHON_PLUGIN_VERSION ?= 21.0.3
RUST_TOOLCHAIN_UV_INSTALL ?= false
CUSTOM_PY_GEN_PLUGIN_NAME ?= shared-python-tools
CUSTOM_PY_APP_GENERATOR ?= $(CUSTOM_PY_GEN_PLUGIN_NAME):shared-python-app
CUSTOM_PY_LIB_GENERATOR ?= $(CUSTOM_PY_GEN_PLUGIN_NAME):shared-python-lib

# Service Architecture Configuration
SERVICE_GENERATOR ?= @org/context-to-service
SERVICE_REMOVER ?= @org/remove-service-shell
CONTAINER_REGISTRY ?= ghcr.io/your-org
SERVICE_BASE_PORT ?= 8000

# Hexagonal Architecture Scaffolding Configuration
APPS ?=
DOMAINS ?=

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
SCAFFOLD_ROOT_DIRS  := tools docker k8s
SCAFFOLD_ROOT_FILES := docker/Dockerfile docker/docker-compose.yml k8s/namespace.yaml

# ==============================================================================
# Help System - Auto-generated from target comments
# ==============================================================================

help: ## Show this help menu
	@echo "Available targets:"
	@grep -E '^[a-zA-Z0-9_-]+:.*?##' $(MAKEFILE_LIST) | sed 's/:.*##/:/' | sed 's/##/ - /'
	@echo ""
	@echo "🔄 Service Architecture Examples:"
	@echo "  make service-split CTX=accounting TRANSPORT=fastapi"
	@echo "  make service-merge CTX=accounting"
	@echo "  make deploy-services"
	@echo "  make scale-service CTX=accounting REPLICAS=3"
	@echo ""
	@echo "🏗️ Development Examples:"
	@echo "  make context-new CTX=orders      # Create DDD context"
	@echo "  make train                       # Train ML models"
	@echo "  make ci                          # Run CI pipeline"

# ==============================================================================
# Initial Setup and Environment Management
# ==============================================================================

setup: init-nx init-python-env install-custom-py-generator install-service-generators install-pre-commit ## Initial one-time setup of the monorepo
	@echo "🚀 Monorepo setup complete! Run 'make help' for available commands."

init-nx: ## Initialize Nx workspace
	@python scripts/setup.py init_nx --nx-python-plugin-version=$(NX_PYTHON_PLUGIN_VERSION)

init-python-env: ## Initialize/update Python environment (.venv)
	@python scripts/setup.py init_python_env --python-version=$(PYTHON_VERSION) --rust-toolchain-uv-install=$(RUST_TOOLCHAIN_UV_INSTALL) --root-pyproject-toml=$(ROOT_PYPROJECT_TOML) --monorepo-root=$(MONOREPO_ROOT)

install-custom-py-generator: ## Install custom Python generators
	@bash ./.make_assets/setup_helper.sh install_custom_py_generator $(CUSTOM_PY_GEN_PLUGIN_NAME)

install-service-generators: ## Install service architecture generators
	@echo "🔧 Installing service architecture generators..."
	@pnpm install @org/nx-service-generators || echo "⚠️  Service generators not yet available, will use built-in implementations"

install-pre-commit: ## Install git pre-commit hooks
	@python scripts/setup.py install_pre_commit

# ==============================================================================
# Project Generation - Apps, Libraries, and DDD Contexts
# ==============================================================================

app: ## Generate Python application NAME=<name>
	$(call need,NAME)
	@echo "✨ Generating Python application '$(NAME)' with custom settings..."
	pnpm nx generate $(CUSTOM_PY_APP_GENERATOR) $(NAME) --directory=apps
	@echo "Installing project-specific Python dependencies for $(NAME)..."
	pnpm nx run $(NAME):install-deps
	@echo "🎉 Python application '$(NAME)' generated and dependencies installed successfully."

lib: ## Generate Python library NAME=<name>
	$(call need,NAME)
	@echo "✨ Generating Python library '$(NAME)' with custom settings..."
	pnpm nx generate $(CUSTOM_PY_LIB_GENERATOR) $(NAME) --directory=libs
	@echo "Installing project-specific Python dependencies for $(NAME)..."
	pnpm nx run $(NAME):install-deps
	@echo "🎉 Python library '$(NAME)' generated and dependencies installed successfully."

context-new: ## Create DDD context with hexagonal architecture CTX=<name>
	$(call need,CTX)
	@echo "🏛️ Creating DDD context '$(CTX)' with hexagonal architecture..."
	@echo "📦 Creating domain layer..."
	$(NX) g lib $(CTX) --directory=libs/$(CTX)/domain --tags=context:$(CTX),layer:domain,deployable:false
	@echo "⚙️ Creating application layer..."
	$(NX) g lib $(CTX) --directory=libs/$(CTX)/application --tags=context:$(CTX),layer:application,deployable:false
	@echo "🔌 Creating infrastructure layer..."
	$(NX) g lib $(CTX) --directory=libs/$(CTX)/infrastructure --tags=context:$(CTX),layer:infrastructure,deployable:false
	@echo "✅ Context $(CTX) created with hexagonal architecture and deployable:false tags."
	@echo "💡 Use 'make service-split CTX=$(CTX)' to extract as microservice when needed."

# ==============================================================================
# 🔄 Reversible Microservice Architecture Management
# ==============================================================================

service-split: ## Extract context to microservice CTX=<name> [TRANSPORT=fastapi|grpc|kafka]
	$(call need,CTX)
	@echo "🔧 Extracting context '$(CTX)' to microservice with $(TRANSPORT) transport..."
	@echo "📋 Checking if context exists..."
	@if [ ! -d "libs/$(CTX)" ]; then \
		echo "❌ Context $(CTX) not found. Run 'make context-new CTX=$(CTX)' first."; \
		exit 1; \
	fi
	@echo "🏗️ Creating microservice application structure..."
	@$(MAKE) -s create-service-app CTX=$(CTX) TRANSPORT=$(TRANSPORT)
	@echo "🐳 Generating container configuration..."
	@$(MAKE) -s create-service-container CTX=$(CTX)
	@echo "☸️ Generating Kubernetes manifests..."
	@$(MAKE) -s create-service-k8s CTX=$(CTX)
	@echo "🏷️ Updating deployment tags..."
	@$(MAKE) -s update-service-tags CTX=$(CTX) DEPLOYABLE=true
	@echo "✅ Context $(CTX) extracted to microservice at apps/$(CTX)-svc/"
	@echo "💡 Deploy with: make deploy-service CTX=$(CTX)"

service-merge: ## Merge microservice back to monolith CTX=<name>
	$(call need,CTX)
	@echo "🔄 Merging microservice '$(CTX)' back to monolith..."
	@echo "📋 Checking if service exists..."
	@if [ ! -d "apps/$(CTX)-svc" ]; then \
		echo "❌ Service $(CTX)-svc not found. Nothing to merge."; \
		exit 1; \
	fi
	@echo "🗑️ Removing service application..."
	@rm -rf "apps/$(CTX)-svc"
	@echo "🏷️ Updating deployment tags..."
	@$(MAKE) -s update-service-tags CTX=$(CTX) DEPLOYABLE=false
	@echo "✅ Service $(CTX) merged back to monolith."
	@echo "💡 Context libs/$(CTX) remains unchanged - zero code impact!"

service-status: ## Show deployment status of all contexts
	@echo "📊 Context Deployment Status:"
	@echo "════════════════════════════════════════════════════════════════"
	@for ctx_dir in libs/*/; do \
		if [ -d "$ctx_dir" ]; then \
			ctx=$(basename "$ctx_dir"); \
			if [ -f "$ctx_dir/project.json" ]; then \
				deployable=$(grep -o '"deployable:[^"]*"' "$ctx_dir/project.json" | cut -d: -f2 | tr -d '"' || echo "false"); \
				service_exists="❌"; \
				if [ -d "apps/$ctx-svc" ]; then service_exists="✅"; fi; \
				printf "  %-20s deployable:%-8s service:%-3s\n" "$ctx" "$deployable" "$service_exists"; \
			fi; \
		fi; \
	done
	@echo "════════════════════════════════════════════════════════════════"

service-list: ## List all deployable services
	@echo "🚀 Deployable Services:"
	@$(NX) show projects --json 2>/dev/null | jq -r '.[] | select(test("-svc$"))' | sort || find apps -name "*-svc" -type d | sed 's|apps/||g' | sort

# ==============================================================================
# AI/ML Model Lifecycle Management
# ==============================================================================

model-new: ## Generate new ML model library CTX=<name>
	$(call need,CTX)
	@echo "🤖 Creating ML model library '$(CTX)'..."
	$(NX) g lib $(CTX) --directory=libs/models --tags=context:$(CTX),type:model,deployable:false
	@echo "✅ ML model library $(CTX) created."

train: ## Train all affected ML models
	@echo "🧠 Training affected ML models..."
	$(NX) affected --target=train --parallel

evaluate: ## Evaluate affected ML models
	@echo "📊 Evaluating affected ML models..."
	$(NX) affected --target=evaluate --parallel

register: ## Register affected models in model registry
	@echo "📝 Registering affected models..."
	$(NX) affected --target=register --parallel

promote: ## Promote model to environment CTX=<name> CH=<candidate|production>
	$(call need,CTX)
	$(call need,CH)
	@echo "🚀 Promoting model $(CTX) to $(CH)..."
	$(NX) run libs/models/$(CTX):promote --to=$(CH)

canary: ## Canary deploy API with traffic percentage PCT=<5|25|50|100>
	$(call need,PCT)
	@echo "🐦 Canary deploying API with $(PCT)% traffic..."
	$(NX) run apps/api:deploy --percent $(PCT)

# ==============================================================================
# Development Workflow - Quality Gates and CI/CD
# ==============================================================================

dev: ## Start affected apps in development mode with watch
	@echo "🚀 Starting development servers..."
	$(NX) run-many --target=serve --all --parallel

ci: ## Run complete CI pipeline with service filtering
	@echo "🔄 Running CI pipeline..."
	@echo "📝 Formatting check..."
	$(NX) format:check
	@echo "🔍 Linting affected projects..."
	$(NX) affected -t lint --parallel=3
	@echo "🧪 Testing affected projects..."
	$(NX) affected -t test --parallel=3
	@echo "🧪 Running e2e tests..."
	$(MAKE) e2e-test
	@echo "📦 Building affected projects..."
	$(NX) affected -t build --parallel=3
	@echo "🐳 Building deployable services..."
	@$(MAKE) -s build-services
	@echo "✅ CI pipeline completed successfully!"

ci-services: ## Run CI only for deployable services
	@echo "🔄 Running CI pipeline for deployable services..."
	$(NX) affected --target=lint,test,build --projects="tag:deployable:true" --parallel=3

build-services: ## Build all deployable services
	@echo "🐳 Building deployable services..."
	@if $(NX) show projects --json 2>/dev/null | jq -r '.[] | select(test("-svc$"))' | head -1 > /dev/null 2>&1; then \
		$(NX) run-many --target=build --projects="tag:deployable:true" --parallel=3; \
		echo "✅ All deployable services built successfully!"; \
	else \
		echo "ℹ️  No deployable services found. Use 'make service-split CTX=<name>' to create some."; \
	fi

lint: ## Lint all affected projects
	@echo "🔎 Linting affected projects..."
	$(NX) affected --target=lint --base=main --parallel=3

test: ## Run tests for all affected projects
	@echo "🧪 Running tests for affected projects..."
	$(NX) affected --target=test --base=main --parallel=3

e2e-test: ## Run e2e tests
	@echo "🧪 Running e2e tests for vector-db..."
	$(NX) e2e e2e-vector-db

build: ## Build all affected projects
	@echo "📦 Building affected projects..."
	$(NX) affected --target=build --base=main --parallel=3

serve: ## Serve specific application PROJECT=<name>
	$(call need,PROJECT)
	@echo "🚀 Serving '$(PROJECT)'..."
	$(NX) serve $(PROJECT)

graph: ## Open Nx dependency graph visualizer
	@echo "📊 Opening Nx dependency graph..."
	$(NX) graph

# ==============================================================================
# 🐳 Container and Kubernetes Management
# ==============================================================================

containerize: ## Build Docker image for project PROJECT=<name>
	$(call need,PROJECT)
	@echo "🐳 Building Docker image for '$(PROJECT)'..."
	$(NX) run $(PROJECT):container
	@echo "✅ Docker image for '$(PROJECT)' built successfully."

build-service-images: ## Build Docker images for all deployable services
	@echo "🐳 Building Docker images for all deployable services..."
	@for svc in $(find apps -name "*-svc" -type d | sed 's|apps/||g'); do \
		echo "🔨 Building image for $svc..."; \
		$(NX) run $svc:docker || echo "⚠️  Failed to build $svc"; \
	done


deploy-service: ## Deploy specific service to Kubernetes CTX=<name>
	$(call need,CTX)
	@echo "🚀 Deploying service $(CTX) to Kubernetes..."
	@if [ ! -d "apps/$(CTX)-svc" ]; then \
		echo "❌ Service $(CTX)-svc not found. Run 'make service-split CTX=$(CTX)' first."; \
		exit 1; \
	fi
	@echo "🐳 Building service image..."
	$(NX) run $(CTX)-svc:docker
	@echo "☸️ Applying Kubernetes manifests..."
	kubectl apply -f apps/$(CTX)-svc/k8s/ --namespace=$(NAMESPACE)
	@echo "✅ Service $(CTX) deployed successfully!"

deploy-services: ## Deploy all deployable services to Kubernetes
	@echo "🚀 Deploying all deployable services to Kubernetes..."
	@for svc in $(find apps -name "*-svc" -type d | sed 's|apps/||g'); do \
		echo "🚀 Deploying $svc..."; \
		$(MAKE) -s deploy-service CTX=${svc%-svc} || echo "⚠️  Failed to deploy $svc"; \
	done

scale-service: ## Scale service replicas CTX=<name> REPLICAS=<number>
	$(call need,CTX)
	$(call need,REPLICAS)
	@echo "📈 Scaling service $(CTX) to $(REPLICAS) replicas..."
	kubectl scale deployment $(CTX)-svc --replicas=$(REPLICAS) --namespace=$(NAMESPACE)
	@echo "✅ Service $(CTX) scaled to $(REPLICAS) replicas."

service-logs: ## View service logs CTX=<name>
	$(call need,CTX)
	@echo "📄 Viewing logs for service $(CTX)..."
	kubectl logs -l app=$(CTX)-svc --namespace=$(NAMESPACE) --tail=100 -f

# ==============================================================================
# Infrastructure as Code (IaC) - Terraform, Ansible, and Cloud
# ==============================================================================

infra-plan: ## Run terraform plan TARGET=<name>
	$(call need,TARGET)
	@echo "🗺️ Running IaC plan for '$(TARGET)'..."
	$(NX) run infrastructure:plan-$(TARGET)

infra-apply: ## Apply terraform changes TARGET=<name>
	$(call need,TARGET)
	@echo "🚀 Applying IaC changes for '$(TARGET)'..."
	$(NX) run infrastructure:apply-$(TARGET)

ansible-run: ## Run Ansible playbook PLAYBOOK=<name> HOSTS=<hosts>
	$(call need,PLAYBOOK)
	@echo "⚙️ Running Ansible playbook '$(PLAYBOOK)' on hosts '$(HOSTS)'..."
	$(NX) run ansible-playbooks:run-$(PLAYBOOK) --args="--inventory $(HOSTS)"

# ==============================================================================
# Workspace Management and Diagnostics
# ==============================================================================

cache-clear: ## Clear Nx cache
	@echo "🧹 Clearing Nx cache..."
	$(NX) reset

doctor: ## Verify workspace constraints and generate dependency graph
	@echo "🩺 Running workspace diagnostics..."
	$(NX) graph --file=diag.html && echo "📊 Dependency graph saved to diag.html"
	@echo "📋 Checking service architecture integrity..."
	@$(MAKE) -s service-status

tree: ## Pretty-print current workspace layout
	@echo "📁 Current workspace structure:"
	@if command -v tree >/dev/null 2>&1; then \
		tree -I 'node_modules|__pycache__|*.pyc|.pytest_cache|.nx|dist' -L 3; \
	else \
		find . -type d -name 'node_modules' -prune -o -type d -name '__pycache__' -prune -o -type d -name '.nx' -prune -o -type d -name 'dist' -prune -o -type d -print | head -50; \
	fi

clean: ## Clean build artifacts and caches (use with caution)
	@echo "🗑️ Cleaning Nx cache, node_modules, and Python environments..."
	$(NX) reset
	rm -rf node_modules .venv
	find . -name ".nx" -type d -exec rm -rf {} + 2>/dev/null || true
	find . -name "dist" -type d -exec rm -rf {} + 2>/dev/null || true
	find . -name "__pycache__" -type d -exec rm -rf {} + 2>/dev/null || true
	find . -name "*.pyc" -delete 2>/dev/null || true
	find . -name ".pytest_cache" -type d -exec rm -rf {} + 2>/dev/null || true
	@echo "✅ Cleanup complete. You may need to run 'make setup' again."

# ==============================================================================
# 🔧 Internal Service Management Helpers
# ==============================================================================

create-service-app: ## Internal: Create service application structure
	@echo "🏗️ Creating service application for $(CTX)..."
	@mkdir -p "apps/$(CTX)-svc/src"
	@echo """" > "apps/$(CTX)-svc/src/main.py"
	@echo "$(CTX) Microservice - Auto-generated service wrapper" >> "apps/$(CTX)-svc/src/main.py"
	@echo "Exposes libs/$(CTX) domain logic via $(TRANSPORT) transport" >> "apps/$(CTX)-svc/src/main.py"
	@echo """" >> "apps/$(CTX)-svc/src/main.py"
	@if [ "$(TRANSPORT)" = "fastapi" ]; then \
		echo "from fastapi import FastAPI, Depends" >> "apps/$(CTX)-svc/src/main.py"; \
		echo "from libs.$(CTX).application.$(CTX)_service import $(shell echo $(CTX) | sed 's/.*/\u&/')Service" >> "apps/$(CTX)-svc/src/main.py"; \
		echo "from libs.$(CTX).adapters.memory_adapter import Memory$(shell echo $(CTX) | sed 's/.*/\u&/')Adapter" >> "apps/$(CTX)-svc/src/main.py"; \
		echo "" >> "apps/$(CTX)-svc/src/main.py"; \
		echo "app = FastAPI(" >> "apps/$(CTX)-svc/src/main.py"; \
		echo "    title=\"$(shell echo $(CTX) | sed 's/.*/\u&/') Service\"," >> "apps/$(CTX)-svc/src/main.py"; \
		echo "    description=\"Microservice for $(CTX) domain\"," >> "apps/$(CTX)-svc/src/main.py"; \
		echo "    version=\"1.0.0\"" >> "apps/$(CTX)-svc/src/main.py"; \
		echo ")" >> "apps/$(CTX)-svc/src/main.py"; \
		echo "" >> "apps/$(CTX)-svc/src/main.py"; \
		echo "def get_service():" >> "apps/$(CTX)-svc/src/main.py"; \
		echo "    repository = Memory$(shell echo $(CTX) | sed 's/.*/\u&/')Adapter()" >> "apps/$(CTX)-svc/src/main.py"; \
		echo "    return $(shell echo $(CTX) | sed 's/.*/\u&/')Service(repository)" >> "apps/$(CTX)-svc/src/main.py"; \
		echo "" >> "apps/$(CTX)-svc/src/main.py"; \
		echo "@app.get(\"/health\")" >> "apps/$(CTX)-svc/src/main.py"; \
		echo "def health_check():" >> "apps/$(CTX)-svc/src/main.py"; \
		echo "    return {\"status\": \"healthy\", \"service\": \"$(CTX)\"}" >> "apps/$(CTX)-svc/src/main.py"; \
		echo "" >> "apps/$(CTX)-svc/src/main.py"; \
		echo "@app.get(\"/$(CTX)\")" >> "apps/$(CTX)-svc/src/main.py"; \
		echo "async def list_items(service: $(shell echo $(CTX) | sed 's/.*/\u&/')Service = Depends(get_service)))" >> "apps/$(CTX)-svc/src/main.py"; \
		echo "    return await service.get_all()" >> "apps/$(CTX)-svc/src/main.py"; \
		echo "" >> "apps/$(CTX)-svc/src/main.py"; \
		echo "if __name__ == \"__main__\":" >> "apps/$(CTX)-svc/src/main.py"; \
		echo "    import uvicorn" >> "apps/$(CTX)-svc/src/main.py"; \
		echo "    uvicorn.run(app, host=\"0.0.0.0\", port=8000)" >> "apps/$(CTX)-svc/src/main.py"; \
	fi
	@echo "{ \"name\": \"$(CTX)-svc\", \"root\": \"apps/$(CTX)-svc\", \"projectType\": \"application\", \"tags\": [\"context:$(CTX)\", \"type:service\", \"deployable:true\"], \"targets\": { \"serve\": { \"executor\": \"@nx/python:run\", \"options\": { \"module\": \"src.main\" } }, \"docker\": { \"executor\": \"@nx/docker:build\", \"options\": { \"context\": \"apps/$(CTX)-svc\", \"dockerfile\": \"apps/$(CTX)-svc/Dockerfile\" } } } }" > "apps/$(CTX)-svc/project.json"

create-service-container: ## Internal: Create Docker configuration for service
	@echo "🐳 Creating Docker configuration for $(CTX)..."
	@echo "FROM python:3.11-slim" > "apps/$(CTX)-svc/Dockerfile"
	@echo "WORKDIR /app" >> "apps/$(CTX)-svc/Dockerfile"
	@echo "COPY requirements.txt ." >> "apps/$(CTX)-svc/Dockerfile"
	@echo "RUN pip install -r requirements.txt" >> "apps/$(CTX)-svc/Dockerfile"
	@echo "COPY . ." >> "apps/$(CTX)-svc/Dockerfile"
	@echo "EXPOSE 8000" >> "apps/$(CTX)-svc/Dockerfile"
	@echo "CMD [\"python\", \"src/main.py\"]" >> "apps/$(CTX)-svc/Dockerfile"
	@echo "fastapi" > "apps/$(CTX)-svc/requirements.txt"
	@echo "uvicorn" >> "apps/$(CTX)-svc/requirements.txt"

create-service-k8s: ## Internal: Create Kubernetes manifests for service
	@echo "☸️ Creating Kubernetes manifests for $(CTX)..."
	@mkdir -p "apps/$(CTX)-svc/k8s"
	@echo "apiVersion: apps/v1" > "apps/$(CTX)-svc/k8s/deployment.yaml"
	@echo "kind: Deployment" >> "apps/$(CTX)-svc/k8s/deployment.yaml"
	@echo "metadata:" >> "apps/$(CTX)-svc/k8s/deployment.yaml"
	@echo "  name: $(CTX)-svc" >> "apps/$(CTX)-svc/k8s/deployment.yaml"
	@echo "  labels:" >> "apps/$(CTX)-svc/k8s/deployment.yaml"
	@echo "    app: $(CTX)-svc" >> "apps/$(CTX)-svc/k8s/deployment.yaml"
	@echo "spec:" >> "apps/$(CTX)-svc/k8s/deployment.yaml"
	@echo "  replicas: 2" >> "apps/$(CTX)-svc/k8s/deployment.yaml"
	@echo "  selector:" >> "apps/$(CTX)-svc/k8s/deployment.yaml"
	@echo "    matchLabels:" >> "apps/$(CTX)-svc/k8s/deployment.yaml"
	@echo "      app: $(CTX)-svc" >> "apps/$(CTX)-svc/k8s/deployment.yaml"
	@echo "  template:" >> "apps/$(CTX)-svc/k8s/deployment.yaml"
	@echo "    metadata:" >> "apps/$(CTX)-svc/k8s/deployment.yaml"
	@echo "      labels:" >> "apps/$(CTX)-svc/k8s/deployment.yaml"
	@echo "        app: $(CTX)-svc" >> "apps/$(CTX)-svc/k8s/deployment.yaml"
	@echo "    spec:" >> "apps/$(CTX)-svc/k8s/deployment.yaml"
	@echo "      containers:" >> "apps/$(CTX)-svc/k8s/deployment.yaml"
	@echo "      - name: $(CTX)-svc" >> "apps/$(CTX)-svc/k8s/deployment.yaml"
	@echo "        image: $(CONTAINER_REGISTRY)/$(CTX)-svc:latest" >> "apps/$(CTX)-svc/k8s/deployment.yaml"
	@echo "        ports:" >> "apps/$(CTX)-svc/k8s/deployment.yaml"
	@echo "        - containerPort: 8000" >> "apps/$(CTX)-svc/k8s/deployment.yaml"
	@echo "        resources:" >> "apps/$(CTX)-svc/k8s/deployment.yaml"
	@echo "          requests:" >> "apps/$(CTX)-svc/k8s/deployment.yaml"
	@echo "            cpu: 100m" >> "apps/$(CTX)-svc/k8s/deployment.yaml"
	@echo "            memory: 128Mi" >> "apps/$(CTX)-svc/k8s/deployment.yaml"
	@echo "          limits:" >> "apps/$(CTX)-svc/k8s/deployment.yaml"
	@echo "            cpu: 500m" >> "apps/$(CTX)-svc/k8s/deployment.yaml"
	@echo "            memory: 512Mi" >> "apps/$(CTX)-svc/k8s/deployment.yaml"
	@echo "---" >> "apps/$(CTX)-svc/k8s/deployment.yaml"
	@echo "apiVersion: v1" >> "apps/$(CTX)-svc/k8s/deployment.yaml"
	@echo "kind: Service" >> "apps/$(CTX)-svc/k8s/deployment.yaml"
	@echo "metadata:" >> "apps/$(CTX)-svc/k8s/deployment.yaml"
	@echo "  name: $(CTX)-svc" >> "apps/$(CTX)-svc/k8s/deployment.yaml"
	@echo "spec:" >> "apps/$(CTX)-svc/k8s/deployment.yaml"
	@echo "  selector:" >> "apps/$(CTX)-svc/k8s/deployment.yaml"
	@echo "    app: $(CTX)-svc" >> "apps/$(CTX)-svc/k8s/deployment.yaml"
	@echo "  ports:" >> "apps/$(CTX)-svc/k8s/deployment.yaml"
	@echo "  - port: 80" >> "apps/$(CTX)-svc/k8s/deployment.yaml"
	@echo "    targetPort: 8000" >> "apps/$(CTX)-svc/k8s/deployment.yaml"
	@echo "---" >> "apps/$(CTX)-svc/k8s/deployment.yaml"
	@echo "apiVersion: autoscaling/v2" > "apps/$(CTX)-svc/k8s/hpa.yaml"
	@echo "kind: HorizontalPodAutoscaler" >> "apps/$(CTX)-svc/k8s/hpa.yaml"
	@echo "metadata:" >> "apps/$(CTX)-svc/k8s/hpa.yaml"
	@echo "  name: $(CTX)-svc-hpa" >> "apps/$(CTX)-svc/k8s/hpa.yaml"
	@echo "spec:" >> "apps/$(CTX)-svc/k8s/hpa.yaml"
	@echo "  scaleTargetRef:" >> "apps/$(CTX)-svc/k8s/hpa.yaml"
	@echo "    apiVersion: apps/v1" >> "apps/$(CTX)-svc/k8s/hpa.yaml"
	@echo "    kind: Deployment" >> "apps/$(CTX)-svc/k8s/hpa.yaml"
	@echo "    name: $(CTX)-svc" >> "apps/$(CTX)-svc/k8s/hpa.yaml"
	@echo "  minReplicas: 2" >> "apps/$(CTX)-svc/k8s/hpa.yaml"
	@echo "  maxReplicas: 10" >> "apps/$(CTX)-svc/k8s/hpa.yaml"
	@echo "  metrics:" >> "apps/$(CTX)-svc/k8s/hpa.yaml"
	@echo "  - type: Resource" >> "apps/$(CTX)-svc/k8s/hpa.yaml"
	@echo "    resource:" >> "apps/$(CTX)-svc/k8s/hpa.yaml"
	@echo "      name: cpu" >> "apps/$(CTX)-svc/k8s/hpa.yaml"
	@echo "      target:" >> "apps/$(CTX)-svc/k8s/hpa.yaml"
	@echo "        type: Utilization" >> "apps/$(CTX)-svc/k8s/hpa.yaml"
	@echo "        averageUtilization: $(SCALE_TARGET)" >> "apps/$(CTX)-svc/k8s/hpa.yaml"

update-service-tags: ## Internal: Update deployable tags for context
	$(call need,CTX)
	$(call need,DEPLOYABLE)
	@echo "🏷️ Updating deployable tag for $(CTX) to $(DEPLOYABLE)..."
	@if [ -f "libs/$(CTX)/project.json" ]; then \
		if jq 'has("tags")' "libs/$(CTX)/project.json" >/dev/null; then \
			jq '(.tags |= map(select(test("^deployable:")) | "deployable:$(DEPLOYABLE)" // .) + if any(.tags[]; test("^deployable:")) then [] else ["deployable:$(DEPLOYABLE)"] end)' "libs/$(CTX)/project.json" > "libs/$(CTX)/project.json.tmp" && mv "libs/$(CTX)/project.json.tmp" "libs/$(CTX)/project.json"; \
		else \
			jq '.tags = (.tags // []) + ["deployable:$(DEPLOYABLE)"]' "libs/$(CTX)/project.json" > "libs/$(CTX)/project.json.tmp" && mv "libs/$(CTX)/project.json.tmp" "libs/$(CTX)/project.json"; \
		fi; \
		if grep -q '"deployable:$(DEPLOYABLE)"' "libs/$(CTX)/project.json"; then \
			echo "✅ Tag updated."; \
		else \
			echo "❌ Failed to update tag."; exit 1; \
		fi; \
	else \
		echo "❌ libs/$(CTX)/project.json not found."; exit 1; \
	fi

# ==============================================================================
# Supabase Integration
# ==============================================================================

supabase-up: ## Start Supabase local development
	@echo "🚀 Starting Supabase local development..."
	@cd supabase && supabase start

supabase-down: ## Stop Supabase local development
	@echo "🛑 Stopping Supabase local development..."
	@cd supabase && supabase stop

supabase-seed: ## Seed Supabase with test data
	@echo "🌱 Seeding Supabase with test data..."
	@cd supabase && supabase db reset

supabase-open: ## Open Supabase dashboard
	@echo "📊 Opening Supabase dashboard..."
	@cd supabase && supabase dashboard

supabase-lint: ## Lint Supabase SQL files
	@echo "🔍 Linting Supabase SQL files..."
	@cd supabase && supabase db lint

supabase-vector-migrate: ## Run vector database migrations
	@echo "🧭 Running vector database migrations..."
	@cd supabase && supabase db push

supabase-vector-seed: ## Seed vector database
	@echo "🌱 Seeding vector database..."
	@python libs/shared/vector/sqlmodel/seed_vectors.py

supabase-vector-schema: ## Generate vector database schema
	@echo "📋 Generating vector database schema..."
	@$(NX) run shared-vector:generate-schema

# ==============================================================================
# Supabase CLI Integration
# ==============================================================================

SCL=tools/supa_cli/main.py

supa-up: ## Start Supabase with CLI wrapper
	@echo "🚀 Starting Supabase via CLI wrapper..."
	@python $(SCL) up

supa-down: ## Stop Supabase with CLI wrapper
	@echo "🛑 Stopping Supabase via CLI wrapper..."
	@python $(SCL) down

supa-reset: ## Reset Supabase database
	@echo "🔄 Resetting Supabase database..."
	@python $(SCL) reset

supa-seed: ## Seed Supabase via CLI wrapper
	@echo "🌱 Seeding Supabase via CLI wrapper..."
	@python $(SCL) seed

supa-types: ## Generate TypeScript types from Supabase
	@echo "📝 Generating TypeScript types from Supabase..."
	@python $(SCL) types

supa-status: ## Check Supabase status
	@echo "📊 Checking Supabase status..."
	@python $(SCL) status

# ==============================================================================
# AI/ML Development Stack
# ==============================================================================

ai-stack: ## Scaffold AI/ML dependencies for domain CTX=<name>
	$(call need,CTX)
	@echo "🤖 Setting up AI stack for domain $(CTX)..."
	@$(MAKE) model-new CTX=$(CTX)
	@echo "✅ AI stack ready for domain $(CTX)"

env-setup: ## Set up Python environment with AI dependencies
	@echo "🔧 Setting up Python environment with AI dependencies..."
	@python libs/shared-python-tools/env_setup.py

# ==============================================================================
# Observability Stack
# ==============================================================================

observability-local: ## Start local observability stack (Prometheus, Grafana)
	@echo "📊 Starting local observability stack..."
	@docker-compose -f docker/observability-compose.yml up -d

observability-stop: ## Stop local observability stack
	@echo "🛑 Stopping local observability stack..."
	@docker-compose -f docker/observability-compose.yml down

observability-status: ## Check observability stack status
	@echo "📊 Checking observability stack status..."
	@docker-compose -f docker/observability-compose.yml ps

vector-service: ## Start vector database service
	@echo "🧭 Starting vector database service..."
	@$(NX) run shared-vector:serve

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
help-domain: ## Show domain-driven development commands
	@echo "🏛️ Domain-Driven Development Commands:"
	@echo "  make context-new CTX=orders     # Create DDD context"
	@echo "  make domain-stack CTX=orders    # Create full domain stack"
	@echo "  make lint-domain CTX=orders     # Lint domain projects"
	@echo "  make test-domain CTX=orders     # Test domain projects"
	@echo "  make graph-domain CTX=orders    # Show domain dependency graph"

# ==============================================================================
# MECE-Driven Domain Generation
# ==============================================================================

generate-domain: ## Generate domain using MECE principles
	@echo "🧠 Generating domain using MECE principles..."
	@python scripts/generate_domain.py
