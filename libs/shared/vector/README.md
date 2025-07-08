# Vector Database Integration (Supabase/pgvector, SQLModel, TypeScript)

## Overview
This directory provides a full-stack, type-safe, and production-ready vector database integration for AI-native applications using Supabase/pgvector, SQLModel, and TypeScript.

---

## Features
- **SQLModel-based vector schema** for type safety and migrations
- **Supabase/pgvector adapter** for Python and TypeScript
- **Auto-generated REST API with FastAPI**
- **Provider-agnostic config and Makefile targets**
- **Seed scripts and example data**
- **End-to-end test and usage examples**

---

## Usage

### 1. Migrate Vector Table to Supabase
```sh
make supabase-vector-migrate
```

### 2. Seed Example Vectors
```sh
make supabase-vector-seed
```

### 3. Use in Python
```python
from libs.shared.vector.supabase_adapter import SupabaseVectorAdapter
adapter = SupabaseVectorAdapter()
adapter.upsert([...], [...], [...])
results = adapter.query([...], top_k=5)
```

### 4. Use in TypeScript
```ts
import { SupabaseVectorAdapter } from './supabase_vector_adapter';
const adapter = new SupabaseVectorAdapter();
await adapter.upsert([...]);
const results = await adapter.query([...], 5);
```

### 5. FastAPI REST API
```python
from libs.shared.vector.sqlmodel.vector_api import router
app.include_router(router)
```

---

## Extending
- Add new adapters for QDrant, Pinecone, etc. by subclassing `VectorDBAdapter`
- Update `vector_record.py` for schema changes and re-generate migrations
- Use `supabase_vector_types.ts` for full-stack type safety

---

## Technical Debt Addressed
- No hardcoded SQL; all schema and operations are type-safe
- Consistent error handling and validation
- Shared types between Python and TypeScript

---

## Requirements
- Supabase CLI, Python 3.10+, Node.js, pnpm, SQLModel, FastAPI, @supabase/supabase-js

---

## See Also
- `supabase-vector-integration-plan.md` for the full implementation plan
