"""Dependency injection for invoicing domain"""
from libs.invoicing.application.invoicing_service import InvoicingService
from libs.invoicing.adapters.memory_adapter import MemoryInvoicingAdapter

def get_invoicing_service() -> InvoicingService:
    """Get invoicing service with injected dependencies"""
    repository = MemoryInvoicingAdapter()
    return InvoicingService(repository)
