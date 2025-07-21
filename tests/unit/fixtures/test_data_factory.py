"""
Test data factory framework for domain and application testing.
Implements TestDataFactory, DomainEntityFactory, and TestDataSpec.
"""
from abc import ABC, abstractmethod
from typing import Dict, Any, List, TypeVar, Generic
from dataclasses import dataclass
from enum import Enum

T = TypeVar('T')

class TestDataType(Enum):
    MINIMAL = "minimal"
    COMPLETE = "complete"
    INVALID = "invalid"
    EDGE_CASE = "edge_case"

@dataclass
class TestDataSpec:
    data_type: TestDataType
    overrides: Dict[str, Any] = None
    constraints: Dict[str, Any] = None

class TestDataFactory(Generic[T], ABC):
    @abstractmethod
    def create(self, spec: TestDataSpec = None) -> T:
        pass

    @abstractmethod
    def create_batch(self, count: int, spec: TestDataSpec = None) -> List[T]:
        pass

    @abstractmethod
    def create_invalid(self, violation_type: str) -> T:
        pass

# Example domain entity factory stub (to be extended per domain)
class DomainEntityFactory(TestDataFactory):
    def create(self, spec: TestDataSpec = None):
        # Implement domain-specific creation logic
        return {}
    def create_batch(self, count: int, spec: TestDataSpec = None):
        return [{} for _ in range(count)]
    def create_invalid(self, violation_type: str):
        return {"invalid": violation_type}
