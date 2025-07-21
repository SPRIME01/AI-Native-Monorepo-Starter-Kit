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

from typing import Type, Callable

class DomainEntityFactory(TestDataFactory[T]):
    def __init__(self, entity_cls: Type[T], default_factory: Callable[..., T]):
        self.entity_cls = entity_cls
        self.default_factory = default_factory

    def create(self, spec: TestDataSpec = None) -> T:
        # Use default_factory and apply overrides if provided
        kwargs = {}
        if spec and spec.overrides:
            kwargs.update(spec.overrides)
        return self.default_factory(**kwargs)

    def create_batch(self, count: int, spec: TestDataSpec = None) -> List[T]:
        return [self.create(spec) for _ in range(count)]

    def create_invalid(self, violation_type: str) -> T:
        # Create a valid instance first, then modify it to be invalid
        # This approach depends on the specific domain entity
        # Consider making this method abstract or providing entity-specific invalid data
        raise NotImplementedError("create_invalid should be implemented by specific domain factories")
