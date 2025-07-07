---
applyTo: "apps/api/**/*.py"
---

## FastAPI & Python Guidelines

### API Design

- Use Pydantic models for all request/response schemas
- Implement proper HTTP status codes and error handling
- Add OpenAPI documentation with examples

### Database Operations

- Use SQLModel for all database models and operations
- Use async database sessions with SQLModel
- Implement proper transaction management
- Add database migrations using Alembic (with SQLModel integration)

### How-to: Creating a new API endpoint

```python
from sqlmodel import SQLModel, Field, Session, select
from typing import Optional
from fastapi import APIRouter, Depends
from app.db import get_session

# 1. Define SQLModel models
class Item(SQLModel, table=True):
    id: Optional[int] = Field(default=None, primary_key=True)
    name: str
    description: Optional[str] = None

# 2. Implement endpoint with proper typing
router = APIRouter()

@router.post("/items", response_model=Item, status_code=201)
async def create_item(item: Item, session: Session = Depends(get_session)):
    session.add(item)
    session.commit()
    session.refresh(item)
    return item
```
