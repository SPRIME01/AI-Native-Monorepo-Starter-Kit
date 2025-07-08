# Supabase Integration for Nx Monorepos

## Overview

This guide shows how to integrate Supabase into your Nx monorepo as a shared data-access library with minimal local development overhead and maximum CI/CD efficiency.

**Key Goals:**
- Treat Supabase as any other shared library in your Nx workspace
- Maintain a lightweight local development stack (3 containers, ~200MB RAM)
- Integrate seamlessly with Nx task caching and dependency graph
- Avoid technical debt through standard tooling

---

## Quick Start

### Prerequisites

- Docker Desktop or Podman
- Supabase CLI ≥ 1.137
- Node.js with pnpm
- Nx workspace

### Installation

```bash
# Install Supabase CLI
npm i -g supabase

# Initialize in your Nx workspace
supabase init

# Generate the data-access library
nx g @nrwl/js:lib shared-data-access-supabase \
  --directory=shared/data-access \
  --importPath=@myorg/shared/data-access-supabase \
  --tags=scope:shared,type:data-access
```

### Start Development Stack

```bash
# Minimal 3-container stack (Postgres + GoTrue + PostgREST)
supabase start \
  -x studio -x storage -x imgproxy -x vector \
  -x functions -x kong -x meta \
  --db-volume-size 1GiB
```

**Result:** ~180MB images, ~200-250MB RAM usage

---

## Architecture

### Folder Structure

```
/apps
  └─ web-app/                    # Next.js/React frontend
/libs
  └─ shared/
      └─ data-access/
          └─ supabase/           # Runtime Supabase code
/tools
  └─ supa_cli/                   # Python CLI helpers
/docker
  └─ supabase/                   # Docker compose overrides
/supabase                        # Official Supabase folder
  ├─ migrations/
  ├─ seed.sql
  └─ config.toml
Makefile                         # Developer convenience wrapper
```

### Service Dependencies

| Service    | Purpose                              | RAM   | Why Essential |
|------------|--------------------------------------|-------|---------------|
| PostgreSQL | Core database with Supabase extensions | ~150MB | Source of truth for schema/policies |
| GoTrue     | Authentication & JWT generation      | ~15MB  | Required for RLS testing |
| PostgREST  | REST API endpoints                   | ~20MB  | Frontend integration point |

**Excluded Services:** Studio, Storage, Edge Functions, Kong, Vector, ImgProxy (adds 400-600MB)

---

## Implementation

### 1. Data Access Library

Create the core Supabase client:

```typescript
// libs/shared/data-access/supabase/src/client.ts
import { createClient } from '@supabase/supabase-js';

export const supabase = createClient(
  process.env['NX_SUPABASE_URL']!,
  process.env['NX_SUPABASE_ANON_KEY']!
);

// Export typed helpers, query builders, etc.
export * from './queries';
export * from './types';
```

### 2. Makefile Integration

```makefile
# ==============================================================================
# Supabase Development Stack
# ==============================================================================

SCL=tools/supa_cli/main.py

.PHONY: supa-up supa-down supa-reset supa-seed supa-types

supa-up:
	@echo "🚀 Starting minimal Supabase stack..."
	@supabase start -x studio -x storage -x imgproxy -x vector -x functions -x kong -x meta

supa-down:
	@echo "🛑 Stopping Supabase stack..."
	@supabase stop

supa-reset:
	@echo "🔄 Resetting database..."
	@supabase db reset --force

supa-seed:
	@echo "🌱 Seeding database..."
	@python $(SCL) seed

supa-types:
	@echo "📝 Generating TypeScript types..."
	@supabase gen types typescript --local > libs/shared/data-access/supabase/src/generated.types.ts

# Passthrough for CLI commands
supa-%:
	@python $(SCL) $*
```

### 3. Python CLI Helper

```python
# tools/supa_cli/main.py
import subprocess
import typer
import pathlib
from typing import Optional

app = typer.Typer(help="Nx-integrated Supabase utilities")
ROOT = pathlib.Path(__file__).resolve().parents[2]

@app.command()
def seed():
    """Apply SQL seeds from supabase/seed.sql"""
    sql_file = ROOT / "supabase" / "seed.sql"
    if not sql_file.exists():
        typer.echo("❌ No seed.sql found")
        raise typer.Exit(1)

    subprocess.run(
        ["supabase", "db", "query", str(sql_file)],
        check=True
    )
    typer.echo("✅ Database seeded")

@app.command()
def open():
    """Open local PostgREST API explorer"""
    typer.launch("http://localhost:54323")

@app.command()
def lint():
    """Lint SQL migrations with sqlfluff"""
    subprocess.run(["sqlfluff", "lint", "supabase/migrations"])

@app.command()
def status():
    """Show running services status"""
    subprocess.run(["supabase", "status"])

if __name__ == "__main__":
    app()
```

### 4. Nx Task Integration

Wire Supabase into your Nx dependency graph:

```json
// apps/web-app/project.json
{
  "name": "web-app",
  "targets": {
    "supabase": {
      "executor": "@nx/run-commands",
      "options": {
        "command": "make supa-up",
        "forwardAllArgs": true,
        "cwd": "{workspaceRoot}"
      }
    },
    "serve": {
      "executor": "@nx/next:dev",
      "dependsOn": ["supabase"]
    },
    "e2e": {
      "executor": "@nx/cypress:cypress",
      "dependsOn": ["supabase"]
    }
  }
}
```

**Benefits:**
- `nx serve web-app` automatically starts Supabase
- Nx caches database state across runs
- Task graph visualizes dependencies

---

## Testing Strategy

### Unit Tests: Mock Everything

Use Mock Service Worker (MSW) for fast, isolated tests:

```typescript
// libs/shared/util-testing/src/mocks/supabase.ts
import { rest } from 'msw';

export const supabaseHandlers = [
  rest.get('http://localhost:54323/rest/v1/users', (req, res, ctx) => {
    return res(ctx.json([{ id: 1, name: 'Test User' }]));
  }),
];
```

### Integration Tests: Live Database

Use the full Supabase stack for end-to-end tests:

```typescript
// apps/web-app/cypress/support/e2e.ts
beforeEach(() => {
  cy.task('db:seed'); // Resets to known state
});
```

### CI/CD Strategy

- **Local development:** Minimal 3-container stack
- **Pull requests:** Full Supabase stack with all services
- **Production:** Hosted Supabase

---

## Optimization Tips

### Resource Management

```bash
# Minimize volume size
supabase start --db-volume-size 256MiB

# Exclude realtime if not needed
supabase start -x realtime -x studio -x storage

# Stop when idle
supabase stop

# Clean up volumes
docker volume prune
```

### Nx Caching

```json
// nx.json
{
  "tasksRunnerOptions": {
    "default": {
      "options": {
        "cacheableOperations": ["supabase", "test", "lint"]
      }
    }
  }
}
```

---

## Common Workflows

### Daily Development

```bash
# Start everything
make supa-up
nx serve web-app

# Make schema changes
supabase db diff --file new_migration
supabase db reset
make supa-seed

# Generate new types
make supa-types
```

### Team Onboarding

```bash
# One-command setup
npm run dev  # Defined in package.json
```

```json
// package.json
{
  "scripts": {
    "dev": "nx run-many --target=supabase --parallel --projects=web-app && nx serve web-app"
  }
}
```

### Production Deployment

```bash
# Link to production
supabase link --project-ref YOUR_PROJECT_REF

# Deploy migrations
supabase db push

# Deploy edge functions
supabase functions deploy
```

---

## Troubleshooting

### Common Issues

**Port conflicts:**
```bash
# Check what's running
supabase status
netstat -an | grep 54322
```

**Memory issues:**
```bash
# Reduce container size
supabase start --db-volume-size 256MiB -x vector -x storage
```

**Type generation errors:**
```bash
# Ensure database is running
supabase status
make supa-types
```

### Performance Monitoring

```bash
# Check resource usage
docker stats
make supa-status
```

---

## Technical Debt Prevention

### ✅ Best Practices

- **Single source of truth:** All migrations in `supabase/migrations/`
- **Standard tooling:** Use official Supabase CLI, don't reinvent
- **Nx integration:** Leverage task caching and dependency graph
- **Environment parity:** Full stack in CI, minimal in development

### ❌ Anti-patterns

- Custom Docker compositions that drift from upstream
- Mocking database behavior instead of using real Postgres
- Running full stack for unit tests
- Hardcoding connection strings

---

## Reference

### Environment Variables

```bash
# Auto-generated by supabase start
SUPABASE_URL=http://localhost:54323
SUPABASE_ANON_KEY=your-anon-key
SUPABASE_SERVICE_ROLE_KEY=your-service-key
```

### Service URLs

- **Database:** `postgres://postgres:postgres@localhost:54322/postgres`
- **API:** `http://localhost:54323`
- **Auth:** `http://localhost:9999`

### Useful Commands

| Command | Purpose |
|---------|---------|
| `make supa-up` | Start minimal stack |
| `make supa-down` | Stop all services |
| `make supa-reset` | Reset database |
| `make supa-seed` | Load test data |
| `make supa-types` | Generate TypeScript types |
| `nx graph` | View dependency graph |

---

This integration provides a lightweight, Nx-native Supabase development experience while maintaining production parity and avoiding common technical debt pitfalls.
