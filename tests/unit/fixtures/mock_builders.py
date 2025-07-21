"""
Mock builder framework for systematic dependency mocking in tests.
Implements MockBuilder and ServiceMockBuilder utilities.
"""
from unittest.mock import Mock, MagicMock, patch
from typing import Type, Dict, Any, Callable, List
from contextlib import contextmanager

class MockBuilder:
    def __init__(self):
        self._mocks: Dict[str, Mock] = {}
        self._patches: List[Any] = []

    def mock_repository(self, repo_class: Type) -> Mock:
        mock = MagicMock(spec=repo_class)
        self._mocks[repo_class.__name__] = mock
        return mock

    def mock_external_service(self, service_class: Type) -> Mock:
        mock = MagicMock(spec=service_class)
        self._mocks[service_class.__name__] = mock
        return mock

    def mock_database_client(self) -> Mock:
        mock = MagicMock()
        mock.table.return_value = MagicMock()
        return mock

    @contextmanager
    def patch_dependencies(self, target_module: str):
        with patch.multiple(target_module, **self._mocks):
            yield

# Example stub for service mock builder (extend as needed)
class ServiceMockBuilder(MockBuilder):
    def build_allocation_service_mocks(self) -> Dict[str, Mock]:
        # Replace with actual repo/service classes as needed
        return {
            'allocation_repository': self.mock_repository(type('AllocationRepository', (), {})),
            'inventory_service': self.mock_external_service(type('InventoryService', (), {})),
            'event_publisher': self.mock_external_service(type('EventPublisher', (), {})),
        }
