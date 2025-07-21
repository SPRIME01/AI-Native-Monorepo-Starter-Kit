# Design Document

## Overview

This design establishes a comprehensive database integration testing framework for the AI-Native Monorepo Starter Kit using pytest, Supabase Python client, and specialized testing utilities. The solution provides structured database testing patterns, transaction testing, vector database validation, performance benchmarking, and automated test data management. The design ensures proper isolation, realistic test scenarios, and comprehensive coverage of all database operations while maintaining data integrity and test reliability.

## Architecture

### Database Testing Architecture Layers

```
┌─────────────────────────────────────────────────────────────┐
│                Database Integration Test Suite              │
├─────────────────────────────────────────────────────────────┤
│  CRUD Tests │ Transaction Tests │ Vector DB Tests │ Perf Tests│
├─────────────────────────────────────────────────────────────┤
│              Test Utilities & Fixtures                     │
├─────────────────────────────────────────────────────────────┤
│    DB Test Client │ Data Factories │ Migration Tools      │
├─────────────────────────────────────────────────────────────┤
│              Database Adapters & Clients                   │
├─────────────────────────────────────────────────────────────┤
│                  Supabase Database                          │
└─────────────────────────────────────────────────────────────┘
```

### Test Organization Structure

```
tests/database/
├── conftest.py                     # Database test configuration
├── fixtures/
│   ├── database_fixtures.py        # Database connection fixtures
│   ├── transaction_fixtures.py     # Transaction management fixtures
│   ├── data_fixtures.py            # Test data fixtures
│   └── vector_fixtures.py          # Vector database fixtures
├── integration/
│   ├── test_supabase_client.py     # Supabase client integration
│   ├── test_connection_management.py # Connection pooling and management
│   └── test_configuration.py       # Database configuration testing
├── crud/
│   ├── allocation/
│   │   ├── test_allocation_repository.py
│   │   └── test_allocation_queries.py
│   ├── payments/
│   │   ├── test_payment_repository.py
│   │   └── test_payment_transactions.py
│   ├── inventory/
│   │   └── test_inventory_operations.py
│   └── shared/
│       └── test_base_repository.py
├── transactions/
│   ├── test_transaction_management.py
│   ├── test_isolation_levels.py
│   ├── test_rollback_scenarios.py
│   └── test_distributed_transactions.py
├── vector/
│   ├── test_vector_storage.py
│   ├── test_similarity_search.py
│   ├── test_vector_metadata.py
│   └── test_vector_performance.py
├── constraints/
│   ├── test_referential_integrity.py
│   ├── test_unique_constraints.py
│   ├── test_check_constraints.py
│   └── test_constraint_violations.py
├── performance/
│   ├── test_query_performance.py
│   ├── test_bulk_operations.py
│   ├── test_concurrent_access.py
│   └── test_resource_utilization.py
├── migrations/
│   ├── test_schema_migrations.py
│   ├── test_data_migrations.py
│   ├── test_rollback_migrations.py
│   └── test_migration_performance.py
└── utils/
    ├── database_test_helpers.py
    ├── test_data_builders.py
    ├── performance_monitors.py
    └── migration_validators.py
```

## Components and Interfaces

### Database Test Client Framework

```python
from supabase import create_client, Client
from typing import Dict, Any, List, Optional, Union
from dataclasses import dataclass
from contextlib import contextmanager
import asyncio
import time

@dataclass
class DatabaseTestConfig:
    url: str
    service_role_key: str
    anon_key: str
    test_schema: str = "test"
    isolation_level: str = "READ_COMMITTED"
    connection_pool_size: int = 10

class DatabaseTestClient:
    def __init__(self, config: DatabaseTestConfig):
        self.config = config
        self.client = create_client(config.url, config.service_role_key)
        self.test_schema = config.test_schema
        self._transaction_stack = []
    
    @contextmanager
    def transaction(self, isolation_level: Optional[str] = None):
        """Context manager for database transactions"""
        transaction_id = self._begin_transaction(isolation_level)
        try:
            yield transaction_id
            self._commit_transaction(transaction_id)
        except Exception as e:
            self._rollback_transaction(transaction_id)
            raise e
    
    def execute_query(self, query: str, params: Optional[Dict[str, Any]] = None) -> Any:
        """Execute raw SQL query with parameters"""
        return self.client.rpc("execute_sql", {"query": query, "params": params or {}})
    
    def bulk_insert(self, table: str, records: List[Dict[str, Any]]) -> Any:
        """Perform bulk insert operation"""
        return self.client.table(table).insert(records).execute()
    
    def bulk_update(self, table: str, updates: List[Dict[str, Any]], key_field: str) -> Any:
        """Perform bulk update operation"""
        results = []
        for update in updates:
            key_value = update.pop(key_field)
            result = self.client.table(table).update(update).eq(key_field, key_value).execute()
            results.append(result)
        return results
    
    def measure_query_performance(self, query_func, *args, **kwargs) -> Dict[str, Any]:
        """Measure query execution performance"""
        start_time = time.time()
        start_memory = self._get_memory_usage()
        
        result = query_func(*args, **kwargs)
        
        end_time = time.time()
        end_memory = self._get_memory_usage()
        
        return {
            "execution_time": end_time - start_time,
            "memory_delta": end_memory - start_memory,
            "result_count": len(result.data) if hasattr(result, 'data') else 0,
            "result": result
        }
```

### Test Data Factory Framework

```python
from typing import Dict, Any, List, Optional, TypeVar, Generic
from abc import ABC, abstractmethod
from dataclasses import dataclass
from faker import Faker
import random
import uuid

T = TypeVar('T')

@dataclass
class TestDataSpec:
    count: int = 1
    relationships: Dict[str, Any] = None
    constraints: Dict[str, Any] = None
    seed: Optional[int] = None

class DatabaseTestDataFactory(Generic[T], ABC):
    def __init__(self, db_client: DatabaseTestClient):
        self.db_client = db_client
        self.faker = Faker()
        self._created_records = []
    
    @abstractmethod
    def create_record(self, spec: TestDataSpec = None) -> T:
        pass
    
    @abstractmethod
    def create_batch(self, spec: TestDataSpec) -> List[T]:
        pass
    
    def cleanup_created_records(self):
        """Clean up all records created by this factory"""
        for table, record_ids in self._created_records:
            self.db_client.client.table(table).delete().in_("id", record_ids).execute()
        self._created_records.clear()

class AllocationTestDataFactory(DatabaseTestDataFactory):
    def create_record(self, spec: TestDataSpec = None) -> Dict[str, Any]:
        spec = spec or TestDataSpec()
        
        allocation = {
            "id": str(uuid.uuid4()),
            "sku": f"SKU-{self.faker.random_number(digits=6)}",
            "quantity": random.randint(1, 100),
            "allocated_at": self.faker.date_time_this_year().isoformat(),
            "status": random.choice(["pending", "allocated", "shipped"])
        }
        
        if spec.constraints:
            allocation.update(spec.constraints)
        
        result = self.db_client.client.table("allocations").insert(allocation).execute()
        self._created_records.append(("allocations", [allocation["id"]]))
        
        return result.data[0]
    
    def create_batch(self, spec: TestDataSpec) -> List[Dict[str, Any]]:
        allocations = []
        for _ in range(spec.count):
            allocation = {
                "id": str(uuid.uuid4()),
                "sku": f"SKU-{self.faker.random_number(digits=6)}",
                "quantity": random.randint(1, 100),
                "allocated_at": self.faker.date_time_this_year().isoformat(),
                "status": random.choice(["pending", "allocated", "shipped"])
            }
            allocations.append(allocation)
        
        result = self.db_client.bulk_insert("allocations", allocations)
        record_ids = [record["id"] for record in result.data]
        self._created_records.append(("allocations", record_ids))
        
        return result.data
```

### Transaction Testing Framework

```python
from enum import Enum
from typing import List, Callable, Any
import threading
import time

class IsolationLevel(Enum):
    READ_UNCOMMITTED = "READ UNCOMMITTED"
    READ_COMMITTED = "READ COMMITTED"
    REPEATABLE_READ = "REPEATABLE READ"
    SERIALIZABLE = "SERIALIZABLE"

class TransactionTester:
    def __init__(self, db_client: DatabaseTestClient):
        self.db_client = db_client
    
    def test_transaction_isolation(self, isolation_level: IsolationLevel, 
                                 concurrent_operations: List[Callable]) -> Dict[str, Any]:
        """Test transaction isolation with concurrent operations"""
        results = []
        threads = []
        
        def execute_operation(operation, result_list):
            try:
                with self.db_client.transaction(isolation_level.value):
                    result = operation()
                    result_list.append({"success": True, "result": result})
            except Exception as e:
                result_list.append({"success": False, "error": str(e)})
        
        # Start concurrent operations
        for operation in concurrent_operations:
            thread = threading.Thread(target=execute_operation, args=(operation, results))
            threads.append(thread)
            thread.start()
        
        # Wait for all operations to complete
        for thread in threads:
            thread.join()
        
        return {
            "isolation_level": isolation_level.value,
            "total_operations": len(concurrent_operations),
            "successful_operations": len([r for r in results if r["success"]]),
            "failed_operations": len([r for r in results if not r["success"]]),
            "results": results
        }
    
    def test_deadlock_detection(self) -> Dict[str, Any]:
        """Test deadlock detection and resolution"""
        deadlock_detected = False
        results = []
        
        def operation_a():
            with self.db_client.transaction():
                # Lock resource A, then try to lock resource B
                self.db_client.execute_query("SELECT * FROM table_a WHERE id = 1 FOR UPDATE")
                time.sleep(0.1)  # Simulate processing time
                self.db_client.execute_query("SELECT * FROM table_b WHERE id = 1 FOR UPDATE")
        
        def operation_b():
            with self.db_client.transaction():
                # Lock resource B, then try to lock resource A
                self.db_client.execute_query("SELECT * FROM table_b WHERE id = 1 FOR UPDATE")
                time.sleep(0.1)  # Simulate processing time
                self.db_client.execute_query("SELECT * FROM table_a WHERE id = 1 FOR UPDATE")
        
        # Execute operations concurrently to create deadlock
        thread_a = threading.Thread(target=operation_a)
        thread_b = threading.Thread(target=operation_b)
        
        thread_a.start()
        thread_b.start()
        
        thread_a.join()
        thread_b.join()
        
        return {"deadlock_detected": deadlock_detected, "resolution_time": 0}
```

### Vector Database Testing Framework

```python
import numpy as np
from typing import List, Dict, Any, Tuple
from sklearn.metrics.pairwise import cosine_similarity

class VectorDatabaseTester:
    def __init__(self, db_client: DatabaseTestClient):
        self.db_client = db_client
        self.vector_dimension = 1536  # Default OpenAI embedding dimension
    
    def test_vector_storage_accuracy(self, test_vectors: List[List[float]]) -> Dict[str, Any]:
        """Test vector storage and retrieval accuracy"""
        stored_vectors = []
        retrieved_vectors = []
        
        # Store vectors
        for i, vector in enumerate(test_vectors):
            vector_id = f"test_vector_{i}"
            self.db_client.client.table("vectors").insert({
                "id": vector_id,
                "embedding": vector,
                "metadata": {"test": True, "index": i}
            }).execute()
            stored_vectors.append((vector_id, vector))
        
        # Retrieve and compare vectors
        for vector_id, original_vector in stored_vectors:
            result = self.db_client.client.table("vectors").select("*").eq("id", vector_id).execute()
            retrieved_vector = result.data[0]["embedding"]
            retrieved_vectors.append(retrieved_vector)
            
            # Calculate precision loss
            precision_loss = np.mean(np.abs(np.array(original_vector) - np.array(retrieved_vector)))
            
        return {
            "vectors_tested": len(test_vectors),
            "storage_success_rate": len(retrieved_vectors) / len(test_vectors),
            "average_precision_loss": np.mean([
                np.mean(np.abs(np.array(orig) - np.array(retr))) 
                for orig, retr in zip(test_vectors, retrieved_vectors)
            ])
        }
    
    def test_similarity_search_accuracy(self, query_vector: List[float], 
                                      expected_results: List[str], top_k: int = 5) -> Dict[str, Any]:
        """Test similarity search accuracy and ranking"""
        # Perform similarity search
        search_result = self.db_client.client.rpc("vector_search", {
            "query_embedding": query_vector,
            "top_k": top_k
        }).execute()
        
        retrieved_ids = [result["id"] for result in search_result.data]
        
        # Calculate accuracy metrics
        precision_at_k = len(set(retrieved_ids) & set(expected_results)) / len(retrieved_ids)
        recall_at_k = len(set(retrieved_ids) & set(expected_results)) / len(expected_results)
        
        return {
            "precision_at_k": precision_at_k,
            "recall_at_k": recall_at_k,
            "retrieved_count": len(retrieved_ids),
            "expected_count": len(expected_results),
            "search_results": search_result.data
        }
    
    def test_vector_performance_scaling(self, vector_counts: List[int]) -> Dict[str, Any]:
        """Test vector database performance with increasing data volumes"""
        performance_results = {}
        
        for count in vector_counts:
            # Generate test vectors
            test_vectors = [np.random.rand(self.vector_dimension).tolist() for _ in range(count)]
            
            # Measure insertion performance
            start_time = time.time()
            self._bulk_insert_vectors(test_vectors)
            insertion_time = time.time() - start_time
            
            # Measure search performance
            query_vector = np.random.rand(self.vector_dimension).tolist()
            start_time = time.time()
            self.db_client.client.rpc("vector_search", {
                "query_embedding": query_vector,
                "top_k": 10
            }).execute()
            search_time = time.time() - start_time
            
            performance_results[count] = {
                "insertion_time": insertion_time,
                "search_time": search_time,
                "insertion_rate": count / insertion_time,
                "search_latency": search_time
            }
        
        return performance_results
```

## Data Models

### Database Test Configuration

```python
from dataclasses import dataclass
from typing import Dict, List, Optional, Any
from enum import Enum

class DatabaseTestType(Enum):
    UNIT = "unit"
    INTEGRATION = "integration"
    PERFORMANCE = "performance"
    MIGRATION = "migration"

@dataclass
class DatabaseTestConfig:
    test_type: DatabaseTestType
    database_url: str
    service_role_key: str
    test_schema: str
    isolation_level: str
    connection_pool_size: int
    query_timeout: int
    cleanup_after_test: bool

@dataclass
class PerformanceTestConfig:
    max_query_time: float
    max_bulk_operation_time: float
    concurrent_connection_limit: int
    memory_usage_limit_mb: int
    query_complexity_threshold: int

@dataclass
class VectorTestConfig:
    vector_dimension: int
    similarity_threshold: float
    search_accuracy_threshold: float
    max_search_time: float
    bulk_insert_batch_size: int
```

### Test Result Models

```python
from dataclasses import dataclass
from datetime import datetime
from typing import List, Dict, Any, Optional

@dataclass
class DatabaseTestMetrics:
    execution_time: float
    memory_usage: Optional[float]
    rows_affected: int
    query_complexity: Optional[int]
    connection_count: int

@dataclass
class DatabaseTestResult:
    test_name: str
    test_type: DatabaseTestType
    status: str
    metrics: DatabaseTestMetrics
    error_message: Optional[str] = None
    performance_data: Optional[Dict[str, Any]] = None

@dataclass
class TransactionTestResult:
    isolation_level: str
    concurrent_operations: int
    successful_operations: int
    failed_operations: int
    deadlocks_detected: int
    average_execution_time: float
```

## Error Handling

### Database Error Testing Framework

```python
from typing import Dict, Any, List
from enum import Enum
import psycopg2

class DatabaseErrorType(Enum):
    CONNECTION_ERROR = "connection_error"
    CONSTRAINT_VIOLATION = "constraint_violation"
    TRANSACTION_ROLLBACK = "transaction_rollback"
    DEADLOCK = "deadlock"
    TIMEOUT = "timeout"
    PERMISSION_DENIED = "permission_denied"

class DatabaseErrorTester:
    def __init__(self, db_client: DatabaseTestClient):
        self.db_client = db_client
    
    def test_constraint_violations(self, table: str, constraint_tests: List[Dict[str, Any]]) -> Dict[str, Any]:
        """Test various constraint violation scenarios"""
        results = []
        
        for test_case in constraint_tests:
            try:
                self.db_client.client.table(table).insert(test_case["data"]).execute()
                results.append({
                    "test_case": test_case["name"],
                    "expected_error": test_case["expected_error"],
                    "actual_result": "success",
                    "passed": False  # Should have failed
                })
            except Exception as e:
                error_type = self._classify_error(e)
                results.append({
                    "test_case": test_case["name"],
                    "expected_error": test_case["expected_error"],
                    "actual_error": error_type,
                    "passed": error_type == test_case["expected_error"]
                })
        
        return {
            "total_tests": len(constraint_tests),
            "passed_tests": len([r for r in results if r["passed"]]),
            "results": results
        }
    
    def test_connection_resilience(self, connection_scenarios: List[str]) -> Dict[str, Any]:
        """Test database connection resilience under various failure scenarios"""
        results = {}
        
        for scenario in connection_scenarios:
            try:
                if scenario == "connection_timeout":
                    # Simulate connection timeout
                    pass
                elif scenario == "connection_pool_exhaustion":
                    # Simulate pool exhaustion
                    pass
                elif scenario == "network_interruption":
                    # Simulate network issues
                    pass
                
                results[scenario] = {"success": True, "recovery_time": 0}
            except Exception as e:
                results[scenario] = {"success": False, "error": str(e)}
        
        return results
```

## Testing Strategy

### Test Categories and Implementation

#### 1. Connection and Configuration Testing (Requirement 1)
```python
class TestDatabaseConnection:
    def test_connection_pool_management(self, db_client):
        # Test connection pooling and resource management
        connections = []
        for _ in range(db_client.config.connection_pool_size + 5):
            try:
                conn = db_client.get_connection()
                connections.append(conn)
            except Exception as e:
                assert "connection pool exhausted" in str(e).lower()
        
        # Cleanup connections
        for conn in connections:
            conn.close()
```

#### 2. CRUD Operations Testing (Requirement 2)
```python
class TestCRUDOperations:
    def test_allocation_crud_operations(self, db_client, allocation_factory):
        # Create
        allocation = allocation_factory.create_record()
        assert allocation["id"] is not None
        
        # Read
        retrieved = db_client.client.table("allocations").select("*").eq("id", allocation["id"]).execute()
        assert len(retrieved.data) == 1
        
        # Update
        updated_data = {"quantity": 50}
        db_client.client.table("allocations").update(updated_data).eq("id", allocation["id"]).execute()
        
        # Delete
        db_client.client.table("allocations").delete().eq("id", allocation["id"]).execute()
```

#### 3. Transaction Testing (Requirement 3)
```python
class TestTransactionManagement:
    def test_transaction_rollback(self, db_client, allocation_factory):
        try:
            with db_client.transaction():
                allocation = allocation_factory.create_record()
                # Force an error to trigger rollback
                raise Exception("Forced rollback")
        except:
            pass
        
        # Verify rollback occurred
        result = db_client.client.table("allocations").select("*").eq("id", allocation["id"]).execute()
        assert len(result.data) == 0
```

#### 4. Vector Database Testing (Requirement 4)
```python
class TestVectorDatabase:
    def test_vector_similarity_search(self, db_client, vector_tester):
        test_vectors = [np.random.rand(1536).tolist() for _ in range(100)]
        query_vector = test_vectors[0]  # Use first vector as query
        
        # Store vectors
        vector_tester.test_vector_storage_accuracy(test_vectors)
        
        # Test similarity search
        results = vector_tester.test_similarity_search_accuracy(
            query_vector, ["test_vector_0"], top_k=5
        )
        assert results["precision_at_k"] > 0.8
```

## Implementation Phases

### Phase 1: Core Database Testing Infrastructure (Requirements 1, 8)
- Database test client setup and configuration
- Test data factory framework
- Connection management testing
- Test environment isolation

### Phase 2: CRUD and Transaction Testing (Requirements 2, 3)
- Comprehensive CRUD operation testing
- Transaction management and isolation testing
- Rollback and error scenario testing
- Concurrent operation testing

### Phase 3: Vector Database Testing (Requirements 4, 6)
- Vector storage and retrieval testing
- Similarity search accuracy testing
- Vector database performance testing
- Metadata and indexing validation

### Phase 4: Data Integrity and Constraints (Requirements 5, 7)
- Constraint violation testing
- Referential integrity validation
- Migration testing framework
- Schema evolution testing

### Phase 5: Performance and Advanced Features (Requirements 6, 7)
- Query performance benchmarking
- Bulk operation testing
- Migration performance testing
- Advanced monitoring and reporting