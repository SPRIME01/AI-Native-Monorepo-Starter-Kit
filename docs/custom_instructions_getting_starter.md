# Configuring GitHub Copilot Custom Instructions

This guide provides a comprehensive overview of how to configure GitHub Copilot with custom instructions to tailor its behavior to your project's specific needs. Following these steps will improve Copilot's accuracy, align it with your coding standards, and streamline your development workflow.

## Quick Start: Repository-Wide Instructions

The most straightforward way to provide context to Copilot is by creating a single instructions file at the root of your repository. Copilot automatically detects and uses this file for all interactions within the project.

### How-To

1.  **Create the file**: In your project's root, create a file named `.github/copilot-instructions.md`. If the `.github` directory doesn't exist, create it first.
2.  **Add your instructions**: Populate the file with clear, direct guidelines.

### Example: `copilot-instructions.md`

A well-structured instructions file is crucial. Use Markdown to organize your rules logically.

```markdown
# Copilot Instructions

## Overall Guidelines
- You are an autonomous coding assistant.
- Complete all parts of every request.
- Read file content before making changes.
- Reuse existing helper functions and imports.

## Project Context
- **Frameworks**: This is a monorepo using Nx. The backend is FastAPI with Pydantic, and the frontend is React with Tailwind CSS.
- **Structure**: Use a domain-based folder structure under `/libs` and `/apps`.

## Coding Conventions
- **Language**: Use TypeScript with ES2022 syntax.
- **Style**: Follow the Airbnb style guide.
- **Asynchronicity**: Always use async/await for promises.

## Validation & Testing
- **Testing Framework**: Use pytest with a minimum of 90% coverage.
- **Test Location**: Place tests in `tests/unit/` and `tests/integration/`.
- **Schema Validation**: Use `pydantic.BaseModel` for all JSON schema validation.

## Output Format
- **Code Only**: Provide working code without explanations.
- **Package Managers**: Use `yarn` for JavaScript and `poetry` for Python.
- **Deployment Targets**: Assume deployment to AWS Lambda (Python) or Vercel (JS).
```

---

## Advanced Configuration

For more granular control, you can use multiple instruction files or configure instructions directly in VS Code's settings.

### Method 1: Granular Instruction Files (`.instructions.md`)

Use separate files to organize instructions by language, framework, or task.

1.  **Location**: Store these files in the `.github/instructions` directory.
2.  **File Naming**: Use the `.instructions.md` suffix (e.g., `typescript.instructions.md`).
3.  **Automatic Application**: Use front matter to specify when an instruction file should apply.

**Example: `react.instructions.md`**

This file will automatically apply to all files within `apps/web/src`.

```markdown
---
applyTo: "apps/web/src/**/*.{ts,tsx}"
---

## React & TypeScript Guidelines
- Use functional components with Hooks.
- Define component props using TypeScript interfaces.
- Use `React.FC` for component type definitions.
```

### Method 2: Workspace Settings (`settings.json`)

You can customize specific Copilot features (like commit message generation) by editing your workspace's `.vscode/settings.json` file.

**Reference: Custom Instruction Settings**

| Feature | Setting Name |
| :--- | :--- |
| Code Generation | `github.copilot.chat.codeGeneration.instructions` |
| Test Generation | `github.copilot.chat.testGeneration.instructions` |
| Code Review | `github.copilot.chat.reviewSelection.instructions` |
| Commit Messages | `github.copilot.chat.commitMessageGeneration.instructions` |
| Pull Requests | `github.copilot.chat.pullRequestDescriptionGeneration.instructions` |

**Example: `settings.json`**

This example customizes the style of generated commit messages.

```json
{
  "github.copilot.chat.commitMessageGeneration.instructions": [
    {
      "text": "Generate commit messages following the Conventional Commits specification. The message should be concise and start with a type (e.g., feat, fix, docs)."
    }
  ]
}
```

---

## Reusable Prompts: Prompt Files (`.prompt.md`)

Prompt files are different from instructions. They are **reusable, executable prompts** for common tasks, not passive context.

1.  **Location**: Store prompt files in the `.github/prompts` directory.
2.  **File Naming**: Use the `.prompt.md` suffix (e.g., `create-component.prompt.md`).
3.  **Usage**: Run them from the chat view by typing `/` followed by the prompt name.

### Example: `new-api-endpoint.prompt.md`

This prompt file can reference other files to provide context for the task.

```markdown
Generate a new FastAPI endpoint in a file named `${input:endpoint_name}.py`.

Refer to our standard Pydantic models defined in [libs/models/schemas.py](../libs/models/schemas.py).

The endpoint should include:
- A `POST` method.
- Request body validation using the appropriate Pydantic model.
- A call to the `create_item` service function.
```

---

## Best Practices for Writing Instructions

- **Be Direct and Imperative**: Use commands like "Use..." and "Avoid...".
- **Keep It Short**: Write concise, single-purpose rules.
- **Provide Context, Not Just Rules**: Explain the *why* when it's important (e.g., "Use `pydantic.BaseModel` for schema validation because we auto-generate OpenAPI docs").
- **Use Examples**: Provide small code snippets to illustrate correct and incorrect patterns.
- **Avoid Negations**: Tell Copilot what to do, not what *not* to do. Instead of "Don't use `var`," write "Use `let` and `const` for variable declarations."
