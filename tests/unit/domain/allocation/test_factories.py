"""
Unit tests for Allocation, Payment, and Inventory Entity Factories.
"""
import pytest
from libs.allocation.domain.factories import AllocationEntityFactory, PaymentEntityFactory, InventoryEntityFactory
from libs.payments.domain.entities.payment import Payment
from libs.inventory.domain.entities.inventory_aggregate import InventoryAggregate

class TestAllocationEntityFactory:
    def test_create_default(self):
        factory = AllocationEntityFactory()
        entity = factory.create()
        assert isinstance(entity, dict)
        assert entity['order_id'] == 'ORDER001'
        assert entity['sku'] == 'PRODUCT001'
        assert entity['quantity'] == 10
        assert entity['batch_ref'] == 'BATCH001'

    def test_create_with_overrides(self):
        factory = AllocationEntityFactory()
        entity = factory.create(overrides={'order_id': 'ORDER999', 'quantity': 99})
        assert entity['order_id'] == 'ORDER999'
        assert entity['quantity'] == 99
        assert entity['sku'] == 'PRODUCT001'  # Unchanged

class TestPaymentEntityFactory:
    def test_create_default(self):
        factory = PaymentEntityFactory()
        payment = factory.create()
        assert isinstance(payment, Payment)
        assert payment.amount == 100.0
        assert payment.currency == 'USD'

    def test_create_with_overrides(self):
        factory = PaymentEntityFactory()
        payment = factory.create(overrides={'amount': 42.5, 'currency': 'EUR'})
        assert payment.amount == 42.5
        assert payment.currency == 'EUR'

class TestInventoryEntityFactory:
    def test_create_default(self):
        factory = InventoryEntityFactory()
        inventory = factory.create()
        assert isinstance(inventory, InventoryAggregate)
        assert inventory.item_id == 'ITEM001'
        assert inventory.quantity == 100
        assert inventory.reserved_quantity == 0
        assert inventory.location == 'WAREHOUSE_A'
        assert inventory.is_valid()

    def test_create_with_overrides(self):
        factory = InventoryEntityFactory()
        inventory = factory.create(overrides={'item_id': 'ITEM999', 'quantity': 5, 'reserved_quantity': 2, 'location': 'WAREHOUSE_B'})
        assert inventory.item_id == 'ITEM999'
        assert inventory.quantity == 5
        assert inventory.reserved_quantity == 2
        assert inventory.location == 'WAREHOUSE_B'
        assert inventory.is_valid()

    def test_create_with_invalid_quantity(self):
        factory = InventoryEntityFactory()
        with pytest.raises(ValueError):
            factory.create(overrides={'quantity': -1})

    def test_create_with_reserved_gt_quantity(self):
        factory = InventoryEntityFactory()
        with pytest.raises(ValueError):
            factory.create(overrides={'quantity': 1, 'reserved_quantity': 2})
