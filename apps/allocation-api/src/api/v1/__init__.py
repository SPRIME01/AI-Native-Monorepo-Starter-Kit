"""API v1 router for allocation domain"""
from fastapi import APIRouter, Depends
from ...dependencies.allocation import get_allocation_service

router = APIRouter()

@router.get("/allocation")
async def list_allocations(service=Depends(get_allocation_service)):
    """List all allocations"""
    return await service.get_all()

@router.post("/allocation")
async def create_allocation(data: dict, service=Depends(get_allocation_service)):
    """Create new allocation"""
    return await service.create(data)
