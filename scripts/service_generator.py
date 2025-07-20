#!/usr/bin/env python3
"""
Service generation utilities for the AI-Native Monorepo Starter Kit.
Handles creation of microservice applications, Docker configurations, and Kubernetes manifests.
"""

import os
import sys
import json
from pathlib import Path


def create_service_app(ctx: str, transport: str = "fastapi"):
    """Create service application structure."""
    print(f"🏗️ Creating service application for {ctx}...")
    
    # Validation
    if not ctx:
        print("❌ Error: CTX parameter is required")
        print("Usage: python scripts/service_generator.py create-app <context-name> [transport]")
        sys.exit(1)
    
    if not os.path.exists(f"libs/{ctx}"):
        print(f"❌ Context {ctx} not found. Run 'just context-new CTX={ctx}' first.")
        sys.exit(1)
    
    # Create directory structure
    service_dir = Path(f"apps/{ctx}-svc")
    src_dir = service_dir / "src"
    src_dir.mkdir(parents=True, exist_ok=True)
    
    # Create main.py
    main_py_content = f'''"""
{ctx} Microservice - Auto-generated service wrapper
Exposes libs/{ctx} domain logic via {transport} transport
"""
'''
    
    if transport == "fastapi":
        ctx_capitalized = ctx.capitalize()
        main_py_content += f'''from fastapi import FastAPI, Depends
from libs.{ctx}.application.{ctx}_service import {ctx_capitalized}Service
from libs.{ctx}.adapters.memory_adapter import Memory{ctx_capitalized}Adapter

app = FastAPI(
    title="{ctx_capitalized} Service",
    description="Microservice for {ctx} domain",
    version="1.0.0"
)

def get_service():
    repository = Memory{ctx_capitalized}Adapter()
    return {ctx_capitalized}Service(repository)

@app.get("/health")
def health_check():
    return {{"status": "healthy", "service": "{ctx}"}}

@app.get("/{ctx}")
async def list_items(service: {ctx_capitalized}Service = Depends(get_service)):
    return await service.get_all()

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)
'''
    
    with open(src_dir / "main.py", "w", encoding="utf-8") as f:
        f.write(main_py_content)
    
    # Create project.json
    project_config = {
        "name": f"{ctx}-svc",
        "root": f"apps/{ctx}-svc",
        "projectType": "application",
        "tags": [f"context:{ctx}", "type:service", "deployable:true"],
        "targets": {
            "serve": {
                "executor": "@nx/python:run",
                "options": {
                    "module": "src.main"
                }
            },
            "docker": {
                "executor": "@nx/docker:build",
                "options": {
                    "context": f"apps/{ctx}-svc",
                    "dockerfile": f"apps/{ctx}-svc/Dockerfile"
                }
            }
        }
    }
    
    with open(service_dir / "project.json", "w", encoding="utf-8") as f:
        json.dump(project_config, f, indent=2)
    
    print(f"✅ Service application {ctx}-svc created successfully")


def create_service_container(ctx: str):
    """Create Docker configuration for service."""
    print(f"🐳 Creating Docker configuration for {ctx}...")
    
    # Validation
    if not ctx:
        print("❌ Error: CTX parameter is required")
        sys.exit(1)
    
    service_dir = Path(f"apps/{ctx}-svc")
    if not service_dir.exists():
        print(f"❌ Service {ctx}-svc not found. Run create-app first.")
        sys.exit(1)
    
    # Create Dockerfile
    dockerfile_content = """FROM python:3.11-slim
WORKDIR /app
COPY requirements.txt .
RUN pip install -r requirements.txt
COPY . .
EXPOSE 8000
CMD ["python", "src/main.py"]
"""
    
    with open(service_dir / "Dockerfile", "w", encoding="utf-8") as f:
        f.write(dockerfile_content)
    
    # Create requirements.txt
    requirements_content = """fastapi
uvicorn
"""
    
    with open(service_dir / "requirements.txt", "w", encoding="utf-8") as f:
        f.write(requirements_content)
    
    print(f"✅ Docker configuration for {ctx}-svc created successfully")


def create_service_k8s(ctx: str, container_registry: str = "ghcr.io/your-org", scale_target: str = "70"):
    """Create Kubernetes manifests for service."""
    print(f"☸️ Creating Kubernetes manifests for {ctx}...")
    
    # Validation
    if not ctx:
        print("❌ Error: CTX parameter is required")
        sys.exit(1)
    
    service_dir = Path(f"apps/{ctx}-svc")
    if not service_dir.exists():
        print(f"❌ Service {ctx}-svc not found. Run create-app first.")
        sys.exit(1)
    
    k8s_dir = service_dir / "k8s"
    k8s_dir.mkdir(exist_ok=True)
    
    # Create deployment.yaml
    deployment_content = f"""apiVersion: apps/v1
kind: Deployment
metadata:
  name: {ctx}-svc
  labels:
    app: {ctx}-svc
spec:
  replicas: 2
  selector:
    matchLabels:
      app: {ctx}-svc
  template:
    metadata:
      labels:
        app: {ctx}-svc
    spec:
      containers:
      - name: {ctx}-svc
        image: {container_registry}/{ctx}-svc:latest
        ports:
        - containerPort: 8000
        resources:
          requests:
            cpu: 100m
            memory: 128Mi
          limits:
            cpu: 500m
            memory: 512Mi
---
apiVersion: v1
kind: Service
metadata:
  name: {ctx}-svc
spec:
  selector:
    app: {ctx}-svc
  ports:
  - port: 80
    targetPort: 8000
"""
    
    with open(k8s_dir / "deployment.yaml", "w", encoding="utf-8") as f:
        f.write(deployment_content)
    
    # Create hpa.yaml
    hpa_content = f"""apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: {ctx}-svc-hpa
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: {ctx}-svc
  minReplicas: 2
  maxReplicas: 10
  metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: {scale_target}
"""
    
    with open(k8s_dir / "hpa.yaml", "w", encoding="utf-8") as f:
        f.write(hpa_content)
    
    print(f"✅ Kubernetes manifests for {ctx}-svc created successfully")


def update_service_tags(ctx: str, deployable: str):
    """Update deployable tags for context."""
    print(f"🏷️ Updating deployable tag for {ctx} to {deployable}...")
    
    # Validation
    if not ctx or not deployable:
        print("❌ Error: CTX and DEPLOYABLE parameters are required")
        sys.exit(1)
    
    project_file = Path(f"libs/{ctx}/project.json")
    if not project_file.exists():
        print(f"❌ {project_file} not found.")
        sys.exit(1)
    
    try:
        with open(project_file, "r", encoding="utf-8") as f:
            data = json.load(f)
        
        # Initialize tags if not present
        if "tags" not in data:
            data["tags"] = []
        
        # Remove existing deployable tag
        data["tags"] = [tag for tag in data["tags"] if not tag.startswith("deployable:")]
        
        # Add new deployable tag
        data["tags"].append(f"deployable:{deployable}")
        
        with open(project_file, "w", encoding="utf-8") as f:
            json.dump(data, f, indent=2)
        
        print("✅ Tag updated.")
    except Exception as e:
        print(f"❌ Failed to update tag: {e}")
        sys.exit(1)


if __name__ == "__main__":
    if len(sys.argv) < 3:
        print("Usage: python scripts/service_generator.py <command> <ctx> [args...]")
        print("Commands: create-app, create-container, create-k8s, update-tags")
        sys.exit(1)
    
    command = sys.argv[1]
    ctx = sys.argv[2]
    
    if command == "create-app":
        transport = sys.argv[3] if len(sys.argv) > 3 else "fastapi"
        create_service_app(ctx, transport)
    elif command == "create-container":
        create_service_container(ctx)
    elif command == "create-k8s":
        container_registry = sys.argv[3] if len(sys.argv) > 3 else "ghcr.io/your-org"
        scale_target = sys.argv[4] if len(sys.argv) > 4 else "70"
        create_service_k8s(ctx, container_registry, scale_target)
    elif command == "update-tags":
        deployable = sys.argv[3] if len(sys.argv) > 3 else "true"
        update_service_tags(ctx, deployable)
    else:
        print(f"Unknown command: {command}")
        sys.exit(1)