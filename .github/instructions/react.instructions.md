---
applyTo: "apps/web/**/*.{ts,tsx,js,jsx}"
---

## React & TypeScript Guidelines

### Component Structure

- Use functional components with TypeScript interfaces for props
- Implement proper error boundaries for production reliability
- Use React.memo() for performance optimization when needed

### State Management

- Use React Query for server state management
- Use Zustand for client state management
- Implement proper loading and error states

### How-to: Creating a new React component

```typescript
// 1. Define props interface first
interface ComponentProps {
  title: string;
  onAction: () => void;
}

// 2. Implement component with proper typing
export const Component: React.FC<ComponentProps> = ({ title, onAction }) => {
  // Component logic
};
```
