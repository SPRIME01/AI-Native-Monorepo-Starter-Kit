"""Dependency injection for allocation domain"""
from libs.allocation.application.allocation_service import AllocationService
from libs.allocation.adapters.memory_adapter import MemoryAllocationAdapter

def get_allocation_service() -> AllocationService:
    """Get allocation service with injected dependencies"""
    repository = MemoryAllocationAdapter()
    return AllocationService(repository)
