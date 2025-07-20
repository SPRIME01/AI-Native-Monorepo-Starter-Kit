import subprocess
import os
import sys
import shutil
import argparse

def run_command(command: list[str], description: str = "", check: bool = True, capture_output: bool = False):
    """Runs a shell command and prints its output. Raises an exception if the command fails."""
    print(f"Executing: {description} {' '.join(command)}")
    try:
        result = subprocess.run(command, check=check, capture_output=capture_output, text=True)
        if capture_output:
            print(result.stdout)
        return result
    except subprocess.CalledProcessError as e:
        print(f"Error executing command: {e}")
        if e.stdout:
            print(f"Stdout: {e.stdout}")
        if e.stderr:
            print(f"Stderr: {e.stderr}")
        sys.exit(1)
    except FileNotFoundError:
        print(f"Error: Command not found. Please ensure '{command[0]}' is installed and in your PATH.")
        sys.exit(1)

def init_nx(nx_python_plugin_version: str):
    print("🏗️ Initializing Nx workspace with pnpm...")
    if not os.path.exists("pnpm-lock.yaml"):
        run_command(["npx", "create-nx-workspace@latest", ".", "--nxCloud=skip", "--preset=react-standalone", "--pm=pnpm"],
                    "Running npx create-nx-workspace...")
        run_command(["pnpm", "add", "-D", f"@nxlv/python@{nx_python_plugin_version}"],
                    "Adding @nxlv/python plugin...")
    else:
        print("Nx workspace already initialized. Skipping.")
    print("✅ Nx workspace ready.")

def init_python_env(python_version: str, rust_toolchain_uv_install: bool, root_pyproject_toml: str, monorepo_root: str):
    print("🐍 Setting up Python environment with pyenv and uv...")

    # Check for pyenv
    try:
        run_command(["pyenv", "--version"], "Checking pyenv installation...", check=True)
    except SystemExit: # run_command exits if pyenv is not found
        print("pyenv not found. Please install pyenv first: https://github.com/pyenv/pyenv#installation")
        sys.exit(1)

    # Install Python version
    print(f"Installing Python {python_version}...")
    run_command(["pyenv", "install", python_version], check=False) # pyenv install returns 0 even if already installed

    # Set local Python version
    print(f"Setting local Python version to {python_version}...")
    run_command(["pyenv", "local", python_version])

    # Check for uv installation
    print("Checking for uv installation...")
    try:
        run_command(["uv", "--version"], "Checking uv installation...", check=True)
        print("uv already installed. Skipping.")
    except SystemExit: # run_command exits if uv is not found
        if rust_toolchain_uv_install:
            print("Installing uv via cargo (Rust toolchain required)...")
            run_command(["cargo", "install", "uv"])
        else:
            print("Installing uv via pip...")
            run_command([os.path.join(monorepo_root, ".venv", "bin", "pip"), "install", "uv"]) # Use venv pip

    # Create/update root pyproject.toml
    print("Creating/updating root pyproject.toml...")
    pyproject_content = f"""
[project]
name = "monorepo-dev-env"
version = "0.0.1"

[project.optional-dependencies]
dev = [
    "ruff",
    "mypy",
    "pytest",
    "uv"
]

[build-system]
requires = ["uv>=0.1.0"]
build-backend = "setuptools.build_meta"
"""
    with open(root_pyproject_toml, "w") as f:
        f.write(pyproject_content)
    print("✅ Python environment setup complete.")

def install_custom_py_generator(custom_py_gen_plugin_name: str):
    print("📦 Installing custom Python generator plugin...")
    
    # Create the tools/generators directory structure for the custom generators
    import shutil
    import os
    import json
    
    tools_generators_dir = "tools/generators"
    make_assets_dir = ".make_assets"
    
    try:
        # Ensure tools/generators directory exists
        os.makedirs(tools_generators_dir, exist_ok=True)
        print(f"📁 Ensured directory exists: {tools_generators_dir}")
        
        # Check if .make_assets directory exists
        if not os.path.exists(make_assets_dir):
            print(f"❌ Error: Source directory not found: {make_assets_dir}")
            print("💡 This directory should contain the generator templates.")
            print("💡 Please ensure the project is properly set up.")
            return
        
        generators_installed = 0
        
        # Install shared-python-app generator
        app_generator_src = os.path.join(make_assets_dir, "shared-python-app")
        app_generator_dest = os.path.join(tools_generators_dir, "shared-python-app")
        
        if os.path.exists(app_generator_src):
            try:
                if os.path.exists(app_generator_dest):
                    shutil.rmtree(app_generator_dest)
                    print(f"🗑️  Removed existing generator: {app_generator_dest}")
                
                shutil.copytree(app_generator_src, app_generator_dest)
                print(f"✅ Installed shared-python-app generator to {app_generator_dest}")
                generators_installed += 1
            except Exception as e:
                print(f"❌ Error installing shared-python-app generator: {e}")
        else:
            print(f"⚠️  Source generator not found: {app_generator_src}")
            print("💡 This generator is needed for creating Python applications.")
        
        # Install shared-python-lib generator
        lib_generator_src = os.path.join(make_assets_dir, "shared-python-lib")
        lib_generator_dest = os.path.join(tools_generators_dir, "shared-python-lib")
        
        if os.path.exists(lib_generator_src):
            try:
                if os.path.exists(lib_generator_dest):
                    shutil.rmtree(lib_generator_dest)
                    print(f"🗑️  Removed existing generator: {lib_generator_dest}")
                
                shutil.copytree(lib_generator_src, lib_generator_dest)
                print(f"✅ Installed shared-python-lib generator to {lib_generator_dest}")
                generators_installed += 1
            except Exception as e:
                print(f"❌ Error installing shared-python-lib generator: {e}")
        else:
            print(f"⚠️  Source generator not found: {lib_generator_src}")
            print("💡 This generator is needed for creating Python libraries.")
        
        if generators_installed == 0:
            print("❌ No generators were installed successfully.")
            print("💡 Please check that the .make_assets directory contains the generator templates.")
            return
        
        # Create a generators.json file to register the generators with Nx
        generators_config = {
            "generators": {
                f"{custom_py_gen_plugin_name}:shared-python-app": {
                    "factory": "./tools/generators/shared-python-app/generator",
                    "schema": "./tools/generators/shared-python-app/schema.json",
                    "description": "Generate a Python application with custom settings"
                },
                f"{custom_py_gen_plugin_name}:shared-python-lib": {
                    "factory": "./tools/generators/shared-python-lib/generator",
                    "schema": "./tools/generators/shared-python-lib/schema.json", 
                    "description": "Generate a Python library with custom settings"
                }
            }
        }
        
        # Write generators configuration
        generators_config_path = "tools/generators.json"
        try:
            with open(generators_config_path, 'w') as f:
                json.dump(generators_config, f, indent=2)
            print(f"✅ Created generators configuration at {generators_config_path}")
        except Exception as e:
            print(f"❌ Error creating generators configuration: {e}")
            return
        
        print("✅ Custom Python generator plugin installation complete.")
        print(f"💡 You can now use: nx generate {custom_py_gen_plugin_name}:shared-python-app <name>")
        print(f"💡 You can now use: nx generate {custom_py_gen_plugin_name}:shared-python-lib <name>")
        print("💡 Example: just app NAME=my-service")
        print("💡 Example: just lib NAME=my-library")
        
    except Exception as e:
        print(f"❌ Unexpected error during generator installation: {e}")
        print("💡 Please check file permissions and try again.")
        print("💡 If the issue persists, you may need to install generators manually.")

def update_service_tags(ctx: str, deployable: str):
    """Update deployable tags for a context in its project.json file."""
    import json
    
    project_file = f"libs/{ctx}/project.json"
    
    if not os.path.exists(project_file):
        print(f"❌ libs/{ctx}/project.json not found.")
        sys.exit(1)
    
    try:
        with open(project_file, 'r') as f:
            data = json.load(f)
        
        # Initialize tags if not present
        if 'tags' not in data:
            data['tags'] = []
        
        # Remove existing deployable tag
        data['tags'] = [tag for tag in data['tags'] if not tag.startswith('deployable:')]
        
        # Add new deployable tag
        data['tags'].append(f'deployable:{deployable}')
        
        with open(project_file, 'w') as f:
            json.dump(data, f, indent=2)
        
        print('✅ Tag updated.')
    except Exception as e:
        print(f'❌ Failed to update tag: {e}')
        sys.exit(1)

def install_pre_commit():
    print("🎣 Installing pre-commit hooks...")
    try:
        run_command(["pre-commit", "--version"], "Checking pre-commit installation...", check=True)
    except SystemExit:
        print("pre-commit not found. Installing...")
        run_command([sys.executable, "-m", "pip", "install", "pre-commit"]) # Use current python's pip

    run_command(["pre-commit", "install", "--config", ".make_assets/.pre-commit-config.yaml"])
    print("✅ Pre-commit hooks installed.")

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Monorepo setup script.")
    parser.add_argument("action", help="Action to perform (e.g., init_nx, init_python_env, install_pre_commit)")
    parser.add_argument("--python-version", default="3.11.9", help="Python version to install via pyenv.")
    parser.add_argument("--nx-python-plugin-version", default="21.0.3", help="Version of @nxlv/python Nx plugin.")
    parser.add_argument("--rust-toolchain-uv-install", action="store_true", help="Install uv via rustup/cargo.")
    parser.add_argument("--root-pyproject-toml", default=os.path.join(os.getcwd(), "pyproject.toml"),
                        help="Path to the root pyproject.toml file.")
    parser.add_argument("--monorepo-root", default=os.getcwd(), help="Path to the monorepo root directory.")
    parser.add_argument("--custom-py-gen-plugin-name", default="shared-python-tools",
                        help="Name of the custom Python generator plugin.")
    parser.add_argument("--ctx", help="Context name for service tag updates.")
    parser.add_argument("--deployable", help="Deployable flag (true/false) for service tag updates.")

    args = parser.parse_args()

    if args.action == "init_nx":
        init_nx(args.nx_python_plugin_version)
    elif args.action == "init_python_env":
        init_python_env(args.python_version, args.rust_toolchain_uv_install, args.root_pyproject_toml, args.monorepo_root)
    elif args.action == "install_custom_py_generator":
        install_custom_py_generator(args.custom_py_gen_plugin_name)
    elif args.action == "install_pre_commit":
        install_pre_commit()
    elif args.action == "update_service_tags":
        if not args.ctx or not args.deployable:
            print("❌ Error: --ctx and --deployable arguments are required for update_service_tags")
            parser.print_help()
            exit(1)
        update_service_tags(args.ctx, args.deployable)
    else:
        print(f"Unknown action: {args.action}")
        parser.print_help()
        exit(1)