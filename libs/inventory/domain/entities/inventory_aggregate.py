"""
Inventory Aggregate Domain Entity.
"""
from dataclasses import dataclass
from typing import Optional


@dataclass
class InventoryAggregate:
    """Domain aggregate for inventory management."""

    item_id: str
    quantity: int
    reserved_quantity: int = 0
    location: Optional[str] = None

    def __post_init__(self):
        """Validate inventory constraints."""
        if self.quantity < 0:
            raise ValueError("Quantity cannot be negative")
        if self.reserved_quantity < 0:
            raise ValueError("Reserved quantity cannot be negative")
        if self.reserved_quantity > self.quantity:
            raise ValueError("Reserved quantity cannot exceed total quantity")

    def is_valid(self) -> bool:
        """Check if the aggregate is in a valid state."""
        return (
            self.quantity >= 0 and
            self.reserved_quantity >= 0 and
            self.reserved_quantity <= self.quantity
        )

    def allocate(self, quantity: int) -> None:
        """Allocate inventory quantity."""
        if quantity <= 0:
            raise ValueError("Allocation quantity must be positive")
        if quantity > self.available_quantity:
            raise ValueError("Insufficient available quantity")

        self.reserved_quantity += quantity

    def deallocate(self, quantity: int) -> None:
        """Deallocate inventory quantity."""
        if quantity <= 0:
            raise ValueError("Deallocation quantity must be positive")
        if quantity > self.reserved_quantity:
            raise ValueError("Cannot deallocate more than reserved")

        self.reserved_quantity -= quantity

    def fulfill(self, quantity: int) -> None:
        """Fulfill allocated inventory (reduce total quantity)."""
        if quantity <= 0:
            raise ValueError("Fulfillment quantity must be positive")
        if quantity > self.reserved_quantity:
            raise ValueError("Cannot fulfill more than reserved")

        self.quantity -= quantity
        self.reserved_quantity -= quantity

    @property
    def available_quantity(self) -> int:
        """Get available (non-reserved) quantity."""
        return self.quantity - self.reserved_quantity
