#### Overview

You want an Nx workspace that …
1. treats Supabase like any other **shared data-access library**,
2. spins up a **minimal 3-container Supabase stack** for local development/mocking,
3. exposes a **thin CLI** (`supa <command>`) implemented with Typer + a Makefile wrapper, so teammates can run “Nx-ish” tasks even though Nx itself has no Supabase plugin.

The recipe below keeps everything in one repo, leverages Nx task-graph caching, and avoids technical debt by re-using official tools (Supabase CLI, Docker, MSW).

---

#### 1 · Recommended folder layout (inside the Nx workspace)

```
/apps
  └─ web-app/            # Next.js / React / Angular … front-end
/libs
  └─ shared/
      └─ data-access/
          └─ supabase/   # <— all runtime code that talks to Supabase
/tools
  └─ supa_cli/           # Typer-based helper commands
docker/
  └─ supabase/           # Generated minimal docker-compose.yml
Makefile                 # Thin wrapper over Supabase + Typer
```

Nx encourages `apps/` + `libs/` and further grouping by domain; the path `libs/shared/data-access/supabase` follows that guidance.

---

#### 2 · Generate the Supabase data-access library

```bash
nx g @nrwl/js:lib shared-data-access-supabase \
  --directory=shared/data-access \
  --importPath=@myorg/shared/data-access-supabase \
  --tags=scope:shared,type:data-access
```

Inside `libs/shared/data-access/supabase/src/index.ts` create an init helper:

```ts
// libs/shared/data-access/supabase/src/client.ts
import { createClient } from '@supabase/supabase-js';

export const supabase = createClient(
  process.env['NX_SUPABASE_URL']!,
  process.env['NX_SUPABASE_KEY']!
);
```

The library then exports typed helpers, Realtime listeners, etc.

---

#### 3 · Minimal local Supabase stack

Use the **official Supabase CLI ≥ 1.137** but exclude everything except Postgres, GoTrue and PostgREST:

```bash
# one-time
supabase init

# daily
supabase start \
  -x studio -x storage -x imgproxy -x vector \
  -x functions -x kong -x meta             # keep only 3 containers
```

Steady-state footprint ≈ 200-250 MB RAM & ≈ 180 MB images (see previous answer).
Environment variables are written to `supabase/.env`. Map them into Nx apps via `.env.*` or `@nrwl/react:webpack` envFile.

---

#### 4 · Makefile (developer convenience)

```make
## ---- Supabase ----------------------------------------------------------------
SCL=tools/supa_cli/main.py

.PHONY: supa-up supa-down supa-reset supa-seed supa-types
supa-up:
	@supabase start -x studio -x storage -x imgproxy -x vector -x functions -x kong -x meta
supa-down:
	@supabase stop
supa-reset:
	@supabase db reset --force
supa-seed:
	@python $(SCL) seed
supa-types:
	@supabase gen types typescript --local > libs/shared/data-access/supabase/src/generated.types.ts

## ---- Typer passthrough -------------------------------------------------------
supa-%:
	@python $(SCL) $*
```

Running `make supa-up` starts the trimmed stack; `make supa-seed` calls a Typer sub-command.

---

#### 5 · Typer micro-CLI (`tools/supa_cli/main.py`)

```python
import subprocess, typer, json, pathlib, os, sys, shutil
app = typer.Typer(help="Nx-style helpers for Supabase")

ROOT = pathlib.Path(__file__).resolve().parents[2]

@app.command()
def seed():
    "Apply SQL or RPC seeds in supabase/seed.sql"
    sql = ROOT / "supabase" / "seed.sql"
    if not sql.exists():
        typer.echo("No seed.sql found"); raise typer.Exit(1)
    subprocess.run(["supabase", "db", "query", str(sql)], check=True)

@app.command()
def open():
    "Quick link to local PostgREST explorer"
    typer.launch("http://localhost:54323")

@app.command()
def lint():
    "Run sqlfluff on migrations"
    subprocess.run(["sqlfluff", "lint", "supabase/migrations"])

if __name__ == "__main__":
    app()
```

Expose anything Nx cannot: seeding, linting SQL, opening Studio, etc.

---

#### 6 · Wire Supabase into Nx tasks

`project.json` for the web app can depend on a custom **“supabase” target** that uses `@nx/run-commands`:

```jsonc
{
  "name": "web-app",
  "targets": {
    "supabase": {
      "executor": "@nx/run-commands",
      "options": {
        "command": "make supa-up",
        "forwardAllArgs": true,
        "cwd": "${workspaceRoot}"
      }
    },
    "e2e": {
      "executor": "@nx/cypress:cypress",
      "dependsOn": ["supabase"]
    }
  }
}
```

Now `nx run web-app:e2e` starts Supabase once, reuses it across affected targets, and profits from Nx’s task hashing.

In CI you might instead spin **all** services by removing the `-x` flags, guaranteeing parity with production.

---

#### 7 · Mocking strategy inside tests & Storybook

For unit tests or Storybook stories **do not boot containers**; use **Mock-Service-Worker (msw)** bound into Nx just like the article in Source 1 describes :

1. `npm i -D msw`
2. Create `libs/shared/util-testing/src/mocks/handlers.ts` with your Supabase REST paths.
3. Storybook’s `preview.ts` registers the worker; Jest setup does the same.

Because PostgREST exposes pure HTTP, MSW can intercept `/rest/v1/*` and return fixtures, letting component stories run instantly without Docker.

---

#### 8 · Keeping technical debt low

• **Single source of truth** – your Supabase migrations live in `supabase/migrations`, committed the same way Nx commits code.
• **Nx caching** – database-less tests hit MSW; only integration tests depend on the live stack, so the cache stays warm.
• **CLI delegation** – the Typer wrapper never re-implements logic that already exists in `supabase` CLI; it merely orchestrates.
• **Upgrade path** – when Supabase adds new services (Vector, Edge Functions) you remove corresponding `-x` exclusions and gain functionality without refactoring Nx libs.

---

#### 9 · Quick onboarding script (optional)

Add to `package.json`:

```json
"scripts": {
  "dev": "nx run-many --target=supabase --parallel --projects=web-app && nx serve web-app"
}
```

A newcomer only runs `npm run dev` – Nx starts Supabase (if not running), then the web app.

---

#### 10 · What this gives you

• A **lightweight local backend** that behaves 95 % like production.
• **Consistent developer ergonomics**: `nx test`, `nx storybook`, `make supa-*`, `python tools/supa_cli/main.py …`.
• The ability to **cache** and **affect** tasks so that when only UI code changes, Supabase isn’t even started.
• A clear demarcation between **runtime code** (`libs/shared/data-access/supabase`) and **infrastructure helpers** (`tools/supa_cli`, Makefile), matching Nx best-practice for large monorepos.

Feel free to lift any snippets into your existing Makefile; nothing here conflicts with Nx conventions, and everything stays “standard” so future devs instantly recognize the moving parts.




#### TL;DR
The absolute smallest setup that will still behave “like Supabase” is:

1. PostgreSQL + Supabase’s core extensions (`pgcrypto`, `uuid-ossp`, `pgjwt`, `supabase_realtime`, etc.).
2. GoTrue (Auth) if you need to test row-level-security or JWT-based policies.
3. PostgREST if you want to hit the same REST/RPC endpoints your front-end will call.

Using the Supabase CLI ≥ 1.137 you can spin up exactly those three containers with one command:

```bash
supabase start \
  -x studio -x storage -x imgproxy -x vector \
  -x functions -x kong -x meta \
  --db-volume-size 1GiB   # keeps the Docker volume tiny
```

This boots:
• Postgres 15 (~130 MB image, ~150 MB RAM)
• GoTrue (~17 MB image, ~15 MB RAM)
• PostgREST (~32 MB image, ~20 MB RAM)

Total cold-pull size ≈ 180 MB; steady-state RAM ≈ 200 – 250 MB.
For many feature-tests that’s “good enough” while remaining under ½ GB of disk and RAM on a laptop.

---

#### Why this is the “minimum viable” bundle

Service | Why you (might) still need it | Why you can omit everything else
--------|------------------------------|---------------------------------
PostgreSQL | Source of truth; all policies/extensions live here | Non-negotiable
GoTrue | Generates the same JWT payload + refresh flow you’ll see in prod | Skip if you mock JWTs by hand in tests
PostgREST | Powers the `/rest/v1/*` endpoints your front end calls | Skip if you exclusively use Supabase JS client in “schema = public” mode and talk to Postgres directly

Everything else (Realtime, Storage, Studio, Edge Functions, Kong, Vector, ImgProxy) is optional for pure schema / auth / SQL testing and adds 400-600 MB more images plus hundreds of MB of memory.

---

#### One-liner setup

1. Install Docker Desktop or Podman.
2. Install the CLI:

```bash
brew install supabase/tap/supabase   # macOS
# OR
npm i -g supabase                    # Linux/Windows
```

3. Inside your project folder:

```bash
supabase init
supabase start -x studio -x storage -x imgproxy -x vector \
               -x functions -x kong -x meta
```

The CLI will create a trimmed `docker-compose.yml` and run only the selected services.

URLs:
• Postgres: `postgres://postgres:postgres@localhost:54322/postgres`
• Auth:     `http://localhost:9999`
• REST:     `http://localhost:54323`

---

#### Keeping the footprint tiny

• Use `--db-volume-size 1GiB` or even `256MiB` for throw-away dev data.
• Add `-x realtime` if you don’t need `on*.subscribe()` tests.
• Stop containers when idle: `supabase stop`.
• Prune volumes occasionally: `docker volume prune`.

---

#### Is there technical debt in this approach?

“Running a partial Supabase locally” can become debt when:

1. You accidentally rely on behavior that only exists in the stripped-down stack (e.g., no Kong rate-limiting).
2. Your pipeline/tests diverge from prod because of missing services (edge functions, storage S3 semantics, realtime presence, etc.).
3. Devs must maintain bespoke compose files that drift from upstream.

Mitigation / “better ways”:

• Use the full Supabase stack in CI once per pull request with Testcontainers or the official GitHub Action; keep the trimmed setup only for fast inner-loop work.
• For pure front-end unit tests, stub the network layer with tools like `msw` or `vitest` mocks instead of spinning any containers.
• Consider seeding a plain Postgres Docker image with the Supabase extension set and your schema if you truly only need SQL + RLS; that removes even GoTrue/PostgREST.

---

#### Recommended workflow

1. Day-to-day coding: trimmed 3-container stack (`supabase start -x ...`).
2. Pre-push / CI: full `supabase start` (all services) or the official `supabase/db` Testcontainer image.
3. Unit tests: pure mocks / stubs, no Docker at all.

That gives you fast feedback locally, confidence in CI, and keeps disk/RAM usage to a minimum without accruing meaningful technical debt.
