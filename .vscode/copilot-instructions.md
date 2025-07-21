# AI-Native Monorepo Copilot Instructions

## General Rules

Follow all rules from `.github/instructions/general-rules.instructions.md`.

## Justfile Workflow Integration

This project uses a `justfile` for orchestrating all development tasks. **Always use justfile commands instead of direct CLI commands** when available:

### Core Development Commands
- **Setup**: `just setup` - Initial monorepo setup (run once)
- **Development**: `just dev` - Start development servers with watch mode
- **CI Pipeline**: `just ci` - Run complete CI pipeline locally
- **Testing**: `just test` - Run tests for affected projects
- **Linting**: `just lint` - Lint affected projects
- **Building**: `just build` - Build affected projects

### Project Generation Commands
- **New App**: `just app NAME` - Generate Python application
- **New Library**: `just lib NAME` - Generate Python library
- **New DDD Context**: `just context-new CTX=context-name` - Create hexagonal architecture context

### Service Architecture Commands
- **Extract Microservice**: `just service-split CTX=context-name TRANSPORT=fastapi`
- **Merge to Monolith**: `just service-merge CTX=context-name`
- **Service Status**: `just service-status` - Show deployment status
- **Service List**: `just service-list` - List deployable services

### ML/AI Workflow Commands
- **New Model**: `just model-new CTX=model-name`
- **Train Models**: `just train` - Train affected ML models
- **Evaluate Models**: `just evaluate` - Evaluate affected models
- **Model Registry**: `just register` - Register models

### Container & Deployment Commands
- **Build Images**: `just build-service-images` - Build all service Docker images
- **Deploy Service**: `just deploy-service CTX=service-name`
- **Deploy All**: `just deploy-services` - Deploy all services
- **Scale Service**: `just scale-service CTX=service-name REPLICAS=3`

### Workspace Management Commands
- **Help**: `just help` - Show all available commands
- **Graph**: `just graph` - Open Nx dependency graph
- **Doctor**: `just doctor` - Workspace diagnostics
- **Clean**: `just clean` - Clean build artifacts and caches

## Context-Specific Instructions

When working with specific technologies or file patterns, also apply these specialized instructions:

### Database Operations

- **Files**: `libs/database/**/*.py`
- **Reference**: `.github/instructions/database.instructions.md`
- Use SQLModel for all database models and operations

### API Development

- **Files**: `apps/api/**/*.py`
- **Reference**: `.github/instructions/fastapi.instructions.md`
- Use Pydantic models for request/response schemas

### Frontend Development

- **Files**: `apps/web/**/*.{ts,tsx,js,jsx}`
- **Reference**: `.github/instructions/react.instructions.md`
- Use functional components with TypeScript interfaces

### UI Components

- **Files**: `apps/web/**/*.{tsx,css,scss}`
- **Reference**: `.github/instructions/ui.instructions.md`
- Use Tailwind CSS with design system tokens

### Testing

- **Files**: `**/tests/**/*.{py,ts,tsx}`
- **Reference**: `.github/instructions/testing.instructions.md`
- Achieve 90%+ code coverage, use descriptive test names

### Configuration

- **Files**: `{.env*,config/**/*,*.config.{js,ts}}`
- **Reference**: `.github/instructions/config.instructions.md`
- Use type-safe environment validation

## Architecture Patterns

### Hexagonal Architecture (DDD)
- **Domain Layer**: `libs/*/domain/` - Pure business logic, no external dependencies
- **Application Layer**: `libs/*/application/` - Use cases and application services
- **Infrastructure Layer**: `libs/*/infrastructure/` - External adapters and implementations

### Microservice Architecture
- Use `just service-split CTX=name` to extract contexts as microservices
- Use `just service-merge CTX=name` to merge microservices back to monolith
- All services deployable via `just deploy-services`

### ML/AI Integration
- Models in `libs/models/` with lifecycle management
- Training pipeline via `just train`
- Model registry via `just register`

## Nx Workspace

This is an Nx workspace with Python support via `@nxlv/python` plugin. Follow `.github/instructions/nx.instructions.md` for Nx-specific operations.

### Nx + Justfile Integration
- **Prefer justfile commands** over direct `nx` commands for consistency
- Use `just graph` instead of `npx nx graph`
- Use `just ci` instead of manual `nx affected` commands
- Use `just doctor` for workspace health checks

## Development Workflow

### New Feature Development
1. `just context-new CTX=feature-name` - Create DDD context
2. `just dev` - Start development mode
3. `just test` - Run tests during development
4. `just ci` - Validate before commit

### Microservice Extraction
1. Develop in monolith using DDD contexts
2. `just service-split CTX=context-name` when ready to extract
3. `just deploy-service CTX=context-name` to deploy
4. `just service-merge CTX=context-name` to merge back if needed

### ML Model Development
1. `just model-new CTX=model-name` - Create model library
2. `just train` - Train models
3. `just evaluate` - Evaluate performance
4. `just register` - Register in model registry

## Instruction Priority

1. System messages (highest priority)
2. This file (.vscode/copilot-instructions.md)
3. Justfile workflow commands (use these over direct CLI)
4. Specialized instruction files
5. General coding best practices (lowest priority)
