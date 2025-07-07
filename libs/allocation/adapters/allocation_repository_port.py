"""
Allocation repository port - Interface for data persistence
Defines the contract without implementation details
"""
from abc import ABC, abstractmethod
from typing import List, Optional
from ..domain.entities.allocation import Allocation

class AllocationRepositoryPort(ABC):
    """Port defining data access contract for allocation domain"""

    @abstractmethod
    async def find_all(self) -> List[Allocation]:
        """Find all allocations"""
        pass

    @abstractmethod
    async def find_by_id(self, allocation_id: str) -> Optional[Allocation]:
        """Find allocation by ID"""
        pass

    @abstractmethod
    async def find_by_sku(self, sku: str) -> List[Allocation]:
        """Find allocations by SKU"""
        pass

    @abstractmethod
    async def find_by_batch_ref(self, batch_ref: str) -> List[Allocation]:
        """Find allocations by batch reference"""
        pass

    @abstractmethod
    async def save(self, allocation: Allocation) -> Allocation:
        """Save allocation"""
        pass

    @abstractmethod
    async def delete(self, allocation_id: str) -> bool:
        """Delete allocation by ID"""
        pass
