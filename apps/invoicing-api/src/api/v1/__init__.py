"""API v1 router for invoicing domain"""
from fastapi import APIRouter, Depends
from ...dependencies.invoicing import get_invoicing_service

router = APIRouter()

@router.get("/invoicing")
async def list_invoicings(service=Depends(get_invoicing_service)):
    """List all invoicings"""
    return await service.get_all()

@router.post("/invoicing")
async def create_invoicing(data: dict, service=Depends(get_invoicing_service)):
    """Create new invoicing"""
    return await service.create(data)
