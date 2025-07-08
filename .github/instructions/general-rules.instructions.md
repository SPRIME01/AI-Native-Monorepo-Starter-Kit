---
applyTo: "**"
---

## Execution Rules

- Complete all parts of every request
- Create, modify, and delete files autonomously
- Read actual file content before making changes to ensure accuracy
- Reuse existing imports and helper functions to maintain consistency

## Validation Rules

- Check for syntax and compilation errors after changes
- Fix detected issues immediately
- Run builds or tests when applicable to verify functionality

## Code Quality Rules

- Follow project's existing code style and naming conventions
- Use consistent formatting throughout the codebase
- Implement clean, readable code structure

## Technical Debt Management Rules

- Actively identify technical debt in requests (code duplication, hardcoded values, missing error handling, poor naming, etc.)
- Explicitly address and remedy identified technical debt as part of the implementation
- Refactor existing code to improve maintainability when making changes
- Add proper error handling, logging, and validation where missing

## Clarity and Communication Rules

- When prompts are ambiguous or unclear, ask 1-2 specific clarifying questions
- Rephrase unclear requests and confirm understanding before proceeding
- If multiple interpretations are possible, present options and ask for selection
- Suggest better approaches when requests indicate potential issues

## Output Rules

- Provide working code without lengthy explanations
- Use direct commands for terminal operations
- Make reasonable assumptions instead of asking for permissions
- Flag technical debt found and remediation applied

## Workspace Management Rules

- Use `docs/.temp/.scratchpad/` for temporary files during complex tasks (todo lists, scripts, analysis)
- Create working documents to track progress on multi-step implementations
- Break down complex requests into manageable chunks with clear milestones
- Maintain context across tool calls by documenting decisions and state

## Workflow Rules

- For complex tasks, create a working plan in `.scratchpad/` before starting implementation
- Use temporary scripts and automation tools when beneficial for efficiency
- Track progress in markdown files to maintain context and avoid repetition
- Clean up temporary files after task completion unless they provide ongoing value

## Planning and Organization Rules

- Before starting multi-file changes, create a plan document outlining the approach
- Use `.scratchpad/` to prototype solutions and validate approaches
- Document assumptions and decisions that affect implementation
- Create reusable scripts for repetitive tasks

## Examples

**Good**: Read file before editing

```typescript
// Read current component structure first
const existingComponent = await readFile("./Component.tsx");
// Then make targeted changes
```

**Good**: Reuse existing patterns

```typescript
// Use existing error handling pattern
import { handleApiError } from "./utils/errorHandler";
```

**Good**: Technical debt identification

```typescript
// Before: Hardcoded values and no error handling
const API_URL = "https://api.example.com";
fetch(API_URL + "/users");

// After: Environment config and proper error handling
import { API_BASE_URL } from "./config";
import { handleApiError } from "./utils/errorHandler";
try {
  const response = await fetch(`${API_BASE_URL}/users`);
  if (!response.ok) throw new Error(`API Error: ${response.status}`);
} catch (error) {
  handleApiError(error);
}
```

**Good**: Clarification requests

- "I see you want to add authentication. Do you mean JWT token-based auth or session-based auth?"
- "Your request mentions 'update
