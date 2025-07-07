import os
import sys
from pathlib import Path

CATEGORIES = [
    ("entities", "libs/{domain}/domain/entities/{name}.py"),
    ("services", "libs/{domain}/application/{name}.py"),
    ("ports", "libs/{domain}/adapters/{name}.py"),
    ("libs", "libs/{name}/__init__.py"),
    ("apps", "apps/{name}/src/main.py"),
    ("tools", "tools/generators/{name}/__init__.py"),
    ("docker", "docker/{name}.Dockerfile"),
]

TEMPLATES = {
    "entities": "class {name}:
    def __init__(self):
        pass\n",
    "services": "class {name}:
    def __init__(self):
        pass\n",
    "ports": "class {name}:
    def __init__(self):
        pass\n",
    "libs": "# {name} shared library\n",
    "apps": "# FastAPI app entry for {name}\nfrom fastapi import FastAPI\napp = FastAPI()\n",
    "tools": "# Generator tool: {name}\n",
    "docker": "# Dockerfile for {name}\nFROM python:3.11-slim\n",
}

def read_list(path):
    if not os.path.exists(path):
        return []
    with open(path) as f:
        return [line.strip() for line in f if line.strip() and not line.startswith('#')]

def ensure_init_py(path):
    d = os.path.dirname(path)
    while d and d != os.path.dirname(d):
        init = os.path.join(d, "__init__.py")
        if not os.path.exists(init) and "libs" in d:
            Path(init).touch()
        d = os.path.dirname(d)

def main():
    if len(sys.argv) < 2:
        print("Usage: python scripts/generate_domain.py <domain>")
        sys.exit(1)
    domain = sys.argv[1]
    base = f"project-definitions/{domain}"
    if not os.path.isdir(base):
        print(f"No definition folder found: {base}")
        sys.exit(1)
    for cat, target in CATEGORIES:
        items = read_list(os.path.join(base, f"{cat}.txt"))
        for name in items:
            fname = target.format(domain=domain, name=name)
            os.makedirs(os.path.dirname(fname), exist_ok=True)
            with open(fname, "w") as f:
                f.write(TEMPLATES[cat].format(name=name))
            if cat in ("entities", "services", "ports", "libs"):
                ensure_init_py(fname)
    # README
    readme = f"libs/{domain}/README.md"
    with open(readme, "w") as f:
        f.write(f"# {domain}\n\nGenerated with MECE-driven generator.\n")
    print(f"Domain '{domain}' generated.")

if __name__ == "__main__":
    main()
