"""
Mock builder framework for systematic dependency mocking in tests.
Implements MockBuilder and ServiceMockBuilder utilities.
"""
from unittest.mock import Mock, MagicMock, patch
from typing import Type, Dict, Any, Callable, List
from contextlib import contextmanager

from tests.unit.utils.mock_builders import MockBuilder

# Example stub for service mock builder (extend as needed)
class ServiceMockBuilder(MockBuilder):
    def build_allocation_service_mocks(self) -> Dict[str, Mock]:
        # Replace with actual repo/service classes as needed
        return {
            'allocation_repository': self.mock_repository(type('AllocationRepository', (), {})),
            'inventory_service': self.mock_external_service(type('InventoryService', (), {})),
            'event_publisher': self.mock_external_service(type('EventPublisher', (), {})),
        }
