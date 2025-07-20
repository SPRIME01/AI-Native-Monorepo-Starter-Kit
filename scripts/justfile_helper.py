#!/usr/bin/env python3
"""
Justfile Helper Script
======================

Cross-platform helper functions for the justfile build system.
Handles complex operations that would otherwise require shell-specific syntax.
"""

import argparse
import json
import os
import shutil
import subprocess
import sys
from pathlib import Path
from typing import Dict, List, Optional


class JustfileHelper:
    """Helper class for justfile operations"""

    def __init__(self, workspace_root: str = "."):
        self.workspace_root = Path(workspace_root).resolve()
        self.libs_dir = self.workspace_root / "libs"
        self.apps_dir = self.workspace_root / "apps"

    def check_context_exists(self, ctx: str) -> bool:
        """Check if a DDD context exists"""
        return (self.libs_dir / ctx).exists()

    def check_service_exists(self, ctx: str) -> bool:
        """Check if a service application exists"""
        return (self.apps_dir / f"{ctx}-svc").exists()

    def get_deployable_contexts(self) -> List[Dict[str, any]]:
        """Get list of contexts with their deployment status"""
        contexts = []

        if not self.libs_dir.exists():
            return contexts

        for ctx_dir in self.libs_dir.iterdir():
            if ctx_dir.is_dir() and not ctx_dir.name.startswith('.'):
                project_json = ctx_dir / "project.json"
                deployable = False

                if project_json.exists():
                    try:
                        with open(project_json, 'r') as f:
                            project_data = json.load(f)
                            tags = project_data.get('tags', [])
                            deployable = any('deployable:true' in tag for tag in tags)
                    except (json.JSONDecodeError, KeyError):
                        pass

                service_exists = self.check_service_exists(ctx_dir.name)

                contexts.append({
                    'name': ctx_dir.name,
                    'deployable': deployable,
                    'service_exists': service_exists
                })

        return contexts

    def get_service_list(self) -> List[str]:
        """Get list of service applications"""
        services = []

        if not self.apps_dir.exists():
            return services

        for app_dir in self.apps_dir.iterdir():
            if app_dir.is_dir() and app_dir.name.endswith('-svc'):
                services.append(app_dir.name)

        return sorted(services)

    def create_service_app(self, ctx: str, transport: str = "fastapi") -> bool:
        """Create service application structure"""
        service_dir = self.apps_dir / f"{ctx}-svc"
        src_dir = service_dir / "src"

        try:
            # Create directories
            src_dir.mkdir(parents=True, exist_ok=True)

            # Create main.py with proper template
            main_py_content = self._generate_service_main_py(ctx, transport)

            with open(src_dir / "main.py", "w") as f:
                f.write(main_py_content)

            # Create project.json
            project_json_content = self._generate_service_project_json(ctx)

            with open(service_dir / "project.json", "w") as f:
                f.write(project_json_content)

            print(f"✅ Service application {ctx}-svc created successfully")
            return True

        except Exception as e:
            print(f"❌ Failed to create service application: {e}")
            return False

    def create_service_container(self, ctx: str) -> bool:
        """Create container configuration for service"""
        service_dir = self.apps_dir / f"{ctx}-svc"

        if not service_dir.exists():
            print(f"❌ Service {ctx}-svc does not exist")
            return False

        try:
            # Create Dockerfile
            dockerfile_content = self._generate_dockerfile(ctx)

            with open(service_dir / "Dockerfile", "w") as f:
                f.write(dockerfile_content)

            # Create requirements.txt
            requirements_content = self._generate_requirements_txt(ctx)

            with open(service_dir / "requirements.txt", "w") as f:
                f.write(requirements_content)

            print(f"✅ Container configuration for {ctx}-svc created successfully")
            return True

        except Exception as e:
            print(f"❌ Failed to create container configuration: {e}")
            return False

    def create_service_k8s(self, ctx: str) -> bool:
        """Create Kubernetes manifests for service"""
        service_dir = self.apps_dir / f"{ctx}-svc"
        k8s_dir = service_dir / "k8s"

        if not service_dir.exists():
            print(f"❌ Service {ctx}-svc does not exist")
            return False

        try:
            k8s_dir.mkdir(exist_ok=True)

            # Create deployment.yaml
            deployment_content = self._generate_k8s_deployment(ctx)

            with open(k8s_dir / "deployment.yaml", "w") as f:
                f.write(deployment_content)

            # Create service.yaml
            service_content = self._generate_k8s_service(ctx)

            with open(k8s_dir / "service.yaml", "w") as f:
                f.write(service_content)

            print(f"✅ Kubernetes manifests for {ctx}-svc created successfully")
            return True

        except Exception as e:
            print(f"❌ Failed to create Kubernetes manifests: {e}")
            return False

    def update_service_tags(self, ctx: str, deployable: bool) -> bool:
        """Update service deployment tags"""
        lib_dir = self.libs_dir / ctx
        project_json_file = lib_dir / "project.json"

        if not project_json_file.exists():
            print(f"❌ Context {ctx} project.json not found")
            return False

        try:
            with open(project_json_file, 'r') as f:
                project_data = json.load(f)

            tags = project_data.get('tags', [])

            # Remove existing deployable tags
            tags = [tag for tag in tags if not tag.startswith('deployable:')]

            # Add new deployable tag
            tags.append(f'deployable:{str(deployable).lower()}')

            project_data['tags'] = tags

            with open(project_json_file, 'w') as f:
                json.dump(project_data, f, indent=2)

            print(f"✅ Updated {ctx} tags: deployable={deployable}")
            return True

        except Exception as e:
            print(f"❌ Failed to update service tags: {e}")
            return False

    def remove_service(self, ctx: str) -> bool:
        """Remove service application"""
        service_dir = self.apps_dir / f"{ctx}-svc"

        if not service_dir.exists():
            print(f"❌ Service {ctx}-svc does not exist")
            return False

        try:
            shutil.rmtree(service_dir)
            print(f"✅ Service {ctx}-svc removed successfully")
            return True

        except Exception as e:
            print(f"❌ Failed to remove service: {e}")
            return False

    def clean_workspace(self, targets: List[str]) -> bool:
        """Clean workspace artifacts"""
        try:
            for target in targets:
                if target == "nx":
                    # Clear Nx cache
                    subprocess.run(["npx", "nx", "reset"], check=False)
                elif target == "node_modules":
                    if (self.workspace_root / "node_modules").exists():
                        shutil.rmtree(self.workspace_root / "node_modules")
                elif target == "python":
                    # Clean Python artifacts
                    for pattern in ["__pycache__", "*.pyc", ".pytest_cache", "dist"]:
                        for path in self.workspace_root.rglob(pattern):
                            if path.is_dir():
                                shutil.rmtree(path, ignore_errors=True)
                            elif path.is_file():
                                path.unlink(missing_ok=True)
                elif target == "venv":
                    venv_path = self.workspace_root / ".venv"
                    if venv_path.exists():
                        shutil.rmtree(venv_path)

            print(f"✅ Cleaned targets: {', '.join(targets)}")
            return True

        except Exception as e:
            print(f"❌ Failed to clean workspace: {e}")
            return False

    def _generate_service_main_py(self, ctx: str, transport: str) -> str:
        """Generate main.py content for service"""
        ctx_title = ctx.replace('-', ' ').replace('_', ' ').title()
        ctx_class = ''.join(word.capitalize() for word in ctx.replace('-', '_').split('_'))

        if transport == "fastapi":
            return f'''"""
{ctx_title} Microservice
Auto-generated service wrapper that exposes libs/{ctx} domain logic via FastAPI transport
"""

from fastapi import FastAPI, HTTPException
from contextlib import asynccontextmanager
import uvicorn
import os

# Import domain logic (adjust imports based on your actual structure)
try:
    from libs.{ctx}.application.{ctx}_service import {ctx_class}Service
    from libs.{ctx}.adapters.memory_adapter import Memory{ctx_class}Repository
except ImportError as e:
    print(f"Warning: Could not import domain logic: {{e}}")
    print("You may need to implement the domain classes in libs/{ctx}/")


@asynccontextmanager
async def lifespan(app: FastAPI):
    """Application lifespan manager"""
    print(f"🚀 Starting {ctx_title} service...")
    yield
    print(f"🛑 Shutting down {ctx_title} service...")


app = FastAPI(
    title="{ctx_title} Service",
    description="Microservice for {ctx} domain logic",
    version="1.0.0",
    lifespan=lifespan
)


@app.get("/")
async def root():
    """Health check endpoint"""
    return {{"message": "{ctx_title} service is running", "status": "healthy"}}


@app.get("/health")
async def health_check():
    """Detailed health check"""
    return {{
        "status": "healthy",
        "service": "{ctx}-svc",
        "version": "1.0.0"
    }}


# Add your domain-specific endpoints here
@app.get("/{ctx}")
async def get_{ctx}_info():
    """Get {ctx} information"""
    try:
        # Initialize your service here
        # repository = Memory{ctx_class}Repository()
        # service = {ctx_class}Service(repository)
        # return service.get_info()

        return {{"message": "Implement your {ctx} domain logic here"}}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


if __name__ == "__main__":
    port = int(os.getenv("PORT", "8000"))
    uvicorn.run(
        "main:app",
        host="0.0.0.0",
        port=port,
        reload=True if os.getenv("ENVIRONMENT") == "development" else False
    )
'''
        else:
            return f'''"""
{ctx_title} Microservice
Auto-generated service wrapper for {transport} transport
"""

print("🚀 {ctx_title} service with {transport} transport")
print("⚠️  Transport '{transport}' not yet implemented")
print("💡 Update this file to implement your {transport} service")
'''

    def _generate_service_project_json(self, ctx: str) -> str:
        """Generate project.json for service"""
        return json.dumps({
            "name": f"{ctx}-svc",
            "type": "application",
            "tags": [f"context:{ctx}", "type:service", "deployable:true"],
            "targets": {
                "serve": {
                    "executor": "@nx/python:run",
                    "options": {
                        "command": "python src/main.py"
                    }
                },
                "docker": {
                    "executor": "@nx/docker:build",
                    "options": {
                        "dockerfile": "Dockerfile",
                        "context": "."
                    }
                },
                "test": {
                    "executor": "@nx/python:test",
                    "options": {
                        "testFolder": "tests"
                    }
                }
            }
        }, indent=2)

    def _generate_dockerfile(self, ctx: str) -> str:
        """Generate Dockerfile for service"""
        return f'''# {ctx} Service Dockerfile
FROM python:3.11-slim

WORKDIR /app

# Copy requirements first for better caching
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy source code
COPY src/ ./src/
COPY libs/{ctx}/ ./libs/{ctx}/

# Set Python path
ENV PYTHONPATH=/app

# Expose port
EXPOSE 8000

# Health check
HEALTHCHECK --interval=30s --timeout=30s --start-period=5s --retries=3 \\
    CMD curl -f http://localhost:8000/health || exit 1

# Run the service
CMD ["python", "src/main.py"]
'''

    def _generate_requirements_txt(self, ctx: str) -> str:
        """Generate requirements.txt for service"""
        return '''# Service dependencies
fastapi>=0.104.0
uvicorn[standard]>=0.24.0
pydantic>=2.0.0
httpx>=0.25.0

# Optional: Add your domain-specific dependencies here
# requests>=2.31.0
# sqlalchemy>=2.0.0
# pydantic-settings>=2.0.0
'''

    def _generate_k8s_deployment(self, ctx: str) -> str:
        """Generate Kubernetes deployment manifest"""
        return f'''apiVersion: apps/v1
kind: Deployment
metadata:
  name: {ctx}-svc
  labels:
    app: {ctx}-svc
    context: {ctx}
spec:
  replicas: 2
  selector:
    matchLabels:
      app: {ctx}-svc
  template:
    metadata:
      labels:
        app: {ctx}-svc
        context: {ctx}
    spec:
      containers:
      - name: {ctx}-svc
        image: {ctx}-svc:latest
        ports:
        - containerPort: 8000
        env:
        - name: ENVIRONMENT
          value: "production"
        - name: PORT
          value: "8000"
        resources:
          requests:
            memory: "128Mi"
            cpu: "100m"
          limits:
            memory: "512Mi"
            cpu: "500m"
        livenessProbe:
          httpGet:
            path: /health
            port: 8000
          initialDelaySeconds: 30
          periodSeconds: 10
        readinessProbe:
          httpGet:
            path: /health
            port: 8000
          initialDelaySeconds: 5
          periodSeconds: 5
---
apiVersion: v1
kind: Service
metadata:
  name: {ctx}-svc
  labels:
    app: {ctx}-svc
    context: {ctx}
spec:
  selector:
    app: {ctx}-svc
  ports:
  - name: http
    port: 80
    targetPort: 8000
  type: ClusterIP
'''

    def _generate_k8s_service(self, ctx: str) -> str:
        """Generate Kubernetes service manifest"""
        return f'''apiVersion: v1
kind: Service
metadata:
  name: {ctx}-svc-lb
  labels:
    app: {ctx}-svc
    context: {ctx}
spec:
  selector:
    app: {ctx}-svc
  ports:
  - name: http
    port: 80
    targetPort: 8000
  type: LoadBalancer
'''


def main():
    """Main entry point for the helper script"""
    parser = argparse.ArgumentParser(description="Justfile helper for cross-platform operations")
    parser.add_argument("--workspace-root", default=".", help="Workspace root directory")

    subparsers = parser.add_subparsers(dest="command", help="Available commands")

    # Service status command
    status_parser = subparsers.add_parser("service-status", help="Show service deployment status")

    # Service list command
    list_parser = subparsers.add_parser("service-list", help="List deployable services")

    # Create service app command
    create_app_parser = subparsers.add_parser("create-service-app", help="Create service application")
    create_app_parser.add_argument("--ctx", required=True, help="Context name")
    create_app_parser.add_argument("--transport", default="fastapi", help="Transport type")

    # Create service container command
    create_container_parser = subparsers.add_parser("create-service-container", help="Create service container config")
    create_container_parser.add_argument("--ctx", required=True, help="Context name")

    # Create service k8s command
    create_k8s_parser = subparsers.add_parser("create-service-k8s", help="Create Kubernetes manifests")
    create_k8s_parser.add_argument("--ctx", required=True, help="Context name")

    # Update service tags command
    update_tags_parser = subparsers.add_parser("update-service-tags", help="Update service deployment tags")
    update_tags_parser.add_argument("--ctx", required=True, help="Context name")
    update_tags_parser.add_argument("--deployable", type=str, choices=["true", "false"], required=True, help="Deployable status")

    # Remove service command
    remove_parser = subparsers.add_parser("remove-service", help="Remove service application")
    remove_parser.add_argument("--ctx", required=True, help="Context name")

    # Clean workspace command
    clean_parser = subparsers.add_parser("clean", help="Clean workspace artifacts")
    clean_parser.add_argument("--targets", nargs="+", default=["nx", "python"],
                             choices=["nx", "node_modules", "python", "venv"],
                             help="Targets to clean")

    # Check context exists command
    check_ctx_parser = subparsers.add_parser("check-context", help="Check if context exists")
    check_ctx_parser.add_argument("--ctx", required=True, help="Context name")

    # Check service exists command
    check_svc_parser = subparsers.add_parser("check-service", help="Check if service exists")
    check_svc_parser.add_argument("--ctx", required=True, help="Context name")

    args = parser.parse_args()

    if not args.command:
        parser.print_help()
        return 1

    helper = JustfileHelper(args.workspace_root)

    try:
        if args.command == "service-status":
            contexts = helper.get_deployable_contexts()
            print("📊 Context Deployment Status:")
            print("════════════════════════════════════════════════════════════════")
            for ctx in contexts:
                service_indicator = "✅" if ctx['service_exists'] else "❌"
                print(f"  {ctx['name']:<20} deployable:{str(ctx['deployable']):<8} service:{service_indicator}")
            print("════════════════════════════════════════════════════════════════")

        elif args.command == "service-list":
            services = helper.get_service_list()
            print("🚀 Deployable Services:")
            for service in services:
                print(f"  {service}")

        elif args.command == "create-service-app":
            success = helper.create_service_app(args.ctx, args.transport)
            return 0 if success else 1

        elif args.command == "create-service-container":
            success = helper.create_service_container(args.ctx)
            return 0 if success else 1

        elif args.command == "create-service-k8s":
            success = helper.create_service_k8s(args.ctx)
            return 0 if success else 1

        elif args.command == "update-service-tags":
            deployable = args.deployable.lower() == "true"
            success = helper.update_service_tags(args.ctx, deployable)
            return 0 if success else 1

        elif args.command == "remove-service":
            success = helper.remove_service(args.ctx)
            return 0 if success else 1

        elif args.command == "clean":
            success = helper.clean_workspace(args.targets)
            return 0 if success else 1

        elif args.command == "check-context":
            exists = helper.check_context_exists(args.ctx)
            if exists:
                print(f"✅ Context {args.ctx} exists")
                return 0
            else:
                print(f"❌ Context {args.ctx} not found")
                return 1

        elif args.command == "check-service":
            exists = helper.check_service_exists(args.ctx)
            if exists:
                print(f"✅ Service {args.ctx}-svc exists")
                return 0
            else:
                print(f"❌ Service {args.ctx}-svc not found")
                return 1

        return 0

    except Exception as e:
        print(f"❌ Error: {e}")
        return 1


if __name__ == "__main__":
    sys.exit(main())
