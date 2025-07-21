"""
Unit tests for allocation domain entity business rules.
"""
import pytest


from libs.allocation.domain.entities.allocation import Allocation
import uuid

def test_allocation_creation_valid():
    # Arrange
    allocation_data = {
        "id": uuid.uuid4(),
        "order_id": "ORDER-1",
        "product_id": "SKU-1",
        "quantity": 10,
        "status": "active"
    }
    # Act
    allocation = Allocation(**allocation_data)
    # Assert
    assert allocation.quantity > 0
    assert allocation.product_id == "SKU-1"
    assert allocation.is_valid()
