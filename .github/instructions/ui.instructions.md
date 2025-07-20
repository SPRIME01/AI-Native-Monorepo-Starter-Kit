---
applyTo: "apps/web/**/*.{tsx,css,scss}"
---

## UI & Styling Guidelines

### Tailwind CSS Usage

- Use design system tokens for consistent spacing and colors
- Implement responsive design mobile-first
- Create reusable component variants using cva (class-variance-authority)

### Accessibility

- Include proper ARIA labels and roles
- Ensure keyboard navigation support
- Maintain color contrast ratios

### How-to: Creating styled components

```tsx
// 1. Define component variants
const buttonVariants = cva("px-4 py-2 rounded", {
  variants: {
    variant: {
      primary: "bg-blue-600 text-white",
      secondary: "bg-gray-200 text-gray-900",
    },
  },
});

// 2. Implement component
export const Button = ({ variant, ...props }) => (
  <button className={buttonVariants({ variant })} {...props} />
);
```
