"""
Domain Fixtures

This module provides reusable test fixtures for domain layer testing, including
factories for creating domain entities and value objects. These fixtures are
designed to simplify test setup and improve maintainability by providing
consistent and realistic test data.

Fixtures:
- domain_factory: Provides a factory for creating domain entities with various
                  configurations, such as minimal, complete, or invalid data.
- allocation_entity_factory: A specialized factory for creating allocation
                             domain entities for testing purposes.
- payment_entity_factory: A specialized factory for creating payment domain
                          entities, ensuring proper test data generation.
- inventory_entity_factory: A factory for generating inventory domain
                            entities with controlled test data variations.
"""

import pytest
from libs.allocation.domain.factories import (
    AllocationEntityFactory,
    PaymentEntityFactory,
    InventoryEntityFactory,
)

@pytest.fixture
def allocation_entity_factory() -> AllocationEntityFactory:
    """
    Provides a factory for creating allocation domain entities.

    This fixture returns an instance of AllocationEntityFactory, which can be used
    to generate allocation entities with different data specifications (e.g.,
    minimal, complete, invalid). It simplifies the setup for allocation-related
    domain tests by providing a consistent way to create test data.

    Returns:
        AllocationEntityFactory: An instance of the allocation entity factory.
    """
    return AllocationEntityFactory()

@pytest.fixture
def payment_entity_factory() -> PaymentEntityFactory:
    """
    Provides a factory for creating payment domain entities.

    This fixture returns an instance of PaymentEntityFactory, which is responsible
    for generating payment entities for testing. It supports creating entities
    with various data configurations, making it easier to test payment-related
    business logic and validation rules.

    Returns:
        PaymentEntityFactory: An instance of the payment entity factory.
    """
    return PaymentEntityFactory()

@pytest.fixture
def inventory_entity_factory() -> InventoryEntityFactory:
    """
    Provides a factory for creating inventory domain entities.

    This fixture returns an instance of InventoryEntityFactory, which allows for
    the creation of inventory entities with controlled test data. It is useful
    for testing inventory management logic, including stock levels, reservations,
    and business rule enforcement.

    Returns:
        InventoryEntityFactory: An instance of the inventory entity factory.
    """
    return InventoryEntityFactory()
