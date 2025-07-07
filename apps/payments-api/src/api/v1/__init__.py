"""API v1 router for payments domain"""
from fastapi import APIRouter, Depends
from ...dependencies.payments import get_payments_service

router = APIRouter()

@router.get("/payments")
async def list_paymentss(service=Depends(get_payments_service)):
    """List all paymentss"""
    return await service.get_all()

@router.post("/payments")
async def create_payments(data: dict, service=Depends(get_payments_service)):
    """Create new payments"""
    return await service.create(data)
