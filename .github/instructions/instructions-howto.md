---
applyTo: "**"
---

#  How-To: Using Custom Instructions

## What are .instructions.md files?
- Markdown files that provide Copilot with context-specific coding rules and best practices.
- Each file targets a specific domain, technology, or folder using the `applyTo` front matter.

## How to use them in this project
1. Place all `.instructions.md` files in `.github/instructions/`.
2. Each file should be MECE: Mutually Exclusive, Collectively Exhaustive—no overlap, no gaps.
3. Use the `applyTo` field to scope rules to the right files or folders.
4. Add clear, imperative rules and at least one practical "How-to" code example per file.
5. Supplement (not duplicate) the general rules in `general-rules.instructions.md`.

## Example
- `react.instructions.md` applies only to React/TypeScript files in `apps/web/`.
- `fastapi.instructions.md` applies only to Python FastAPI code in `apps/api/`.
- `testing.instructions.md` applies only to test files.
- `config.instructions.md` applies only to config and environment files.

## Best Practices
- Keep each file focused and concise.
- Use code comments to explain non-obvious rules.
- Update instructions as your architecture evolves.

---

# Why ?
- Ensures instructions are discoverable (reference), actionable (how-to), and conceptual (explanation) for both humans and Copilot.
- Promotes clarity, maintainability, and onboarding speed.
