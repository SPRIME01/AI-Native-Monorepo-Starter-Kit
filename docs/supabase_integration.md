# Supabase Integration and Minimal Footprint Documentation

This document outlines the setup, configuration, and best practices for integrating Supabase into the AI-Native Monorepo Starter Kit, with a strong emphasis on maintaining a minimal development footprint. It adheres to the Diataxis documentation framework, providing Tutorials, How-to Guides, Reference information, and Explanations.

---

## 1. Tutorials: Getting Started with Supabase

This section guides you through the initial setup of Supabase for your project, covering both local and remote configurations.

### 1.1. Setting Up Supabase Environment Variables

To connect your application to Supabase, you need to configure the necessary environment variables.

**Steps:**

1.  **Locate the `.env.template` file:** This file provides a template for all required environment variables.
    ```bash
    # Path: .env.template
    SUPABASE_URL="your_supabase_url_here"
    SUPABASE_ANON_KEY="your_supabase_anon_key_here"
    ```
2.  **Create your `.env` file:** Copy the contents of `.env.template` to a new file named `.env` in the project root. This file is ignored by Git and should contain your actual secrets.
    ```bash
    cp .env.template .env
    ```
3.  **Populate `.env` with your Supabase credentials:**
    *   If you are using a **remote Supabase project**, obtain your `SUPABASE_URL` and `SUPABASE_ANON_KEY` from your Supabase project settings (API section).
    *   If you plan to use **local Supabase development**, set `SUPABASE_URL` to `http://localhost:54323` and `SUPABASE_ANON_KEY` to `your-anon-key` (the default for local Supabase).
    *   **Important:** Ensure that `SUPABASE_URL` and `SUPABASE_ANON_KEY` are consistently used. Avoid using `SUPABASE_KEY` or `SUPABASE_SERVICE_ROLE_KEY` directly in application code unless specifically required for server-side operations.

### 1.2. Starting and Stopping Local Supabase Services

If you are developing with a local Supabase instance, you can manage its services using the provided CLI wrapper.

**Steps:**

1.  **Start Supabase services:**
    ```bash
    uv run python tools/supa_cli/main.py up
    ```
    This command will start the necessary Docker containers for your local Supabase instance.
2.  **Stop Supabase services:**
    ```bash
    uv run python tools/supa_cli/main.py down
    ```
    This command will gracefully stop the running Supabase Docker containers.

---

## 2. How-to Guides: Practical Operations

This section provides step-by-step instructions for common tasks related to Supabase integration and maintaining a minimal footprint.

### 2.1. Optimizing Python Dependencies for Minimal Footprint

To keep the project lean and reduce resource consumption, it's crucial to manage Python dependencies effectively.

**Steps:**

1.  **Audit `pyproject.toml`:** Regularly review the `[project.optional-dependencies]` section in `pyproject.toml` to identify and remove any unutilized or redundant packages.
2.  **Prioritize lightweight libraries:** When adding new functionality, prefer libraries that have minimal dependencies themselves.
3.  **Pin dependency versions:** All dependencies should have their versions strictly pinned in `pyproject.toml` to ensure reproducible builds and prevent unexpected dependency conflicts.
    *   **Example:** `supabase = ["supabase==2.16.0", "python-dotenv==1.1.1"]`
4.  **Install dependencies:** After modifying `pyproject.toml`, always reinstall dependencies to apply changes:
    ```bash
    uv pip install -e .[dev,supabase]
    ```

### 2.2. Using the Supabase CLI Wrapper

The `tools/supa_cli/main.py` script provides a convenient wrapper for common Supabase CLI commands, ensuring they execute in the correct project context.

**Available Commands:**

*   **`up`**: Starts local Supabase services.
    ```bash
    uv run python tools/supa_cli/main.py up
    ```
*   **`down`**: Stops local Supabase services.
    ```bash
    uv run python tools/supa_cli/main.py down
    ```
*   **`reset`**: Resets the local Supabase database, applying migrations and seeding data.
    ```bash
    uv run python tools/supa_cli/main.py reset
    ```
*   **`seed`**: Seeds the local Supabase database (typically part of `reset` with `--data-only`).
    ```bash
    uv run python tools/supa_cli/main.py seed
    ```
*   **`types`**: Generates TypeScript types from your Supabase schema.
    ```bash
    uv run python tools/supa_cli/main.py types
    ```
*   **`status`**: Checks the status of local Supabase services.
    ```bash
    uv run python tools/supa_cli/main.py status
    ```

### 2.3. Testing Supabase Integration

The project includes tests to verify the Supabase client connection and basic operations.

**Steps:**

1.  **Ensure `.env` is configured:** Make sure your `.env` file has `SUPABASE_URL` and `SUPABASE_ANON_KEY` set correctly.
2.  **Run tests:**
    ```bash
    uv run pytest
    ```
    *   If `SUPABASE_URL` points to `localhost`, the test will only verify client creation without attempting data operations.
    *   If `SUPABASE_URL` points to a remote instance, the test will perform an insert/select operation with cleanup.

---

## 3. Reference: Technical Details

This section provides detailed technical information about the Supabase integration components.

### 3.1. `get_supabase_client()` Function

*   **Location:** `libs/shared/data_access/supabase/client.py`
*   **Purpose:** This function initializes and returns a Supabase client instance. It loads `SUPABASE_URL` and `SUPABASE_ANON_KEY` from environment variables.
*   **Error Handling:**
    *   Raises `ValueError` if `SUPABASE_URL` or `SUPABASE_ANON_KEY` are not set.
    *   Raises `ConnectionError` if the client fails to connect to Supabase.
    *   **Conditional Connection Verification:** If `SUPABASE_URL` contains "localhost", the function will *not* attempt a live database query to verify the connection, allowing it to be used in environments where local Supabase might not be running. For remote URLs, a simple query is executed to confirm connectivity.

### 3.2. `pyproject.toml` Dependency Management

The `pyproject.toml` file manages Python project metadata and dependencies.

*   **`[project.optional-dependencies]`**: This section defines groups of optional dependencies.
    *   `dev`: Contains development tools like `pytest`, `ruff`, `mypy`, `pre-commit`, `uv`, and `pytest-dotenv`.
    *   `supabase`: Contains core Supabase client libraries like `supabase` and `python-dotenv`.
*   **Dependency Pinning:** All dependencies are strictly pinned to specific versions (e.g., `supabase==2.16.0`) to ensure build reproducibility and prevent unexpected breaking changes from new library versions.
*   **`requires-python`**: Specifies the minimum required Python version for the project (currently `>=3.12`).

### 3.3. Supabase Environment Variables

*   **`SUPABASE_URL`**: The URL of your Supabase project. For local development, this is typically `http://localhost:54323`.
*   **`SUPABASE_ANON_KEY`**: The "anon" public key for your Supabase project. This key is safe to use in client-side applications.

---

## 4. Explanation: Underlying Concepts and Rationale

This section delves into the "why" behind the design choices, providing context and deeper understanding.

### 4.1. The "Minimal Development" Philosophy

The core objective of this project's Supabase integration is to achieve the lowest possible system footprint and RAM consumption during development and application runtime. This philosophy is driven by:

*   **Resource Efficiency:** Minimizing the consumption of system resources (CPU, RAM, disk space) leads to faster development cycles, quicker feedback loops, and a more responsive development environment, especially on machines with limited resources.
*   **Cost Optimization:** For deployed applications, a minimal footprint translates directly to lower infrastructure costs.
*   **Faster Builds and Deployments:** Fewer dependencies and optimized code result in smaller build artifacts and quicker deployment times.
*   **Reduced Attack Surface:** A smaller codebase with fewer external dependencies inherently reduces the potential attack surface, improving security.

This philosophy is applied across:
*   **Minimal Supabase Setup:** Only essential Supabase services are enabled locally.
*   **Fewer Python Dependencies:** Aggressive pruning of unnecessary packages.
*   **Lighter-Weight Tooling:** Preference for resource-efficient development tools.
*   **Optimized Code & Data Handling:** Writing memory-efficient Python code and optimizing Supabase queries.

### 4.2. Conditional Supabase Connection Testing Rationale

The `test_supabase_connection` in `tests/test_supabase.py` and the `get_supabase_client` function in `libs/shared/data_access/supabase/client.py` implement conditional logic based on the `SUPABASE_URL`.

**Rationale:**

*   **Developer Experience:** When developing locally, developers often do not have the local Supabase Docker containers running constantly. Attempting a full database connection in tests or client initialization would lead to frequent failures and a frustrating development experience.
*   **Flexibility:** This approach allows developers to seamlessly switch between local and remote Supabase instances without constantly modifying test logic or client initialization.
*   **Focused Testing:**
    *   For local development (`localhost` URL), the test focuses on verifying that the environment variables are correctly loaded and the client object can be instantiated. This confirms the basic setup without requiring a live database connection.
    *   For remote deployments, a full connection and data operation test is crucial to ensure end-to-end connectivity and functionality.

### 4.3. Rationale for Strict Dependency Pinning

Strict dependency pinning in `pyproject.toml` (e.g., `package==X.Y.Z`) is a critical practice for several reasons:

*   **Reproducible Builds:** Ensures that every time the project's dependencies are installed, the exact same versions are used. This prevents "it works on my machine" scenarios and ensures consistency across development, testing, and production environments.
*   **Stability:** Prevents unexpected breaking changes that might be introduced in newer versions of dependencies. If a new version of a library introduces a bug or an incompatible API change, pinning ensures your project continues to use the stable version.
*   **Easier Debugging:** If a bug appears, you can be confident that it's not due to an unannounced dependency update. This significantly narrows down the scope of debugging.
*   **Security:** While not a primary security measure, pinning helps in controlling the exact versions of libraries, allowing for more precise vulnerability management. If a vulnerability is found in a specific version, you know exactly which version you are using and can plan an upgrade.

---
