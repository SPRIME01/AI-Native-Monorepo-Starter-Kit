# Design Document

## Overview

This design establishes a comprehensive unit testing foundation for the AI-Native Monorepo Starter Kit using pytest as the primary testing framework. The solution provides structured testing patterns, reusable fixtures, comprehensive mocking utilities, and automated coverage reporting. The design follows hexagonal architecture principles to ensure proper isolation between domain, application, and infrastructure layers while maintaining high test quality and maintainability.

## Architecture

### Testing Architecture Layers

```
┌─────────────────────────────────────────────────────────────┐
│                    Unit Test Suite                          │
├─────────────────────────────────────────────────────────────┤
│  Domain Tests │ Application Tests │ Infrastructure Tests    │
├─────────────────────────────────────────────────────────────┤
│              Test Utilities & Fixtures                     │
├─────────────────────────────────────────────────────────────┤
│    Mocking Framework │ Test Factories │ Coverage Tools     │
├─────────────────────────────────────────────────────────────┤
│              Pytest Framework & Plugins                    │
├─────────────────────────────────────────────────────────────┤
│                  Application Code                           │
└─────────────────────────────────────────────────────────────┘
```

### Test Organization Structure

```
tests/unit/
├── conftest.py                     # Global pytest configuration
├── fixtures/
│   ├── domain_fixtures.py          # Domain entity fixtures
│   ├── application_fixtures.py     # Application service fixtures
│   ├── infrastructure_fixtures.py  # Infrastructure component fixtures
│   └── test_data_factory.py        # Test data generation
├── domain/
│   ├── allocation/
│   │   ├── test_allocation_entity.py
│   │   ├── test_allocation_policies.py
│   │   └── test_allocation_rules.py
│   ├── payments/
│   │   ├── test_payment_entity.py
│   │   └── test_payment_value_objects.py
│   ├── inventory/
│   │   └── test_inventory_aggregate.py
│   └── shared/
│       └── test_domain_events.py
├── application/
│   ├── allocation/
│   │   └── test_allocation_service.py
│   ├── payments/
│   │   └── test_payment_service.py
│   └── shared/
│       └── test_use_case_base.py
├── infrastructure/
│   ├── data_access/
│   │   ├── test_supabase_client.py
│   │   └── test_repository_base.py
│   ├── observability/
│   │   ├── test_logging.py
│   │   ├── test_metrics.py
│   │   └── test_tracing.py
│   └── vector/
│       ├── test_embedding_service.py
│       ├── test_vector_adapters.py
│       └── test_similarity_search.py
└── utils/
    ├── test_helpers.py
    ├── mock_builders.py
    ├── property_testing.py
    └── coverage_utils.py
```

## Components and Interfaces

### Test Data Factory

```python
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

class DomainEntityFactory(TestDataFactory[T]):
    def create_allocation(self, spec: TestDataSpec = None) -> 'Allocation':
        pass
    
    def create_payment(self, spec: TestDataSpec = None) -> 'Payment':
        pass
    
    def create_inventory_item(self, spec: TestDataSpec = None) -> 'InventoryItem':
        pass
```

### Mock Builder Framework

```python
from unittest.mock import Mock, MagicMock, patch
from typing import Type, Dict, Any, Callable
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

class ServiceMockBuilder(MockBuilder):
    def build_allocation_service_mocks(self) -> Dict[str, Mock]:
        return {
            'allocation_repository': self.mock_repository(AllocationRepository),
            'inventory_service': self.mock_external_service(InventoryService),
            'event_publisher': self.mock_external_service(EventPublisher)
        }
```

### Test Fixture Framework

```python
import pytest
from typing import Generator, Any
from libs.shared.data_access.supabase.client import get_supabase_client

@pytest.fixture(scope="session")
def test_database():
    """Provides isolated test database instance"""
    # Setup test database
    db_client = get_supabase_client()
    yield db_client
    # Cleanup test data

@pytest.fixture(scope="function")
def clean_database(test_database):
    """Ensures clean database state for each test"""
    yield test_database
    # Cleanup after each test

@pytest.fixture
def domain_factory() -> DomainEntityFactory:
    """Provides domain entity factory for test data creation"""
    return DomainEntityFactory()

@pytest.fixture
def mock_builder() -> MockBuilder:
    """Provides mock builder for dependency mocking"""
    return MockBuilder()

@pytest.fixture
def allocation_service_mocks(mock_builder):
    """Provides pre-configured mocks for allocation service testing"""
    return mock_builder.build_allocation_service_mocks()
```

### Property-Based Testing Framework

```python
from hypothesis import given, strategies as st, settings, assume
from hypothesis.stateful import RuleBasedStateMachine, rule, invariant
from typing import Any, List

class DomainPropertyTesting:
    @staticmethod
    def valid_email_strategy():
        return st.emails()
    
    @staticmethod
    def valid_money_strategy():
        return st.builds(
            Money,
            amount=st.decimals(min_value=0, max_value=1000000, places=2),
            currency=st.sampled_from(['USD', 'EUR', 'GBP'])
        )
    
    @staticmethod
    def valid_allocation_strategy():
        return st.builds(
            Allocation,
            id=st.uuids(),
            quantity=st.integers(min_value=1, max_value=1000),
            sku=st.text(min_size=3, max_size=20)
        )

class AllocationStateMachine(RuleBasedStateMachine):
    def __init__(self):
        super().__init__()
        self.allocations = []
    
    @rule(allocation=DomainPropertyTesting.valid_allocation_strategy())
    def add_allocation(self, allocation):
        self.allocations.append(allocation)
    
    @rule()
    def remove_allocation(self):
        assume(len(self.allocations) > 0)
        self.allocations.pop()
    
    @invariant()
    def total_quantity_non_negative(self):
        total = sum(a.quantity for a in self.allocations)
        assert total >= 0
```

## Data Models

### Test Configuration Model

```python
from dataclasses import dataclass
from typing import Dict, List, Optional
from enum import Enum

class TestLevel(Enum):
    UNIT = "unit"
    INTEGRATION = "integration"
    E2E = "e2e"

class CoverageType(Enum):
    LINE = "line"
    BRANCH = "branch"
    FUNCTION = "function"

@dataclass
class TestConfig:
    test_level: TestLevel
    coverage_threshold: float
    coverage_types: List[CoverageType]
    parallel_execution: bool
    timeout_seconds: int
    retry_count: int
    
@dataclass
class MockConfig:
    auto_spec: bool = True
    strict_mode: bool = True
    call_tracking: bool = True
    return_value_validation: bool = True

@dataclass
class FixtureConfig:
    scope: str = "function"
    auto_cleanup: bool = True
    isolation_level: str = "strict"
    data_persistence: bool = False
```

### Test Result Model

```python
from dataclasses import dataclass
from datetime import datetime
from typing import List, Dict, Optional, Any
from enum import Enum

class TestStatus(Enum):
    PASSED = "passed"
    FAILED = "failed"
    SKIPPED = "skipped"
    ERROR = "error"

@dataclass
class TestMetrics:
    execution_time: float
    memory_usage: Optional[float]
    assertions_count: int
    mock_calls_count: int
    coverage_percentage: float

@dataclass
class TestResult:
    test_name: str
    test_file: str
    status: TestStatus
    metrics: TestMetrics
    error_message: Optional[str] = None
    stack_trace: Optional[str] = None
    
@dataclass
class TestSuiteResult:
    suite_name: str
    start_time: datetime
    end_time: datetime
    total_tests: int
    results: List[TestResult]
    overall_coverage: float
    
    @property
    def passed_tests(self) -> int:
        return len([r for r in self.results if r.status == TestStatus.PASSED])
    
    @property
    def failed_tests(self) -> int:
        return len([r for r in self.results if r.status == TestStatus.FAILED])
```

## Error Handling

### Test Error Classification

```python
from enum import Enum
from typing import Dict, Any, Optional

class TestErrorCategory(Enum):
    ASSERTION_FAILURE = "assertion_failure"
    MOCK_CONFIGURATION = "mock_configuration"
    FIXTURE_SETUP = "fixture_setup"
    DATA_GENERATION = "data_generation"
    DEPENDENCY_INJECTION = "dependency_injection"
    RESOURCE_CLEANUP = "resource_cleanup"

class TestErrorHandler:
    def __init__(self):
        self.error_handlers: Dict[TestErrorCategory, Callable] = {
            TestErrorCategory.ASSERTION_FAILURE: self._handle_assertion_failure,
            TestErrorCategory.MOCK_CONFIGURATION: self._handle_mock_error,
            TestErrorCategory.FIXTURE_SETUP: self._handle_fixture_error,
        }
    
    def handle_error(self, error: Exception, category: TestErrorCategory) -> Dict[str, Any]:
        handler = self.error_handlers.get(category, self._handle_generic_error)
        return handler(error)
    
    def _handle_assertion_failure(self, error: AssertionError) -> Dict[str, Any]:
        return {
            'category': 'assertion_failure',
            'message': str(error),
            'suggestion': 'Review test expectations and actual behavior',
            'debug_info': self._extract_assertion_context(error)
        }
```

### Test Isolation and Cleanup

```python
import pytest
from contextlib import contextmanager
from typing import Generator, Any, List

class TestIsolationManager:
    def __init__(self):
        self._cleanup_tasks: List[Callable] = []
        self._isolated_resources: Dict[str, Any] = {}
    
    @contextmanager
    def isolated_test_environment(self) -> Generator[Dict[str, Any], None, None]:
        try:
            # Setup isolated environment
            env = self._create_isolated_environment()
            yield env
        finally:
            # Cleanup resources
            self._cleanup_environment()
    
    def register_cleanup(self, cleanup_func: Callable):
        self._cleanup_tasks.append(cleanup_func)
    
    def _create_isolated_environment(self) -> Dict[str, Any]:
        return {
            'database': self._create_test_database(),
            'cache': self._create_test_cache(),
            'filesystem': self._create_test_filesystem()
        }
    
    def _cleanup_environment(self):
        for cleanup_task in reversed(self._cleanup_tasks):
            try:
                cleanup_task()
            except Exception as e:
                # Log cleanup errors but don't fail tests
                pytest.fail(f"Cleanup failed: {e}")
```

## Testing Strategy

### Test Categories and Patterns

#### 1. Domain Layer Testing (Requirements 1)
```python
# Entity Testing Pattern
class TestAllocationEntity:
    def test_create_allocation_with_valid_data(self, domain_factory):
        # Arrange
        allocation_data = domain_factory.create(TestDataType.COMPLETE)
        
        # Act
        allocation = Allocation(**allocation_data)
        
        # Assert
        assert allocation.is_valid()
        assert allocation.quantity > 0
    
    @given(DomainPropertyTesting.valid_allocation_strategy())
    def test_allocation_invariants(self, allocation):
        # Property-based testing for domain invariants
        assert allocation.quantity >= 0
        assert allocation.sku is not None
```

#### 2. Application Layer Testing (Requirements 2)
```python
# Service Testing Pattern
class TestAllocationService:
    def test_allocate_inventory_success(self, allocation_service_mocks):
        # Arrange
        with allocation_service_mocks.patch_dependencies('allocation.service'):
            service = AllocationService()
            allocation_service_mocks['inventory_service'].check_availability.return_value = True
            
            # Act
            result = service.allocate(sku="TEST-SKU", quantity=10)
            
            # Assert
            assert result.success
            allocation_service_mocks['allocation_repository'].save.assert_called_once()
```

#### 3. Infrastructure Layer Testing (Requirements 3)
```python
# Infrastructure Testing Pattern
class TestSupabaseClient:
    def test_connection_with_valid_credentials(self, mock_builder):
        # Arrange
        mock_supabase = mock_builder.mock_external_service(Client)
        
        # Act & Assert
        with patch('supabase.create_client', return_value=mock_supabase):
            client = get_supabase_client()
            assert client is not None
```

### Coverage and Quality Metrics

#### Coverage Configuration
```python
# pytest.ini additions
[tool.pytest.ini_options]
addopts = [
    "--cov=libs",
    "--cov=apps", 
    "--cov-report=html:htmlcov",
    "--cov-report=xml:coverage.xml",
    "--cov-report=term-missing",
    "--cov-fail-under=90",
    "--cov-branch"
]
```

#### Quality Gates
```python
class TestQualityGates:
    MIN_COVERAGE_THRESHOLD = 90.0
    MAX_TEST_EXECUTION_TIME = 300  # 5 minutes
    MAX_INDIVIDUAL_TEST_TIME = 5   # 5 seconds
    
    def validate_coverage(self, coverage_report: Dict[str, float]) -> bool:
        return all(
            coverage >= self.MIN_COVERAGE_THRESHOLD 
            for coverage in coverage_report.values()
        )
    
    def validate_performance(self, test_results: List[TestResult]) -> bool:
        slow_tests = [
            r for r in test_results 
            if r.metrics.execution_time > self.MAX_INDIVIDUAL_TEST_TIME
        ]
        return len(slow_tests) == 0
```

## Implementation Phases

### Phase 1: Core Testing Infrastructure (Requirements 4, 6)
- Test data factory implementation
- Mock builder framework
- Basic fixture setup
- Coverage reporting configuration

### Phase 2: Domain Layer Testing (Requirements 1, 7)
- Domain entity unit tests
- Value object testing
- Business rule validation
- Property-based testing setup

### Phase 3: Application Layer Testing (Requirements 2, 5)
- Application service testing
- Use case testing
- Error handling validation
- Integration with mocking framework

### Phase 4: Infrastructure Testing (Requirements 3, 8)
- Shared library testing
- Database utility testing
- Observability component testing
- CI/CD integration

### Phase 5: Advanced Testing Features
- Performance benchmarking
- Test quality metrics
- Automated test generation
- Continuous improvement tools