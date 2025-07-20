---
applyTo: "{.env*,config/**/*,*.config.{js,ts}}"
---

## Configuration & Environment Guidelines

### Environment Variables

- Use type-safe environment validation with Zod
- Separate development, staging, and production configs
- Never commit sensitive values to version control

### Configuration Files

- Use TypeScript for configuration when possible
- Implement proper schema validation
- Document all configuration options

### How-to: Setting up environment validation

```typescript
// 1. Define environment schema
const envSchema = z.object({
  DATABASE_URL: z.string().url(),
  JWT_SECRET: z.string().min(32),
  NODE_ENV: z.enum(["development", "staging", "production"]),
});

// 2. Validate and export
export const env = envSchema.parse(process.env);
```
