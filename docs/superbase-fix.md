Alright, agent. No more chatter. Here are your consolidated, direct, and imperative instructions to get this Supabase setup lean and mean. Stick to these actions, and report only on completion or critical blockers.

---

## Supabase Configuration & Minimal Footprint Setup

### 1. Configure Remote Supabase Access

* **ACTION:** Verify `SUPABASE_URL` and `SUPABASE_KEY` (which maps to `SUPABASE_ANON_KEY` in `.env`) are correctly utilized for remote access, if mapping is incorrect fix it.
* **STATE:** The `.env` file is corrected.
* **ACTION:** Re-start local Supabase services.

---

### 2. Define "Minimal Development"

* **OBJECTIVE:** Achieve the lowest possible system footprint and RAM consumption during both development and application runtime. This means **lean architecture, minimal resource allocation, and optimized code execution.**

* **ACTION:** Interpret "minimal" as follows and apply these principles throughout all subsequent tasks:
    * **Minimal Supabase Setup:** Deploy and run *only* essential Supabase services. Configure the local Supabase environment to selectively enable components, pruning any unnecessary services (e.g., Realtime, Storage, Functions) if not actively in use.
    * **Fewer Python Dependencies:** Drastically reduce installed Python packages and their transitive dependencies.
        * **ACTION:** Audit `pyproject.toml` (or `requirements.txt`) to identify and remove unutilized or redundant packages.
        * **ACTION:** Prioritize lightweight, direct libraries for essential functionalities.
        * **ACTION:** Investigate if core Python modules can replace external dependencies.
        * **ACTION:** Pin dependency versions strictly.
    * **Lighter-Weight Tooling:** Select development tools that consume minimal system resources.
        * **ACTION:** Prioritize lightweight editors over feature-heavy IDEs.
        * **ACTION:** Maximize CLI usage for common tasks.
        * **ACTION:** If using Docker, optimize Docker images for size (multi-stage builds, minimal base images) and set resource limits.
    * **Optimized Code & Data Handling (General):** Write Python code that is inherently memory-efficient.
        * **ACTION:** Utilize generator expressions and iterators for large data processing.
        * **ACTION:** Employ memory-efficient data structures (`tuple`, `set`).
        * **ACTION:** Explicitly `del` large objects when no longer needed.
        * **ACTION:** Implement lazy loading for resources.
        * **ACTION:** Ensure Supabase queries fetch only necessary columns and rows; apply Row Level Security (RLS) effectively.
        * **ACTION:** Profile code regularly for memory usage using tools like `memory_profiler`.

---

### 3. Optimize Supabase Integration for Robust, Minimal Setup

* **OBJECTIVE:** Analyze Supabase integration, eliminate technical debt, and establish a robust, minimal setup for development, testing, and application use, adhering to best practices defined above.

#### Execution Plan:

1.  **Analyze Current State:**
    * **SCOPE:** Review the Supabase client, tests, environment files, and CLI wrapper scripts.
    * **GOAL:** Understand existing implementation and identify improvement areas for footprint and RAM reduction.

2.  **Identify Technical Debt & Best Practices:**
    * **FOCUS:** Consistent environment variable naming, robust error handling, comprehensive testing, proper dependency management, and reliable CLI integration, all while keeping the "minimal" objective paramount.

3.  **Implement Proposed Changes:**
    * **ACTION:** **Standardize Environment Variables:** Ensure `SUPABASE_URL` and `SUPABASE_ANON_KEY` are consistently used across `client.py`, `.env`, and `.env.template`.
    * **ACTION:** **Improve Supabase Client:** Enhance error handling within `get_supabase_client`.
    * **ACTION:** **Refine Supabase CLI Wrapper:** Add `os.chdir` to `tools/supa_cli/main.py` to ensure Supabase commands execute in the correct context.
    * **ACTION:** **Enhance Supabase Test:** Modify `tests/test_supabase.py` to include a simple insert/select operation with proper cleanup. Ensure `pytest-dotenv` is utilized for environment loading.
    * **ACTION:** **Update `pyproject.toml`:** Adjust dependencies and `pytest` configuration for optimal environment variable loading and package discovery, strictly adhering to the "fewer Python dependencies" directive.

4.  **Execute & Test:**
    * **PROCESS:** Implement changes sequentially.
    * **VERIFICATION:** Test at each critical juncture, ensuring no increase in footprint or RAM and ideally a reduction.

---

**INITIATE:** Begin immediately by standardizing environment variable names. Update `libs/shared/data_access/supabase/client.py` to consistently use `SUPABASE_URL` and `SUPABASE_ANON_KEY`.

---

These are your marching orders. Proceed.
