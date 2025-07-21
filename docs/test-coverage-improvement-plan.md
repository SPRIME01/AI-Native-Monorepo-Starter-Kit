# Test Coverage Improvement Plan

## Current Status
- **Current Coverage**: 50.46%
- **Target Coverage**: 90%
- **Gap**: 39.54%

## Coverage Breakdown by Module

### Fully Covered (100%)
- `libs/allocation/domain/entities/allocation.py` - 100%
- `libs/allocation/domain/factories.py` - 100%
- `libs/payments/domain/entities/payment.py` - 100%

### High Coverage (>80%)
- `libs/inventory/domain/entities/inventory_aggregate.py` - 86%

### Medium Coverage (50-80%)
- `libs/shared/data_access/supabase/client.py` - 64%

### No Coverage (0%)
- `libs/shared/vector/adapter.py` - 0%
- `libs/shared/vector/embedding_service.py` - 0%
- `libs/shared/vector/pgvector_adapter.py` - 0%
- `libs/shared/vector/similarity_search.py` - 0%
- `libs/shared/vector/supabase_adapter.py` - 0%
- `libs/shared/vector/test_similarity_search.py` - 0%

## Action Plan to Reach 90% Coverage

### Phase 1: Quick Wins (Target: 65%)
1. **Add tests for inventory edge cases** (4% remaining)
   - Test invalid reserved quantity scenarios
   - Test edge cases in allocation/deallocation

2. **Test supabase client fully** (36% improvement)
   - Add tests for connection methods
   - Test error handling scenarios

### Phase 2: Vector Module Testing (Target: 85%)
3. **Add vector adapter tests**
   - Test embedding service functionality
   - Test pgvector adapter methods
   - Test supabase vector adapter
   - Test similarity search algorithms

### Phase 3: Final Push (Target: 90%+)
4. **Comprehensive integration tests**
   - Cross-module interaction tests
   - Error propagation scenarios
   - Performance edge cases

## Timeline
- **Phase 1**: Complete within 1 sprint
- **Phase 2**: Complete within 2 sprints
- **Phase 3**: Complete within 3 sprints

## Success Metrics
- Each phase should achieve the target coverage percentage
- All new tests should follow existing patterns and conventions
- Test execution time should remain under 30 seconds
- No flaky tests should be introduced

## Notes
- Current threshold set to 50% to enable CI passage
- Gradual increase recommended: 50% → 65% → 85% → 90%
- Focus on high-impact, low-effort wins first
