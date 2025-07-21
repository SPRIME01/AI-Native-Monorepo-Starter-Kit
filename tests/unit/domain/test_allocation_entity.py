"""
Unit tests for allocation domain entity business rules.
"""
import pytest

# Example stub: Replace with actual Allocation entity import and logic
def test_allocation_creation_valid():
    # Arrange
    allocation_data = {"id": 1, "quantity": 10, "sku": "SKU-1"}
    # Act
    allocation = allocation_data  # Replace with Allocation(**allocation_data)
    # Assert
    assert allocation["quantity"] > 0
    assert allocation["sku"] == "SKU-1"
