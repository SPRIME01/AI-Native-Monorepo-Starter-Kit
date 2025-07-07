---
applyTo: "{libs,apps}/**/*"
---

## Nx Monorepo Guidelines

### Library Structure

- Create domain-specific libraries under `/libs`
- Use barrel exports (index.ts) for clean imports
- Implement proper dependency boundaries

### Code Organization

- Separate business logic from UI components
- Create shared utilities in `/libs/shared`
- Use Nx generators for consistent code structure

### How-to: Creating a new library

```bash
# 1. Generate new library
nx g @nx/js:lib shared-utils

# 2. Add barrel export in index.ts
export * from './lib/utils';

# 3. Import in consuming apps
import { utilityFunction } from '@myorg/shared-utils';
```
