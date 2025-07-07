---
applyTo: "libs/database/**/*.py"
---

## Database & Schema Guidelines

### SQLModel Models

- Use SQLModel for all models (inherits from both Pydantic and SQLAlchemy)
- Define models as subclasses of SQLModel
- Use type annotations for all fields
- Implement proper relationships using `Relationship`
- Add indexes and unique constraints using SQLModel field options

### Migrations

- Use Alembic for migrations (with SQLModel integration)
- Create descriptive migration names
- Always include both upgrade and downgrade functions
- Test migrations on sample data

### How-to: Creating a database model

```python
from sqlmodel import SQLModel, Field
from typing import Optional
from datetime import datetime

# 1. Define model with proper typing
class User(SQLModel, table=True):
    id: Optional[int] = Field(default=None, primary_key=True)
    email: str = Field(index=True, unique=True, max_length=255)
    created_at: datetime = Field(default_factory=datetime.utcnow)

# 2. Generate migration (with Alembic)
alembic revision --autogenerate -m "Add user table"
```
