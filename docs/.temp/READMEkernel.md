# Core Homelab Infrastructure as Code (IaC) Specification

This document outlines the specification for building a robust, reproducible, and idempotent homelab environment using Infrastructure as Code (IaC) principles, orchestrated within the existing AI-Native Monorepo Starter Kit. This IaC project leverages the monorepo's capabilities, including Nx for project management and Make for orchestration, to provide a seamless developer experience.

## 1. Introduction: The AI-Native Monorepo and Infrastructure as Code

The AI-Native Monorepo Starter Kit is built on Nx, Domain-Driven Design (DDD), and Hexagonal Architecture principles. It provides a structured environment for developing cross-platform applications with TypeScript and Python, supporting microservices and ML operations. This IaC project extends the monorepo's capabilities to manage the underlying infrastructure, ensuring consistency and automation from development to deployment.

## 2. Core Homelab IaC Specification

The primary objective is to create a single, reproducible, and idempotent automation solution for a personal homelab, driven primarily by `Make` and optionally integrated with `Nx`.

### 2.1. Environment Details

*   **Host OS**: Windows 11 Pro (static IP: `192.168.0.50`)
*   **Guest OS**: Ubuntu 22.04 WSL 2 (static IP: `192.168.0.51`)
*   **SSH Key Sharing**: Both Windows and WSL 2 share the same `ed25519` SSH key for authentication and operations.

### 2.2. Key Capabilities

The IaC automation must be capable of:

1.  **Auditing**: Intelligently audit the WSL instance to determine necessary installations and configurations.
2.  **Installation & Configuration**: Install and configure the following components:
    *   **Ansible**: For declarative host automation.
    *   **Pulumi (latest LTS)**: For cloud resource provisioning (if applicable).
    *   **k3s**: A lightweight Kubernetes distribution, specifically configured *without* the bundled Traefik ingress controller.
    *   **Kubernetes Workloads (MECE Set)**: A small, mutually exclusive, and collectively exhaustive (MECE) set of essential homelab Kubernetes workloads:
        *   Traefik Ingress (as a separate deployment)
        *   Cert-Manager
        *   Secrets-Store-CSI
        *   Authelia (for authentication)
        *   Bitwarden (password manager)
        *   Apache Guacamole (remote desktop gateway)
        *   Home-Page Dashboard
3.  **Network Preservation**: Preserve existing static IPs and firewall rules, or extend them non-destructively.
4.  **SSH Key Reuse**: Seamlessly reuse the shared SSH keypair for all Git, Ansible, and k3s operations.
5.  **Idempotency**: Be re-runnable multiple times without harmful side-effects, always converging to the desired state.
6.  **Maintainability**: Ensure low technical debt through clear commenting, modular design, and dependency pinning.

## 3. IaC Design and Approach

### 3.1. Guiding Principles

*   **Idempotency First**: Every operation is designed to be safe for re-execution. Ansible's declarative nature and `kubectl apply --server-side` are leveraged for this.
*   **Audit Before Act**: Each significant step includes a corresponding `check-*` target to inspect the current state and provide a summary (e.g., JSON/YAML). Action targets (`install-*`, `deploy-*`) depend on these checks and will exit early if no changes are required.
*   **Make as the Top-Level Orchestrator**: `Make` is chosen for its strength in expressing dependency graphs and incremental execution. It delegates heavy lifting (package installations, YAML templating, Helm charts) to specialized tools.
*   **WSL-Friendly**: Avoid assumptions about `systemd`. `k3s` will be run via its bundled OpenRC service with `k3s server --disable traefik`.
*   **Minimal Footprint, Explicit Versions**: Tool versions are explicitly pinned in a central location (e.g., `versions.mk` or `.env` file).
*   **Batteries-Included Dev UX**: A single `make bootstrap` command should bring up the entire micro-homelab. `make status` provides a concise summary of the environment.

### 3.2. Technology Stack

| Layer               | Tool                      | Rationale                                                              |
| :------------------ | :------------------------ | :--------------------------------------------------------------------- |
| Automation Driver   | **GNU Make**              | Simple, ubiquitous, tracks dependencies, excellent for orchestration.  |
| Provisioner         | **Ansible**               | Declarative, idempotent, ideal for local host automation.              |
| Cluster Installer   | **k3sup** or raw **k3s install.sh** | One-liner installation, supports disabling Traefik.                    |
| IaC for Cloud (Optional) | **Pulumi**             | Leverages shared SSH key; state can be managed locally or in S3-compatible storage. |
| K8s Package Manager | **Helm** + **kubectl**    | Helm for chart management, `kubectl` for direct YAML application.      |
| Secrets Management  | **sops-age**              | Cross-platform age keys, integrates with Ansible and Pulumi.           |

### 3.3. High-Level Workflow (`make bootstrap`)

```
make bootstrap
│
├─ check-prereqs  →  install-prereqs
│                     ├─ ansible
│                     ├─ pulumi
│                     └─ k3sup
├─ k3s-ready     →  install-k3s
│                     └─ post-k3s-tweaks (sysctl, iptables)
└─ apps-ready    →  deploy-apps
      ├─ traefik
      ├─ cert-manager
      ├─ bitwarden
      ├─ authelia
      ├─ guacamole
      └─ homepage
```

Each `*-ready` target will create a stamp file under `.state/` to enable `Make` to skip the corresponding `install-*` or `deploy-*` step on subsequent runs, ensuring idempotency and efficiency.

### 3.4. Auditing Strategy

*   **`check-prereqs`**: Detects package managers (`apt`, `snap`) and installed versions. Verifies WSL 2 environment by parsing `/proc/version`.
*   **`k3s-ready`**: Checks for `/etc/rancher/k3s/k3s.yaml` and verifies the k3s server is running.
*   **`apps-ready`**: Queries `kubectl get ns <app-namespace>` and `kubectl get deployment <app-deployment>` to verify essential namespaces and deployments are in a `Ready` state.

Audit checks will output a human-readable table and write detailed JSON reports to `.cache/report-*.json`.

### 3.5. Networking & Firewall

*   Leverage WSL 2's default NAT, which publishes host ports via `netsh interface portproxy`.
*   Existing firewall rules will not be modified. Instead, necessary ports (`80`, `443`, `30080`, `30443` for NodePorts) will be appended non-destructively.
*   Documentation will be provided for users who wish to configure a full WSL 2 bridged network manually.

### 3.6. Secrets & SSH Reuse

*   The IaC will automatically reuse `$HOME/.ssh/id_ed25519`. The process will abort if this key is missing.
*   A helper script (`ssh-to-age`) will be provided to derive an `age` key from the SSH key's private half, facilitating `sops-age` integration.

### 3.7. Nx Integration (Optional Path)

While the core IaC is `Make`-driven, the monorepo's `Makefile` exposes targets like `make nx-*` that delegate to `nx run-many`. This allows for seamless integration if custom microservices or other Nx projects are added later, without adding runtime cost to the infrastructure automation.

### 3.8. Directory Layout

```
/
├─ Makefile                # Main orchestration
├─ versions.mk             # Pinned tool versions
├─ ansible/
│   ├─ inventories/        # Ansible inventories
│   └─ playbooks/          # Ansible playbooks
├─ k8s/
│   ├─ traefik/values.yaml # Helm values for Traefik
│   └─ (other charts)      # Other Kubernetes manifests/charts
├─ scripts/                # Small helper scripts called by Make
├─ .state/                 # Stamp files for Make's incremental execution
└─ .cache/                 # Audit reports and temporary data
```

## 4. Testing Strategy for IaC

Ensuring the reliability and correctness of IaC is paramount. This section outlines the testing strategy, emphasizing pragmatic but highly optimized approaches, including mocking, fakes, and performance considerations.

### 4.1. Unit Testing

*   **Ansible Roles/Playbooks**: Utilize Ansible Lint for static analysis and Molecule for comprehensive unit testing. Molecule will be configured to:
    *   **Mock External Services**: Employ `ansible-playbook --syntax-check` and `ansible-lint` for rapid feedback. For deeper unit tests, use Molecule with a lightweight driver (e.g., `docker`) and strategically mock external API calls (e.g., cloud providers, k3s API) using Python's `unittest.mock` or similar techniques within custom Ansible modules/plugins. This ensures tests are fast and isolated from real infrastructure.
    *   **Fake Dependencies**: For complex roles, create "fake" versions of external services or data sources that return predictable responses, allowing for deterministic testing of logic without actual network calls.
*   **Pulumi Components**: Implement robust unit tests using the Pulumi SDK's testing framework.
    *   **Mock Cloud Provider APIs**: Leverage Pulumi's built-in mocking capabilities to simulate resource creation, updates, and deletions without incurring cloud costs or actual deployments. This involves faking responses from AWS, Azure, or GCP APIs.
    *   **Performance Optimization**: Ensure tests run quickly by minimizing actual resource provisioning and maximizing in-memory state validation.
*   **Shell Scripts**: Develop unit tests for helper scripts using a battle-tested shell testing framework (e.g., `bats` or `shUnit2`).
    *   **Mock System Commands**: Override critical system commands (`kubectl`, `k3s`, `apt`, `snap`, `netsh`) with mock functions that log calls and return predefined outputs. This isolates script logic and prevents unintended system modifications.
    *   **Fake File System Interactions**: Use temporary directories and faked file system structures to simulate various scenarios (e.g., presence/absence of config files, different `/proc/version` outputs) without touching the real filesystem.

### 4.2. Integration Testing

*   **Full `make bootstrap` Flow**: Regularly test the entire `make bootstrap` process in a clean, ephemeral WSL 2 instance or a dedicated virtual machine. This verifies the end-to-end deployment and ensures all components work together.
    *   **Performance Monitoring**: Integrate tools to measure the execution time of `make bootstrap` and its sub-targets. Identify and optimize slow steps, potentially by parallelizing tasks or optimizing shell commands.
    *   **Resource Utilization**: Monitor CPU, memory, and disk I/O during integration tests to identify resource bottlenecks and ensure the IaC is efficient.
*   **Component Interaction**: Verify that different IaC components (e.g., Ansible configuring k3s, Helm deploying applications) interact correctly.
    *   **Contract Testing**: For interactions between different IaC modules (e.g., Ansible preparing a host for Pulumi, Pulumi deploying resources that Ansible then configures), define and test explicit contracts to ensure compatibility.
*   **Environment Consistency**: After deployment, run a comprehensive suite of checks to confirm the environment matches the desired state (e.g., `kubectl get all`, `docker ps`, network connectivity tests, service health checks).
    *   **Automated Verification**: Develop automated scripts that use `kubectl`, `docker`, and other CLI tools to assert the correct state of deployed resources.

### 4.3. Idempotency Testing

*   **Repeated Execution**: After a successful initial `make bootstrap` run, execute it multiple times consecutively.
    *   **Zero-Change Verification**: The primary goal is to verify that subsequent runs result in minimal or zero changes to the infrastructure, indicating true idempotency. Tools like `terraform plan` (for Pulumi, if used) or Ansible's "changed" output will be crucial.
    *   **Performance Baseline**: Measure the execution time of idempotent runs. Optimized IaC should complete idempotent runs very quickly, as most steps should be skipped.
*   **State Verification**: Use the `check-*` and `make status` targets to confirm that the system state is stable and correct after repeated runs. This ensures that the IaC converges to the desired state reliably.

### 4.4. Verification Steps and Optimization

The `check-*` targets and `make status` command are crucial for verifying the state of the homelab. They provide immediate feedback on the deployed infrastructure and applications, allowing for quick identification of discrepancies.
*   **Optimized Feedback Loop**: Ensure these verification steps are as fast as possible. Leverage caching mechanisms (e.g., Nx cache for project status, `Make` stamp files) to avoid redundant checks.
*   **Granular Reporting**: Provide clear, concise output for successful checks and detailed, actionable error messages for failures.
*   **Pre-Commit Hooks**: Integrate static analysis and basic unit tests into pre-commit hooks to catch issues early in the development cycle, reducing the feedback loop.
*   **CI/CD Integration**: Automate all testing phases (unit, integration, idempotency) within a CI/CD pipeline to ensure continuous validation of the IaC. This includes running tests on every pull request and merge to the main branch.

## 5. Alignment with Makefile and Project Implementation

The IaC project is designed to integrate seamlessly with the existing `Makefile` and the broader monorepo structure.

*   **`Makefile` Integration**: The `Makefile` will contain top-level targets like `bootstrap`, `status`, `check-prereqs`, `install-prereqs`, `deploy-apps`, etc., directly mapping to the IaC workflow. Existing `infra-plan`, `infra-apply`, and `ansible-run` targets can be leveraged or extended for more granular IaC operations.
*   **Nx Monorepo Context**: The IaC provides the foundational environment for the Nx monorepo's applications and libraries. While the IaC itself is primarily `Make`-driven, the `Makefile`'s ability to invoke `nx` commands (e.g., `make context-new`, `make service-split`, `make model-new`) ensures that the infrastructure can support the dynamic needs of the AI-Native Monorepo. This allows for a clear separation of concerns: IaC manages the platform, and Nx manages the applications on that platform.

## 6. Future Enhancements / Mind-Blowing Tweaks

*   **GitOps Integration**: Implement a GitOps workflow (e.g., using Flux CD or Argo CD) for Kubernetes workload deployment, where changes to Kubernetes manifests in a Git repository automatically trigger deployments.
*   **Automated IaC Testing in CI/CD**: Integrate IaC testing (unit, integration, idempotency) into a CI/CD pipeline to ensure infrastructure changes are validated before deployment.
*   **Dynamic Ansible Inventory**: Generate Ansible inventories dynamically based on discovered WSL instances or cloud resources.
*   **Observability Integration**: Enhance the homelab with comprehensive monitoring and logging (e.g., Prometheus, Grafana, Loki) for all deployed services and the underlying infrastructure.
*   **Self-Healing Capabilities**: Explore adding self-healing mechanisms for Kubernetes components using operators or custom controllers.
*   **Cross-Platform IaC**: Extend the IaC to support other environments beyond WSL 2, such as bare-metal Linux or public cloud providers, using the same principles.