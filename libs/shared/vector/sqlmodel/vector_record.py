from typing import List, Dict, Any
from datetime import datetime
from sqlmodel import SQLModel, Field, Column, JSON
from sqlalchemy import func
from sqlalchemy.dialects.postgresql import ARRAY
from sqlalchemy_utils import ScalarListType

class VectorRecord(SQLModel, table=True):
    __tablename__ = "vectors"

    id: str = Field(primary_key=True)
    embedding: List[float] = Field(sa_column=Column(ARRAY(float)))  # pgvector: use extension in migration
    metadata: Dict[str, Any] = Field(default_factory=dict, sa_column=Column(JSON))
    created_at: datetime = Field(default_factory=datetime.utcnow, sa_column=Column(default=func.now()))
