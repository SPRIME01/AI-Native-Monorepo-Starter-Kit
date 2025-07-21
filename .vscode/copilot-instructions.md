# AI-Native Monorepo Copilot Instructions

## General Rules
Follow all rules from `.github/instructions/general-rules.instructions.md`.

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

## Nx Workspace
This is an Nx workspace. Follow `.github/instructions/nx.instructions.md` for Nx-specific operations.

## Instruction Priority
1. System messages (highest priority)
2. This file (.vscode/copilot-instructions.md)
3. Specialized instruction files
4. General coding best practices (lowest priority)
