# Technology Stack & Build System

## Core Technologies

### Primary Languages
- **Python 3.12+**: Primary language for backend services, ML models, and domain logic
- **TypeScript/JavaScript**: Frontend and tooling support via Nx workspace

### Build System & Task Runner
- **Nx**: Monorepo orchestration, dependency management, and build caching
- **Just**: Command runner for project-specific tasks (preferred over Make)
- **Make**: Legacy build system (being phased out in favor of Just)
- **uv**: Fast Python package manager and virtual environment management

### Package Management
- **pnpm**: Node.js package manager for JavaScript/TypeScript dependencies
- **uv**: Python package and dependency management
- **pip**: Fallback Python package manager

### Development Environment
- **Python Virtual Environment**: `.venv` directory for isolated Python dependencies
- **Pre-commit**: Git hooks for code quality enforcement
- **Pytest**: Python testing framework with dotenv support

## Key Frameworks & Libraries

### AI/ML Stack
- **Vector Databases**: Supabase with pgvector extension
- **ML Model Management**: Custom lifecycle management with training, evaluation, and promotion
- **Data Processing**: Built-in support for analytics and data pipelines

### Web Framework
- **FastAPI**: Default choice for microservice APIs
- **Uvicorn**: ASGI server for FastAPI applications

### Database & Storage
- **Supabase**: PostgreSQL with vector extensions, real-time subscriptions
- **SQLModel**: Type-safe database models and queries

### Infrastructure
- **Docker**: Containerization with multi-stage builds
- **Kubernetes**: Container orchestration with auto-generated manifests
- **Terraform**: Infrastructure as Code
- **Ansible**: Configuration management and deployment automation

## Common Commands

### Setup & Environment
```bash
# Initial setup
just setup
make setup  # legacy

# Python environment management
just init-python-env
uv sync  # sync dependencies

# Start development servers
just dev
```

### Development Workflow
```bash
# Create new DDD context
just context-new CTX=orders

# Generate Python library
just lib NAME=shared-utils

# Generate Python application  
just app NAME=order-api

# Run CI pipeline
just ci

# Run tests
just test
nx affected --target=test

# Lint code
just lint
nx affected --target=lint
```

### Service Architecture
```bash
# Extract context to microservice
just service-split CTX=orders TRANSPORT=fastapi

# Merge microservice back to monolith
just service-merge CTX=orders

# Deploy services
just deploy-services

# Check service status
just service-status
```

### AI/ML Operations
```bash
# Train models
just train

# Evaluate models
just evaluate

# Promote model to production
just promote CTX=recommendation CH=production

# Canary deployment
just canary PCT=25
```

### Database Operations
```bash
# Start Supabase locally
just supabase-up

# Run migrations
just supabase-vector-migrate

# Seed vector database
just supabase-vector-seed
```

### Infrastructure
```bash
# Build Docker images
just containerize PROJECT=order-api

# Deploy to Kubernetes
just deploy-service CTX=orders

# Scale service
just scale-service CTX=orders REPLICAS=3
```

## Build Conventions

### Project Structure Tags
- `context:<name>`: Domain context grouping
- `layer:<domain|application|infrastructure>`: Hexagonal architecture layers
- `type:<service|model|e2e>`: Project type classification
- `deployable:<true|false>`: Whether project can be deployed independently

### Naming Conventions
- **Contexts**: lowercase with hyphens (e.g., `order-management`)
- **Services**: context name + `-svc` suffix (e.g., `order-management-svc`)
- **Libraries**: descriptive names in libs directory
- **Applications**: descriptive names in apps directory

### Environment Variables
- `.env`: Local development environment variables
- `.env.template`: Template for required environment variables
- Load via `dotenv-load` setting in justfile or pytest configuration