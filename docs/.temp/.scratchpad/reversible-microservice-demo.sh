#!/bin/bash
set -e

# Demo: Reversible Microservice Architecture

CTX=accounting
TRANSPORT=fastapi

# 1. Create context
make context-new CTX=$CTX

# 2. Show initial status
make service-status

# 3. Extract to microservice
make service-split CTX=$CTX TRANSPORT=$TRANSPORT

# 4. Show status
make service-status

# 5. Build service
make build-services

# 6. Merge back to monolith
make service-merge CTX=$CTX

# 7. Show final status
make service-status

echo "✅ Demo complete! Architecture changed with zero domain code impact."
