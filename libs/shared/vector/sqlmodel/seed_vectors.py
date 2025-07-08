from sqlmodel import Session, create_engine
from .vector_record import VectorRecord
from typing import List
import numpy as np
import os

DB_URL = os.getenv("SUPABASE_DB_URL", "postgresql://user:password@localhost:5432/postgres")
engine = create_engine(DB_URL)

example_vectors = [
    VectorRecord(id=f"vec_{i}", embedding=np.random.rand(1536).tolist(), metadata={"label": f"example_{i}"})
    for i in range(5)
]

def seed():
    with Session(engine) as session:
        for vec in example_vectors:
            session.add(vec)
        session.commit()

if __name__ == "__main__":
    seed()
    print("Seeded example vectors.")
