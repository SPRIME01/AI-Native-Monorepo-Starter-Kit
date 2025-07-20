# Design Document

## Overview

This design outlines the complete migration from Make (Makefile) to Just (justfile) build system for the AI-Native Monorepo Starter Kit. The migration addresses critical issues preventing full adoption of Just as the primary build system, including missing dependencies, incomplete helper functions, outdated documentation, and cross-platform compatibility concerns.

The migration follows a systematic approach to ensure zero disruption to existing workflows while modernizing the build system infrastructure. The design prioritizes backward compatibility during transition and provides clear migration paths for all stakeholders.

## Architecture

### Current State Analysis

The project currently operates in a hybrid state with both Make and Just systems:

**Makefile Status:**
- Comprehensive 1000+ line implementation with full feature coverage
- Complex shell-based helper functions and environment validation
- References to missing `setup_helper.sh` file (removed by `scripts/remove_setup_helper.py`)
- Extensive service architecture management capabilities
- Full AI/ML model lifecycle support

**Justfile Status:**
- Partial migration with ~80% command coverage
- Missing critical helper function implementations
- Incomplete service management logic
- Truncated command implementations
- References to missing `setup_helper.sh` dependency

### Target Architecture

The target architecture establishes Just as the single source of truth for build operations:

```
Build System Architecture
├── justfile (Primary Interface)
│   ├── Core Commands (setup, dev, ci, test, lint)
│   ├── Service Architecture (split, merge, deploy, scale)
│   ├── AI/ML Lifecycle (train, evaluate, promote, canary)
│   ├── Infrastructure (containerize, k8s, terraform)
│   └── Helper Functions (inline or Python-based)
├── Python Scripts (Complex Logic)
│   ├── scripts/setup.py (Environment management)
│   ├── scripts/generate_domain.py (Domain scaffolding)
│   └── scripts/supabase_cli.py (Database operations)
├── Documentation (Updated Examples)
│   ├── README.md (Just commands only)
│   ├── HEXAGONAL_ARCHITECTURE_SUMMARY.md
│   └── GEMINI.md
└── Legacy Support (Deprecated)
    └── Makefile (Marked as deprecated with migration guide)
```

## Components and Interfaces

### 1. Command Migration Layer

**Interface:** Direct command mapping from Make to Just syntax
**Responsibility:** Ensure functional parity between Make and Just commands

Key transformations:
- Variable syntax: `$(VAR)` → `{{VAR}}`
- Conditional logic: Shell-based → Just native conditionals
- Multi-line commands: Makefile continuations → Just recipe blocks
- Environment validation: Custom `need` function → Python-based validation

### 2. Helper Function Resolution

**Interface:** Replace missing `setup_helper.sh` functionality
**Responsibility:** Provide equivalent functionality through alternative implementations

Resolution strategies:
- **Python Integration:** Complex logic moved to `scripts/setup.py`
- **Inline Shell:** Simple operations implemented directly in justfile
- **Cross-platform Scripts:** Platform detection and appropriate command selection

### 3. Service Architecture Management

**Interface:** Complete service lifecycle management
**Responsibility:** Full implementation of truncated service commands

Components:
- `create-service-app`: Generate microservice application structure
- `create-service-container`: Docker configuration generation
- `create-service-k8s`: Kubernetes manifest creation
- `update-service-tags`: Project metadata management

### 4. Documentation Synchronization

**Interface:** Consistent command examples across all documentation
**Responsibility:** Update all references from `make` to `just` commands

Affected files:
- `README.md`: Installation and usage examples
- `HEXAGONAL_ARCHITECTURE_SUMMARY.md`: Architecture commands
- `GEMINI.md`: Development workflow examples
- Inline code comments and help text

## Data Models

### Command Configuration Model

```python
@dataclass
class CommandConfig:
    name: str
    description: str
    parameters: List[str]
    dependencies: List[str]
    cross_platform: bool
    implementation_type: Literal["inline", "python", "shell"]
```

### Migration Status Model

```python
@dataclass
class MigrationStatus:
    command_name: str
    makefile_exists: bool
    justfile_exists: bool
    functionality_complete: bool
    documentation_updated: bool
    testing_verified: bool
```

### Service Architecture Model

```python
@dataclass
class ServiceConfig:
    context_name: str
    transport_type: Literal["fastapi", "grpc", "kafka"]
    deployment_target: Literal["kubernetes", "docker", "local"]
    scaling_config: Dict[str, Any]
    health_check_config: Dict[str, Any]
```

## Error Handling

### 1. Missing Dependency Resolution

**Problem:** Commands fail due to missing `setup_helper.sh`
**Solution:** Implement fallback mechanisms and clear error messages

```just
install-custom-py-generator: # Install custom Python generators
    @if [ -f ".make_assets/setup_helper.sh" ]; then \
        bash ./.make_assets/setup_helper.sh install_custom_py_generator {{CUSTOM_PY_GEN_PLUGIN_NAME}}; \
    else \
        echo "🔧 Using Python-based generator installation..."; \
        python3 scripts/setup.py install_custom_py_generator --name={{CUSTOM_PY_GEN_PLUGIN_NAME}}; \
    fi
```

### 2. Cross-Platform Compatibility

**Problem:** Shell commands may not work consistently across Windows/Unix
**Solution:** Platform detection and appropriate command selection

```just
# Platform-aware command execution
clean-cache:
    @if [ "{{os()}}" = "windows" ]; then \
        powershell -Command "Remove-Item -Recurse -Force .nx, node_modules -ErrorAction SilentlyContinue"; \
    else \
        rm -rf .nx node_modules; \
    fi
```

### 3. Incomplete Command Implementation

**Problem:** Justfile commands are truncated or incomplete
**Solution:** Full implementation with proper error handling and validation

```just
service-split CTX TRANSPORT='fastapi': # Extract context to microservice
    @if [ -z "{{CTX}}" ]; then \
        echo "❌ Error: CTX parameter is required"; \
        echo "Usage: just service-split CTX=<context-name> [TRANSPORT=fastapi|grpc|kafka]"; \
        exit 1; \
    fi
    @if [ ! -d "libs/{{CTX}}" ]; then \
        echo "❌ Context {{CTX}} not found. Run 'just context-new CTX={{CTX}}' first."; \
        exit 1; \
    fi
    # ... complete implementation
```

### 4. Documentation Inconsistency

**Problem:** Documentation contains outdated `make` command examples
**Solution:** Systematic replacement with validation

Strategy:
1. Automated search and replace for common patterns
2. Manual review of complex examples
3. Validation that all examples work with current justfile
4. Addition of migration notes for users

## Testing Strategy

### 1. Command Parity Testing

**Objective:** Ensure all Make commands have equivalent Just implementations

Test approach:
- Command inventory comparison
- Parameter validation testing
- Output format verification
- Error condition handling

### 2. Cross-Platform Testing

**Objective:** Verify commands work on Windows, macOS, and Linux

Test matrix:
- Windows (PowerShell/CMD)
- macOS (bash/zsh)
- Linux (bash)
- Container environments (Docker)

### 3. Integration Testing

**Objective:** Validate complete workflows using Just commands

Test scenarios:
- Fresh project setup (`just setup`)
- Domain creation and service extraction
- CI/CD pipeline execution
- ML model lifecycle management
- Infrastructure deployment

### 4. Documentation Validation

**Objective:** Ensure all documented examples work correctly

Validation process:
- Automated extraction of code examples from documentation
- Execution testing in clean environment
- Link validation and reference checking
- User experience testing with new developers

### 5. Regression Testing

**Objective:** Ensure migration doesn't break existing functionality

Test coverage:
- All existing Make commands replicated in Just
- Service architecture operations
- Database operations (Supabase integration)
- Container and Kubernetes deployments
- AI/ML model operations

## Implementation Phases

### Phase 1: Core Infrastructure
- Fix missing `setup_helper.sh` dependencies
- Implement complete helper functions in justfile
- Add proper error handling and validation
- Ensure cross-platform compatibility

### Phase 2: Service Architecture
- Complete truncated service management commands
- Implement full Docker and Kubernetes integration
- Add service scaling and monitoring capabilities
- Validate service lifecycle operations

### Phase 3: Documentation Migration
- Update all documentation files with Just commands
- Add migration guide for existing users
- Create troubleshooting documentation
- Validate all examples work correctly

### Phase 4: Legacy Cleanup
- Mark Makefile as deprecated
- Add migration warnings and guidance
- Provide transition period support
- Remove or archive legacy files

## Design Decisions and Rationales

### 1. Hybrid Approach During Transition

**Decision:** Maintain both Make and Just during migration period
**Rationale:** Minimizes disruption to existing workflows and allows gradual adoption

### 2. Python Integration for Complex Logic

**Decision:** Move complex shell logic to Python scripts
**Rationale:** Better cross-platform compatibility, easier testing, and more maintainable code

### 3. Inline Implementation for Simple Commands

**Decision:** Implement simple commands directly in justfile
**Rationale:** Reduces external dependencies and improves performance

### 4. Comprehensive Error Handling

**Decision:** Add extensive error checking and user-friendly messages
**Rationale:** Improves developer experience and reduces support burden

### 5. Documentation-First Approach

**Decision:** Update documentation as part of migration, not after
**Rationale:** Ensures consistency and prevents outdated examples from persisting

### 6. Backward Compatibility Preservation

**Decision:** Maintain command interface compatibility where possible
**Rationale:** Reduces learning curve and migration friction for existing users

This design provides a comprehensive roadmap for completing the Make-to-Just migration while addressing all identified issues and ensuring a smooth transition for all stakeholders.