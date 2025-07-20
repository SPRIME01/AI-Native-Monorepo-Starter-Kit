# Requirements Document

## Introduction

Complete the migration from Make (Makefile) to Just (justfile) build system for the AI-Native Monorepo Starter Kit. The project has already begun this migration with most commands converted, but several critical issues remain that prevent full adoption of Just as the primary build system.

## Requirements

### Requirement 1

**User Story:** As a developer, I want all build commands to work consistently through Just, so that I can use a single, modern build system without encountering missing dependencies or broken commands.

#### Acceptance Criteria

1. WHEN I run `just setup` THEN the system SHALL complete initial setup without referencing missing setup_helper.sh
2. WHEN I run any just command THEN the system SHALL execute successfully without falling back to Make
3. IF setup_helper.sh functionality is needed THEN the system SHALL provide equivalent functionality through Python scripts or inline shell commands
4. WHEN I run `just help` THEN the system SHALL display all available commands with proper descriptions

### Requirement 2

**User Story:** As a developer, I want the justfile to contain all necessary helper functions, so that complex operations like service creation and management work correctly.

#### Acceptance Criteria

1. WHEN I run `just service-split CTX=test` THEN the system SHALL create all necessary service files and configurations
2. WHEN I run internal helper commands THEN the system SHALL execute the complete logic without truncation
3. IF the justfile references helper functions THEN those functions SHALL be fully implemented and functional
4. WHEN service management commands execute THEN they SHALL create proper Docker, Kubernetes, and application files

### Requirement 3

**User Story:** As a developer reading documentation, I want all examples to use Just commands, so that I can follow current best practices without confusion about which build system to use.

#### Acceptance Criteria

1. WHEN I read any .md documentation file THEN examples SHALL use `just` commands instead of `make` commands
2. WHEN documentation shows command examples THEN they SHALL be accurate and executable with the current justfile
3. IF documentation references build system features THEN it SHALL reference Just capabilities and syntax
4. WHEN new developers follow setup instructions THEN they SHALL use Just exclusively

### Requirement 4

**User Story:** As a project maintainer, I want the legacy Makefile removed or clearly marked as deprecated, so that there's no confusion about which build system is the current standard.

#### Acceptance Criteria

1. WHEN the migration is complete THEN the Makefile SHALL be removed or moved to a legacy directory
2. IF the Makefile is kept for reference THEN it SHALL be clearly marked as deprecated with migration instructions
3. WHEN developers look for build instructions THEN they SHALL find clear guidance to use Just
4. WHEN CI/CD systems run THEN they SHALL use Just commands exclusively

### Requirement 5

**User Story:** As a developer, I want cross-platform compatibility maintained during migration, so that the build system works consistently on Windows, macOS, and Linux.

#### Acceptance Criteria

1. WHEN I run just commands on Windows THEN they SHALL execute properly with Windows-compatible shell commands
2. WHEN I run just commands on Unix-like systems THEN they SHALL execute properly with bash-compatible commands
3. IF platform-specific logic is needed THEN the justfile SHALL detect the platform and use appropriate commands
4. WHEN cross-platform scripts are needed THEN they SHALL be implemented in Python for maximum compatibility