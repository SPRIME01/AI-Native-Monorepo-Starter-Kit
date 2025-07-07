"""Dependency injection for payments domain"""
from libs.payments.application.payments_service import PaymentsService
from libs.payments.adapters.memory_adapter import MemoryPaymentsAdapter

def get_payments_service() -> PaymentsService:
    """Get payments service with injected dependencies"""
    repository = MemoryPaymentsAdapter()
    return PaymentsService(repository)
