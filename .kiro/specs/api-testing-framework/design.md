# Design Document

## Overview

This design establishes a comprehensive API testing framework for the AI-Native Monorepo Starter Kit using FastAPI TestClient, pytest, and additional testing tools. The solution provides structured API testing patterns, contract validation, performance testing, authentication testing, and automated test data management. The design follows microservice testing best practices while ensuring proper isolation, realistic test scenarios, and comprehensive coverage of all API endpoints.

## Architecture

### API Testing Architecture Layers

```
┌─────────────────────────────────────────────────────────────┐
│                    API Test Suite                           │
├─────────────────────────────────────────────────────────────┤
│  Contract Tests │ Integration Tests │ Performance Tests     │
├─────────────────────────────────────────────────────────────┤
│              Test Utilities & Fixtures                     │
├─────────────────────────────────────────────────────────────┤
│    FastAPI TestClient │ Mock Services │ Test Data Factory  │
├─────────────────────────────────────────────────────────────┤
│              FastAPI Applications                           │
├─────────────────────────────────────────────────────────────┤
│                  Domain Services                            │
└─────────────────────────────────────────────────────────────┘
```

### Test Organization Structure

```
tests/api/
├── conftest.py                     # API test configuration
├── fixtures/
│   ├── api_fixtures.py             # FastAPI app fixtures
│   ├── auth_fixtures.py            # Authentication fixtures
│   ├── data_fixtures.py            # Test data fixtures
│   └── mock_fixtures.py            # External service mocks
├── contracts/
│   ├── openapi_schemas/            # OpenAPI specification files
│   ├── test_contract_validation.py # Contract testing
│   └── test_schema_evolution.py    # Schema compatibility tests
├── endpoints/
│   ├── allocation/
│   │   ├── test_allocation_api.py
│   │   ├── test_allocation_auth.py
│   │   └── test_allocation_errors.py
│   ├── payments/
│   │   ├── test_payment_api.py
│   │   └── test_payment_validation.py
│   ├── inventory/
│   │   └── test_inventory_api.py
│   └── shared/
│       ├── test_health_endpoints.py
│       └── test_common_middleware.py
├── integration/
│   ├── test_service_communication.py
│   ├── test_database_integration.py
│   └── test_external_services.py
├── performance/
│   ├── test_load_testing.py
│   ├── test_stress_testing.py
│   └── test_performance_benchmarks.py
├── security/
│   ├── test_authentication.py
│   ├── test_authorization.py
│   └── test_security_headers.py
└── utils/
    ├── api_test_helpers.py
    ├── performance_utils.py
    ├── contract_validators.py
    └── test_data_builders.py
```

## Components and Interfaces

### API Test Client Framework

```python
from fastapi.testclient import TestClient
from fastapi import FastAPI
from typing import Dict, Any, Optional, List
from dataclasses import dataclass
from enum import Enum
import pytest

class HTTPMethod(Enum):
    GET = "GET"
    POST = "POST"
    PUT = "PUT"
    DELETE = "DELETE"
    PATCH = "PATCH"

@dataclass
class APITestRequest:
    method: HTTPMethod
    url: str
    headers: Optional[Dict[str, str]] = None
    params: Optional[Dict[str, Any]] = None
    json: Optional[Dict[str, Any]] = None
    data: Optional[Dict[str, Any]] = None

@dataclass
class APITestResponse:
    status_code: int
    headers: Dict[str, str]
    json_data: Optional[Dict[str, Any]]
    text: str
    execution_time: float

class APITestClient:
    def __init__(self, app: FastAPI):
        self.client = TestClient(app)
        self.base_headers = {}
    
    def set_auth_token(self, token: str):
        self.base_headers["Authorization"] = f"Bearer {token}"
    
    def make_request(self, request: APITestRequest) -> APITestResponse:
        headers = {**self.base_headers, **(request.headers or {})}
        
        start_time = time.time()
        response = self.client.request(
            method=request.method.value,
            url=request.url,
            headers=headers,
            params=request.params,
            json=request.json,
            data=request.data
        )
        execution_time = time.time() - start_time
        
        return APITestResponse(
            status_code=response.status_code,
            headers=dict(response.headers),
            json_data=response.json() if response.headers.get("content-type", "").startswith("application/json") else None,
            text=response.text,
            execution_time=execution_time
        )
```

### Contract Testing Framework

```python
from openapi_spec_validator import validate_spec
from jsonschema import validate, ValidationError
from typing import Dict, Any, List
import yaml
import json

class ContractValidator:
    def __init__(self, openapi_spec_path: str):
        with open(openapi_spec_path, 'r') as f:
            self.spec = yaml.safe_load(f)
        validate_spec(self.spec)
    
    def validate_request(self, endpoint: str, method: str, request_data: Dict[str, Any]) -> bool:
        schema = self._get_request_schema(endpoint, method)
        try:
            validate(instance=request_data, schema=schema)
            return True
        except ValidationError:
            return False
    
    def validate_response(self, endpoint: str, method: str, status_code: int, response_data: Dict[str, Any]) -> bool:
        schema = self._get_response_schema(endpoint, method, status_code)
        try:
            validate(instance=response_data, schema=schema)
            return True
        except ValidationError:
            return False
    
    def detect_breaking_changes(self, old_spec_path: str) -> List[str]:
        with open(old_spec_path, 'r') as f:
            old_spec = yaml.safe_load(f)
        
        breaking_changes = []
        # Compare schemas and detect breaking changes
        breaking_changes.extend(self._compare_endpoints(old_spec, self.spec))
        breaking_changes.extend(self._compare_schemas(old_spec, self.spec))
        
        return breaking_changes

class APIContractTester:
    def __init__(self, api_client: APITestClient, contract_validator: ContractValidator):
        self.api_client = api_client
        self.validator = contract_validator
    
    def test_endpoint_contract(self, endpoint: str, method: str, test_data: Dict[str, Any]):
        # Validate request against contract
        assert self.validator.validate_request(endpoint, method, test_data)
        
        # Make API call
        request = APITestRequest(method=HTTPMethod(method), url=endpoint, json=test_data)
        response = self.api_client.make_request(request)
        
        # Validate response against contract
        assert self.validator.validate_response(endpoint, method, response.status_code, response.json_data)
```

### Authentication Testing Framework

```python
from typing import Optional, Dict, Any
import jwt
from datetime import datetime, timedelta

class AuthTestHelper:
    def __init__(self, secret_key: str, algorithm: str = "HS256"):
        self.secret_key = secret_key
        self.algorithm = algorithm
    
    def create_test_token(self, user_id: str, roles: List[str], expires_in: int = 3600) -> str:
        payload = {
            "user_id": user_id,
            "roles": roles,
            "exp": datetime.utcnow() + timedelta(seconds=expires_in),
            "iat": datetime.utcnow()
        }
        return jwt.encode(payload, self.secret_key, algorithm=self.algorithm)
    
    def create_expired_token(self, user_id: str, roles: List[str]) -> str:
        payload = {
            "user_id": user_id,
            "roles": roles,
            "exp": datetime.utcnow() - timedelta(hours=1),
            "iat": datetime.utcnow() - timedelta(hours=2)
        }
        return jwt.encode(payload, self.secret_key, algorithm=self.algorithm)
    
    def create_invalid_token(self) -> str:
        return "invalid.jwt.token"

class AuthTestScenarios:
    def __init__(self, auth_helper: AuthTestHelper):
        self.auth_helper = auth_helper
    
    def test_valid_authentication(self, api_client: APITestClient, endpoint: str):
        token = self.auth_helper.create_test_token("test_user", ["user"])
        api_client.set_auth_token(token)
        
        response = api_client.make_request(APITestRequest(HTTPMethod.GET, endpoint))
        assert response.status_code != 401
    
    def test_expired_token(self, api_client: APITestClient, endpoint: str):
        token = self.auth_helper.create_expired_token("test_user", ["user"])
        api_client.set_auth_token(token)
        
        response = api_client.make_request(APITestRequest(HTTPMethod.GET, endpoint))
        assert response.status_code == 401
    
    def test_role_based_access(self, api_client: APITestClient, endpoint: str, required_role: str):
        # Test with correct role
        token = self.auth_helper.create_test_token("test_user", [required_role])
        api_client.set_auth_token(token)
        response = api_client.make_request(APITestRequest(HTTPMethod.GET, endpoint))
        assert response.status_code != 403
        
        # Test with incorrect role
        token = self.auth_helper.create_test_token("test_user", ["wrong_role"])
        api_client.set_auth_token(token)
        response = api_client.make_request(APITestRequest(HTTPMethod.GET, endpoint))
        assert response.status_code == 403
```

### Performance Testing Framework

```python
import asyncio
import aiohttp
import time
from concurrent.futures import ThreadPoolExecutor
from typing import List, Dict, Any
from dataclasses import dataclass

@dataclass
class PerformanceMetrics:
    total_requests: int
    successful_requests: int
    failed_requests: int
    average_response_time: float
    min_response_time: float
    max_response_time: float
    requests_per_second: float
    percentile_95: float
    percentile_99: float

class PerformanceTester:
    def __init__(self, base_url: str):
        self.base_url = base_url
        self.response_times: List[float] = []
    
    async def load_test(self, endpoint: str, concurrent_users: int, requests_per_user: int) -> PerformanceMetrics:
        async with aiohttp.ClientSession() as session:
            tasks = []
            for _ in range(concurrent_users):
                task = self._user_simulation(session, endpoint, requests_per_user)
                tasks.append(task)
            
            start_time = time.time()
            results = await asyncio.gather(*tasks, return_exceptions=True)
            total_time = time.time() - start_time
            
            return self._calculate_metrics(results, total_time)
    
    async def _user_simulation(self, session: aiohttp.ClientSession, endpoint: str, request_count: int):
        results = []
        for _ in range(request_count):
            start_time = time.time()
            try:
                async with session.get(f"{self.base_url}{endpoint}") as response:
                    await response.text()
                    response_time = time.time() - start_time
                    results.append({"success": True, "response_time": response_time})
            except Exception as e:
                response_time = time.time() - start_time
                results.append({"success": False, "response_time": response_time, "error": str(e)})
        return results
    
    def stress_test(self, endpoint: str, max_concurrent_users: int, step_size: int = 10) -> Dict[int, PerformanceMetrics]:
        results = {}
        for users in range(step_size, max_concurrent_users + 1, step_size):
            metrics = asyncio.run(self.load_test(endpoint, users, 10))
            results[users] = metrics
            
            # Stop if error rate exceeds threshold
            if metrics.failed_requests / metrics.total_requests > 0.1:
                break
        
        return results
```

## Data Models

### API Test Configuration

```python
from dataclasses import dataclass
from typing import Dict, List, Optional
from enum import Enum

class TestEnvironment(Enum):
    UNIT = "unit"
    INTEGRATION = "integration"
    STAGING = "staging"
    PRODUCTION = "production"

@dataclass
class APITestConfig:
    environment: TestEnvironment
    base_url: str
    timeout_seconds: int
    retry_count: int
    auth_config: Dict[str, Any]
    database_config: Dict[str, Any]
    external_services: Dict[str, str]

@dataclass
class PerformanceTestConfig:
    max_response_time: float
    max_concurrent_users: int
    requests_per_user: int
    error_threshold: float
    memory_limit_mb: int

@dataclass
class ContractTestConfig:
    openapi_spec_path: str
    validate_requests: bool
    validate_responses: bool
    breaking_change_detection: bool
    schema_evolution_rules: Dict[str, Any]
```

### Test Data Models

```python
from dataclasses import dataclass
from typing import Any, Dict, List, Optional
from datetime import datetime

@dataclass
class APITestData:
    endpoint: str
    method: str
    request_data: Dict[str, Any]
    expected_status: int
    expected_response: Optional[Dict[str, Any]] = None
    auth_required: bool = False
    roles_required: List[str] = None

@dataclass
class TestScenario:
    name: str
    description: str
    test_data: List[APITestData]
    setup_steps: List[str] = None
    cleanup_steps: List[str] = None

class APITestDataBuilder:
    def __init__(self):
        self.scenarios: Dict[str, TestScenario] = {}
    
    def create_allocation_scenarios(self) -> List[TestScenario]:
        return [
            TestScenario(
                name="allocation_happy_path",
                description="Test successful allocation creation and retrieval",
                test_data=[
                    APITestData(
                        endpoint="/api/v1/allocations",
                        method="POST",
                        request_data={"sku": "TEST-001", "quantity": 10},
                        expected_status=201,
                        auth_required=True,
                        roles_required=["allocation_manager"]
                    )
                ]
            )
        ]
```

## Error Handling

### API Error Testing Framework

```python
from typing import Dict, Any, List
from enum import Enum

class APIErrorType(Enum):
    VALIDATION_ERROR = "validation_error"
    AUTHENTICATION_ERROR = "authentication_error"
    AUTHORIZATION_ERROR = "authorization_error"
    NOT_FOUND_ERROR = "not_found_error"
    SERVER_ERROR = "server_error"
    RATE_LIMIT_ERROR = "rate_limit_error"

class APIErrorTester:
    def __init__(self, api_client: APITestClient):
        self.api_client = api_client
    
    def test_validation_errors(self, endpoint: str, invalid_payloads: List[Dict[str, Any]]):
        for payload in invalid_payloads:
            response = self.api_client.make_request(
                APITestRequest(HTTPMethod.POST, endpoint, json=payload)
            )
            assert response.status_code == 400
            assert "error" in response.json_data
            assert "validation" in response.json_data["error"]["type"]
    
    def test_authentication_errors(self, endpoint: str):
        # Test without token
        response = self.api_client.make_request(APITestRequest(HTTPMethod.GET, endpoint))
        assert response.status_code == 401
        
        # Test with invalid token
        self.api_client.set_auth_token("invalid_token")
        response = self.api_client.make_request(APITestRequest(HTTPMethod.GET, endpoint))
        assert response.status_code == 401
    
    def test_not_found_errors(self, endpoint_template: str, invalid_ids: List[str]):
        for invalid_id in invalid_ids:
            endpoint = endpoint_template.format(id=invalid_id)
            response = self.api_client.make_request(APITestRequest(HTTPMethod.GET, endpoint))
            assert response.status_code == 404
```

### Error Response Validation

```python
from jsonschema import validate
import json

class ErrorResponseValidator:
    def __init__(self):
        self.error_schema = {
            "type": "object",
            "properties": {
                "error": {
                    "type": "object",
                    "properties": {
                        "type": {"type": "string"},
                        "message": {"type": "string"},
                        "details": {"type": "object"},
                        "timestamp": {"type": "string"},
                        "request_id": {"type": "string"}
                    },
                    "required": ["type", "message"]
                }
            },
            "required": ["error"]
        }
    
    def validate_error_response(self, response_data: Dict[str, Any]) -> bool:
        try:
            validate(instance=response_data, schema=self.error_schema)
            return True
        except:
            return False
    
    def validate_no_sensitive_data(self, response_data: Dict[str, Any]) -> bool:
        response_text = json.dumps(response_data).lower()
        sensitive_patterns = ["password", "secret", "key", "token", "credential"]
        return not any(pattern in response_text for pattern in sensitive_patterns)
```

## Testing Strategy

### Test Categories and Implementation

#### 1. Endpoint Testing (Requirements 1, 3)
```python
class TestAllocationAPI:
    def test_create_allocation_success(self, api_client, auth_token):
        api_client.set_auth_token(auth_token)
        response = api_client.make_request(APITestRequest(
            HTTPMethod.POST,
            "/api/v1/allocations",
            json={"sku": "TEST-001", "quantity": 10}
        ))
        assert response.status_code == 201
        assert response.json_data["sku"] == "TEST-001"
    
    def test_create_allocation_validation_error(self, api_client):
        response = api_client.make_request(APITestRequest(
            HTTPMethod.POST,
            "/api/v1/allocations",
            json={"invalid": "data"}
        ))
        assert response.status_code == 400
```

#### 2. Contract Testing (Requirement 4)
```python
class TestAPIContracts:
    def test_openapi_compliance(self, api_client, contract_validator):
        tester = APIContractTester(api_client, contract_validator)
        tester.test_endpoint_contract(
            "/api/v1/allocations",
            "POST",
            {"sku": "TEST-001", "quantity": 10}
        )
```

#### 3. Performance Testing (Requirement 5)
```python
class TestAPIPerformance:
    @pytest.mark.performance
    def test_allocation_endpoint_performance(self, performance_tester):
        metrics = asyncio.run(performance_tester.load_test(
            "/api/v1/allocations",
            concurrent_users=50,
            requests_per_user=10
        ))
        assert metrics.average_response_time < 1.0
        assert metrics.requests_per_second > 100
```

## Implementation Phases

### Phase 1: Core API Testing Infrastructure (Requirements 1, 8)
- FastAPI TestClient setup and configuration
- API test data builders and fixtures
- Basic endpoint testing framework
- Test environment isolation

### Phase 2: Authentication and Security Testing (Requirements 2, 7)
- JWT token testing framework
- Role-based access control testing
- Security header validation
- Authentication error scenarios

### Phase 3: Contract and Schema Testing (Requirements 4, 7)
- OpenAPI specification validation
- Request/response schema testing
- Breaking change detection
- API versioning support

### Phase 4: Performance and Integration Testing (Requirements 5, 6)
- Load testing framework
- Stress testing capabilities
- Inter-service communication testing
- Database integration testing

### Phase 5: Advanced Testing Features (Requirements 3, 7)
- Comprehensive error scenario testing
- CI/CD integration
- Test automation and reporting
- Monitoring and alerting integration