---
applyTo: "**/tests/**/*.{py,ts,tsx}"
---

## Testing Guidelines

### Python Testing (pytest)

- Achieve 90%+ code coverage
- Use fixtures for test data setup
- Implement integration tests for API endpoints

### TypeScript Testing (Jest/Vitest)

- Test components using React Testing Library
- Mock external dependencies properly
- Test user interactions, not implementation details

### How-to: Writing effective tests

```python
# Python: Use descriptive test names and arrange-act-assert pattern
def test_create_user_returns_201_when_valid_data_provided():
    # Arrange
    user_data = {"name": "John", "email": "john@example.com"}

    # Act
    response = client.post("/users", json=user_data)

    # Assert
    assert response.status_code == 201
```
