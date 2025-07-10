# Supabase Configuration and Optimization

This document outlines the configuration, integration, and optimization strategies for Supabase within this project, focusing on a minimal and robust setup.

## 1. Core Configuration

### 1.1. Environment Variables

Supabase access is managed via environment variables. Consistency across all configuration files is crucial.

*   **`SUPABASE_URL`**: The URL of your Supabase instance. For local development, this typically points to `http://localhost:54323`. For remote deployments, it will be your project's unique Supabase URL.
*   **`SUPABASE_ANON_KEY`**: The public "anon" key for your Supabase project. This is safe to use in client-side applications.

**Key Points:**
*   Ensure `SUPABASE_URL` and `SUPABASE_ANON_KEY` are consistently defined in your `.env` file (which is not version-controlled) and referenced in `.env.template`.
*   Duplicate or conflicting Supabase environment variable definitions have been removed from `.env.template` to prevent confusion.

### 1.2. Python Version Compatibility

To ensure compatibility with project dependencies, the required Python version has been updated.

*   **`pyproject.toml`**: The `requires-python` field in `pyproject.toml` has been updated to `>=3.12` to align with the requirements of `python-dotenv` and other project dependencies.

## 2. Supabase Client Integration

The `get_supabase_client()` function in `libs/shared/data_access/supabase/client.py` is responsible for establishing a connection to your Supabase instance.

### 2.1. Enhanced Error Handling

The client now includes more robust error handling to provide clearer feedback during connection issues.

*   If `SUPABASE_URL` or `SUPABASE_ANON_KEY` are not set, a `ValueError` is raised.
*   Any exceptions during the client creation or initial connection attempt are caught, and a `ConnectionError` is raised with a more informative message, guiding the user to check their `.env` file and Supabase service status.

### 2.2. Local vs. Remote Connection Handling

The `get_supabase_client()` function intelligently adapts its connection verification based on the `SUPABASE_URL`.

*   **Local Supabase (`localhost` in URL)**: If the `SUPABASE_URL` contains "localhost", the client will be created, but an immediate connection verification query (`client.from_('vectors').select('id').limit(0).execute()`) will be skipped. This allows the client to be initialized even if the local Supabase services are not actively running, facilitating development and testing without requiring a full local deployment.
*   **Remote Supabase (no `localhost` in URL)**: For remote Supabase instances, the client will attempt a connection verification query to ensure connectivity before returning the client object.

## 3. Supabase CLI Wrapper

The `tools/supa_cli/main.py` script provides a convenient wrapper for common Supabase CLI commands.

### 3.1. Command Execution Context

To ensure Supabase CLI commands execute correctly, `os.chdir` has been added to relevant functions within `main.py`.

*   Commands like `supa_reset()`, `supa_seed()`, `supa_types()`, and `supa_status()` now temporarily change the current working directory to the `supabase/` directory before executing the `supabase` command. This ensures that the CLI commands operate within the correct project context, preventing potential errors related to file paths or configuration.

## 4. Testing

Comprehensive tests are in place to verify the Supabase integration.

### 4.1. `test_supabase.py`

The `tests/test_supabase.py` file contains tests for Supabase connectivity and basic operations.

*   **Conditional Testing**: The `test_supabase_connection()` function now conditionally performs insert/select operations.
    *   If `SUPABASE_URL` points to a local instance (`localhost`), the test only verifies that the Supabase client can be successfully created, skipping actual data operations.
    *   If `SUPABASE_URL` points to a remote instance, the test proceeds with insert, select, and cleanup operations to ensure full functionality.
*   **Environment Loading**: `pytest-dotenv` is utilized to load environment variables from the `.env` file during test execution, ensuring tests run with the correct Supabase credentials.

### 4.2. Dependency Pinning

All Python dependencies are strictly pinned to their versions to ensure a stable and reproducible development environment.

*   **`pyproject.toml`**: Dependency versions in `pyproject.toml` are explicitly defined (e.g., `supabase==2.16.0`, `python-dotenv==1.1.1`).
*   **`uv pip install`**: The `uv pip install -e .[dev,supabase]` command is used to install these pinned dependencies, guaranteeing that the exact versions are used across all environments.

## 5. Minimal Footprint Principles

Throughout the Supabase setup and integration, the following "minimal footprint" principles have been adhered to:

*   **Lean Architecture**: Prioritizing essential services and configurations.
*   **Fewer Python Dependencies**: Auditing and reducing unnecessary Python packages.
*   **Optimized Code & Data Handling**: Writing memory-efficient Python code and ensuring efficient Supabase queries.

These principles contribute to a lower system footprint and reduced RAM consumption during both development and application runtime.