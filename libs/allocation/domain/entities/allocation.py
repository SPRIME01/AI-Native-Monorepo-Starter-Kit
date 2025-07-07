"""
Allocation entity - Core business object for allocation domain
Pure domain logic with no external dependencies
"""
from dataclasses import dataclass
from datetime import datetime
from typing import Dict, Any, Optional
from uuid import uuid4

@dataclass
class Allocation:
    """Core allocation entity with business rules"""
    id: str
    sku: str
    quantity: int
    batch_ref: str
    allocated_at: datetime

    @classmethod
    def create(cls, sku: str, quantity: int, batch_ref: str) -> "Allocation":
        """Factory method with business validation"""
        if quantity <= 0:
            raise ValueError("Allocation quantity must be positive")
        if not sku.strip():
            raise ValueError("SKU cannot be empty")
        if not batch_ref.strip():
            raise ValueError("Batch reference cannot be empty")

        return cls(
            id=str(uuid4()),
            sku=sku.strip().upper(),
            quantity=quantity,
            batch_ref=batch_ref.strip(),
            allocated_at=datetime.utcnow()
        )

    def is_valid(self) -> bool:
        """Business rule: Check if allocation is valid"""
        return (
            self.quantity > 0
            and bool(self.sku.strip())
            and bool(self.batch_ref.strip())
        )

    def can_deallocate(self) -> bool:
        """Business rule: Check if allocation can be deallocated"""
        # Example: Can't deallocate if allocated more than 24 hours ago
        hours_since_allocation = (datetime.utcnow() - self.allocated_at).total_seconds() / 3600
        return hours_since_allocation < 24

    def to_dict(self) -> Dict[str, Any]:
        """Convert to dictionary for serialization"""
        return {
            "id": self.id,
            "sku": self.sku,
            "quantity": self.quantity,
            "batch_ref": self.batch_ref,
            "allocated_at": self.allocated_at.isoformat(),
            "is_valid": self.is_valid(),
            "can_deallocate": self.can_deallocate()
        }
