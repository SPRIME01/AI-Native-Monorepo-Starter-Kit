"""
Unit tests for the Inventory Aggregate.
"""

import pytest
from libs.inventory.domain.entities.inventory_aggregate import InventoryAggregate


class TestInventoryAggregate:
    def test_allocate_zero_quantity_raises(self):
        """Test that allocating zero quantity raises ValueError."""
        aggregate = InventoryAggregate(
            item_id="ITEM001",
            quantity=100,
            reserved_quantity=0,
            location="WAREHOUSE_A"
        )
        with pytest.raises(ValueError, match="Allocation quantity must be positive"):
            aggregate.allocate(quantity=0)

    def test_allocate_negative_quantity_raises(self):
        """Test that allocating negative quantity raises ValueError."""
        aggregate = InventoryAggregate(
            item_id="ITEM001",
            quantity=100,
            reserved_quantity=0,
            location="WAREHOUSE_A"
        )
        with pytest.raises(ValueError, match="Allocation quantity must be positive"):
            aggregate.allocate(quantity=-10)

    def test_allocate_zero_quantity_raises(self):
        """Test that allocating zero quantity raises ValueError."""
        aggregate = InventoryAggregate(
            item_id="ITEM001",
            quantity=100,
            reserved_quantity=0,
            location="WAREHOUSE_A"
        )
        with pytest.raises(ValueError, match="Allocation quantity must be positive"):
            aggregate.allocate(quantity=0)

    def test_allocate_negative_quantity_raises(self):
        """Test that allocating negative quantity raises ValueError."""
        aggregate = InventoryAggregate(
            item_id="ITEM001",
            quantity=100,
            reserved_quantity=0,
            location="WAREHOUSE_A"
        )
        with pytest.raises(ValueError, match="Allocation quantity must be positive"):
            aggregate.allocate(quantity=-10)

    def test_creation_with_negative_reserved_quantity_raises_error(self):
        """Test that creating with negative reserved_quantity raises an error."""
        with pytest.raises(ValueError, match="Reserved quantity cannot be negative"):
            InventoryAggregate(
                item_id="ITEM001",
                quantity=10,
                reserved_quantity=-5,
                location="WAREHOUSE_A"
            )

    def test_creation_with_reserved_quantity_greater_than_quantity_raises_error(self):
        """Test that creating with reserved_quantity greater than quantity raises an error."""
        with pytest.raises(ValueError, match="Reserved quantity cannot exceed total quantity"):
            InventoryAggregate(
                item_id="ITEM001",
                quantity=5,
                reserved_quantity=10,
                location="WAREHOUSE_A"
            )

    def test_creation_with_valid_data(self):
        """Test creating an aggregate with valid data."""
        aggregate = InventoryAggregate(
            item_id="ITEM001",
            quantity=100,
            reserved_quantity=0,
            location="WAREHOUSE_A"
        )
        assert isinstance(aggregate, InventoryAggregate)
        assert aggregate.is_valid()

    def test_creation_with_negative_quantity_raises_error(self):
        """Test that creating with negative quantity raises an error."""
        with pytest.raises(ValueError, match="Quantity cannot be negative"):
            InventoryAggregate(
                item_id="ITEM001",
                quantity=-10,
                reserved_quantity=0,
                location="WAREHOUSE_A"
            )

    def test_allocate_reduces_available_quantity(self):
        """Test that allocating increases reserved quantity."""
        aggregate = InventoryAggregate(
            item_id="ITEM001",
            quantity=100,
            reserved_quantity=0,
            location="WAREHOUSE_A"
        )
        aggregate.allocate(quantity=30)
        assert aggregate.reserved_quantity == 30
        assert aggregate.available_quantity == 70

    def test_cannot_allocate_more_than_available(self):
        """Test that allocating more than available quantity raises an error."""
        aggregate = InventoryAggregate(
            item_id="ITEM001",
            quantity=10,
            reserved_quantity=0,
            location="WAREHOUSE_A"
        )
        with pytest.raises(ValueError, match="Insufficient available quantity"):
            aggregate.allocate(quantity=20)

    def test_deallocate_functionality(self):
        """Test deallocation functionality."""
        aggregate = InventoryAggregate(
            item_id="ITEM001",
            quantity=100,
            reserved_quantity=30,
            location="WAREHOUSE_A"
        )
        aggregate.deallocate(quantity=10)
        assert aggregate.reserved_quantity == 20
        assert aggregate.available_quantity == 80

    def test_fulfill_functionality(self):
        """Test fulfillment functionality."""
        aggregate = InventoryAggregate(
            item_id="ITEM001",
            quantity=100,
            reserved_quantity=30,
            location="WAREHOUSE_A"
        )
        aggregate.fulfill(quantity=10)
        assert aggregate.quantity == 90
        assert aggregate.reserved_quantity == 20
        assert aggregate.available_quantity == 70

    def test_fulfill_with_zero_quantity_raises(self):
        """Test that fulfilling with zero quantity raises ValueError."""
        aggregate = InventoryAggregate(
            item_id="ITEM001",
            quantity=100,
            reserved_quantity=30,
            location="WAREHOUSE_A"
        )
        with pytest.raises(ValueError, match="Fulfillment quantity must be positive"):
            aggregate.fulfill(quantity=0)

    def test_fulfill_with_negative_quantity_raises(self):
        """Test that fulfilling with negative quantity raises ValueError."""
        aggregate = InventoryAggregate(
            item_id="ITEM001",
            quantity=100,
            reserved_quantity=30,
            location="WAREHOUSE_A"
        )
        with pytest.raises(ValueError, match="Fulfillment quantity must be positive"):
            aggregate.fulfill(quantity=-5)

    def test_fulfill_with_excessive_quantity_raises(self):
        """Test that fulfilling with more than reserved quantity raises ValueError."""
        aggregate = InventoryAggregate(
            item_id="ITEM001",
            quantity=100,
            reserved_quantity=30,
            location="WAREHOUSE_A"
        )
        with pytest.raises(ValueError, match="Cannot fulfill more than reserved"):
            aggregate.fulfill(quantity=40)
