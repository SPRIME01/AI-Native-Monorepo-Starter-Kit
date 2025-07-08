from fastapi import APIRouter, HTTPException
from sqlmodel import Session, select
from .vector_record import VectorRecord
from typing import List

router = APIRouter()

@router.post("/vectors/", response_model=VectorRecord)
def create_vector(vector: VectorRecord, session: Session):
    session.add(vector)
    session.commit()
    session.refresh(vector)
    return vector

@router.get("/vectors/{vector_id}", response_model=VectorRecord)
def get_vector(vector_id: str, session: Session):
    vector = session.get(VectorRecord, vector_id)
    if not vector:
        raise HTTPException(status_code=404, detail="Vector not found")
    return vector

@router.get("/vectors/", response_model=List[VectorRecord])
def list_vectors(session: Session):
    return session.exec(select(VectorRecord)).all()
