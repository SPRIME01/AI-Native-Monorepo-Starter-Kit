# Project Organization & Folder Structure

## Root Directory Structure

```
├── apps/                    # Deployable applications (APIs, services)
├── libs/                    # Shared libraries and domain contexts
├── tools/                   # Development tools and generators
├── scripts/                 # Automation and setup scripts
├── tests/                   # End-to-end and integration tests
├── docs/                    # Project documentation
├── docker/                  # Docker configurations and compose files
├── supabase/               # Database migrations and configurations
├── .kiro/                  # Kiro IDE configuration and steering rules
├── .venv/                  # Python virtual environment
├── node_modules/           # Node.js dependencies
└── project-definitions/    # MECE-driven domain definitions
```

## Core Directories

### `/apps` - Applications
Deployable applications following microservice patterns:
- **Naming**: `<context>-api` or `<context>-svc`
- **Structure**: Each app has `src/main.py` as entry point
- **Purpose**: Expose domain logic via transport layers (FastAPI, gRPC, etc.)
- **Tags**: `type:service`, `deployable:true`, `context:<name>`

### `/libs` - Libraries & Domain Contexts
Shared code organized by domain using hexagonal architecture:

```
libs/
├── <domain-context>/           # Business domain (e.g., allocation, payments)
│   ├── domain/                 # Core business logic
│   │   ├── entities/           # Domain entities
│   │   ├── aggregates/         # Domain aggregates  
│   │   ├── value_objects/      # Value objects
│   │   ├── policies/           # Business policies
│   │   └── rules/              # Business rules
│   ├── application/            # Application services and use cases
│   └── adapters/               # Infrastructure adapters (ports & adapters)
├── shared/                     # Cross-cutting concerns
│   ├── data_access/            # Database utilities
│   ├── observability/          # Logging, metrics, tracing
│   └── vector/                 # Vector database utilities
└── models/                     # ML models (optional)
    └── <model-name>/           # Individual ML model packages
```

### `/tools` - Development Tools
Custom generators and development utilities:
- `generators/`: Nx generators for domain scaffolding
- `supa_cli/`: Supabase CLI wrapper utilities

### `/scripts` - Automation Scripts
Setup and maintenance scripts:
- `setup.py`: Environment initialization
- `generate_domain.py`: Domain scaffolding automation
- Cross-platform scripts (`.sh` and `.ps1` variants)

## Hexagonal Architecture Patterns

### Domain Layer (`libs/<context>/domain/`)
- **Entities**: Core business objects with identity
- **Aggregates**: Consistency boundaries for entities
- **Value Objects**: Immutable objects without identity
- **Policies**: Business rules and constraints
- **Rules**: Domain-specific validation logic

### Application Layer (`libs/<context>/application/`)
- **Services**: Application use cases and orchestration
- **Commands/Queries**: CQRS pattern implementation
- **DTOs**: Data transfer objects for boundaries

### Infrastructure Layer (`libs/<context>/adapters/`)
- **Repositories**: Data persistence implementations
- **External Services**: Third-party integrations
- **Message Handlers**: Event and message processing

## File Naming Conventions

### Python Files
- **Classes**: PascalCase (e.g., `OrderService`, `CustomerEntity`)
- **Files**: snake_case matching class names (e.g., `order_service.py`)
- **Modules**: snake_case (e.g., `payment_processing.py`)

### Project Configuration
- **Nx Projects**: `project.json` in each project root
- **Python Packages**: `__init__.py` in each package directory
- **Dependencies**: `pyproject.toml` for Python, `package.json` for Node.js

### Docker & Infrastructure
- **Dockerfiles**: `Dockerfile` in application directories
- **Kubernetes**: `k8s/` subdirectory with YAML manifests
- **Compose**: `docker-compose.yml` for local development

## Tagging Strategy

### Context Tags
- `context:<domain-name>`: Groups related projects by business domain
- `scope:<area>`: Broader organizational grouping

### Layer Tags  
- `layer:domain`: Core business logic
- `layer:application`: Use cases and orchestration
- `layer:infrastructure`: External concerns and adapters

### Type Tags
- `type:service`: Deployable microservices
- `type:library`: Shared code libraries
- `type:model`: ML model packages
- `type:e2e`: End-to-end test suites

### Deployment Tags
- `deployable:true`: Can be deployed independently
- `deployable:false`: Internal library or shared code

## Directory Creation Rules

### Automatic Generation
- Use `just context-new CTX=<name>` to create proper hexagonal structure
- Use `just lib NAME=<name>` for shared libraries
- Use `just app NAME=<name>` for applications

### Manual Structure
When creating directories manually, ensure:
1. Proper `__init__.py` files in Python packages
2. `project.json` with appropriate tags
3. Consistent naming following conventions
4. README.md documenting purpose and usage

## Import Patterns

### Internal Imports
```python
# Domain layer imports
from libs.orders.domain.entities.order import Order
from libs.orders.domain.value_objects.money import Money

# Application layer imports  
from libs.orders.application.order_service import OrderService

# Adapter imports
from libs.orders.adapters.order_repository import OrderRepository
```

### Shared Library Imports
```python
# Shared utilities
from libs.shared.data_access.database import Database
from libs.shared.observability.logger import Logger
```

### Cross-Context Communication
- Use application services as boundaries
- Avoid direct domain-to-domain dependencies
- Prefer event-driven communication for loose coupling

## Migration Patterns

### Monolith to Microservice
1. Context exists in `libs/<context>/`
2. Run `just service-split CTX=<context>`
3. Service created in `apps/<context>-svc/`
4. Original context remains unchanged

### Microservice to Monolith  
1. Service exists in `apps/<context>-svc/`
2. Run `just service-merge CTX=<context>`
3. Service directory removed
4. Context in `libs/<context>/` unchanged