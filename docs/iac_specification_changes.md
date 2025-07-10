# Infrastructure as Code (IaC) Specification Updates

This document details the updates made to `docs/.temp/kernel.md`, transforming it into a comprehensive specification for the homelab Infrastructure as Code (IaC) project within the AI-Native Monorepo Starter Kit. These changes aim to align the document with the project's existing `Makefile` and overall implementation, providing a clear roadmap for building a reproducible and idempotent homelab environment.

## Purpose of the Update

The primary goal of updating `docs/.temp/kernel.md` was to formalize the requirements and design for the homelab IaC. Previously, the document focused on general Nx and DDD Hexagonal architecture principles. The revised version now serves as a detailed blueprint for setting up a personal homelab, emphasizing automation, reproducibility, and seamless integration with the existing monorepo structure.

## Key Aspects of the New IaC Specification

The updated `kernel.md` now covers the following critical areas:

### 1. Environment Details

*   **Host OS**: Specifies Windows 11 Pro with a static IP.
*   **Guest OS**: Specifies Ubuntu 22.04 WSL 2 with a static IP.
*   **SSH Key Sharing**: Highlights the shared `ed25519` SSH key for consistent authentication across both environments.

### 2. Key Capabilities

Outlines the core functionalities the IaC automation must provide:

*   **Auditing**: Intelligent assessment of the WSL instance.
*   **Installation & Configuration**: Automated setup of Ansible, Pulumi, k3s (without Traefik), and a MECE set of Kubernetes workloads (Traefik, Cert-Manager, Secrets-Store-CSI, Authelia, Bitwarden, Apache Guacamole, Home-Page Dashboard).
*   **Network Preservation**: Non-destructive extension of existing static IPs and firewall rules.
*   **SSH Key Reuse**: Seamless integration of the shared SSH key for all operations.
*   **Idempotency**: Ensuring re-runnability without side-effects.
*   **Maintainability**: Emphasis on modularity, commenting, and dependency pinning.

### 3. IaC Design and Approach

This section details the architectural decisions and guiding principles:

*   **Guiding Principles**: Focus on idempotency, audit-before-act, `Make` as the orchestrator, WSL-friendliness, minimal footprint, explicit versions, and a batteries-included developer experience.
*   **Technology Stack**: A clear table outlining the chosen tools (GNU Make, Ansible, k3sup/k3s install.sh, Pulumi, Helm+kubectl, sops-age) and their rationale.
*   **High-Level Workflow (`make bootstrap`)**: A visual representation of the `make bootstrap` process, showing dependencies and the use of stamp files for incremental execution.
*   **Auditing Strategy**: Specifics on how `check-prereqs`, `k3s-ready`, and `apps-ready` targets will audit the environment and generate reports.
*   **Networking & Firewall**: Approach to managing network configurations within WSL 2.
*   **Secrets & SSH Reuse**: How SSH keys are reused and `age` keys are derived.
*   **Nx Integration (Optional Path)**: Explanation of how `Make` targets can delegate to `nx` commands, allowing for future integration with Nx-managed microservices.
*   **Directory Layout**: A proposed directory structure for the IaC components.

## 4. Testing Strategy for IaC

A new, dedicated section has been added to emphasize the importance of testing IaC:

*   **Unit Testing**: Recommendations for testing Ansible roles, Pulumi components, and shell scripts using appropriate frameworks (Ansible Lint, Molecule, Pulumi SDK testing, `bats`/`shUnit2`).
*   **Integration Testing**: Strategies for testing the full `make bootstrap` flow, component interactions, and environment consistency.
*   **Idempotency Testing**: Procedures for verifying idempotency through repeated execution and state verification.
*   **Verification Steps**: Reinforces the use of `check-*` targets and `make status` for immediate feedback.

## 5. Alignment with Makefile and Project Implementation

This section explicitly connects the IaC specification to the existing monorepo:

*   **`Makefile` Integration**: Explains how the `Makefile` will house top-level IaC targets and leverage existing `infra-plan`, `infra-apply`, and `ansible-run` commands.
*   **Nx Monorepo Context**: Clarifies the separation of concerns, where IaC manages the platform, and Nx manages applications on that platform, with the `Makefile` bridging the two.

## 6. Future Enhancements / Mind-Blowing Tweaks

This forward-looking section outlines potential advanced features and improvements, such as GitOps integration, automated IaC testing in CI/CD, dynamic Ansible inventory, enhanced observability, self-healing capabilities, and cross-platform IaC.

## Conclusion

The updated `docs/.temp/kernel.md` now serves as a robust and detailed specification for the homelab IaC project. It provides a clear, actionable plan for implementation, ensuring that the homelab environment is built with the same principles of automation, reproducibility, and maintainability that define the AI-Native Monorepo Starter Kit.
