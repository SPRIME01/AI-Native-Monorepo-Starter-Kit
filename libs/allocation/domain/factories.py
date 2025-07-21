"""
Domain Entity Factories for Testing.
"""
from typing import Dict, Any, Optional
from libs.inventory.domain.entities.inventory_aggregate import InventoryAggregate
from libs.payments.domain.entities.payment import Payment


class InventoryEntityFactory:
    """Factory for creating inventory test entities."""

    def create(self, overrides: Optional[Dict[str, Any]] = None) -> InventoryAggregate:
        """Create an inventory aggregate with optional overrides."""
        defaults = {
            'item_id': 'ITEM001',
            'quantity': 100,
            'reserved_quantity': 0,
            'location': 'WAREHOUSE_A'
        }

        if overrides:
            defaults.update(overrides)

        return InventoryAggregate(**defaults)


class PaymentEntityFactory:
    """Factory for creating payment test entities."""

    def create(self, overrides: Optional[Dict[str, Any]] = None) -> Payment:
        """Create a payment entity with optional overrides."""
        defaults = {
            'amount': 100.0,
            'currency': 'USD'
        }

        if overrides:
            defaults.update(overrides)

        return Payment(**defaults)


class AllocationEntityFactory:
    """Factory for creating allocation test entities."""

    def create(self, overrides: Optional[Dict[str, Any]] = None) -> Dict[str, Any]:
        """Create allocation test data with optional overrides."""
        defaults = {
            'order_id': 'ORDER001',
            'sku': 'PRODUCT001',
            'quantity': 10,
            'batch_ref': 'BATCH001'
        }

        if overrides:
            defaults |= overrides

        return defaults
