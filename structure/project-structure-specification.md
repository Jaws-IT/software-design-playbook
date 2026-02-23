# PROJECT STRUCTURE AND LAYERING SPECIFICATION

This document defines mandatory structural, layering, dependency,
and package rules for all modules.

These rules are deterministic and enforceable.

No interpretation or advisory language applies.

---

# 1. Module Structure

Each module MUST be implemented as a single Maven project.

Required layout:

modules/<module-name>/
pom.xml
src/
main/
java/
domain/
application/
integration/
infrastructure/
test/
java/

Forbidden:

- Multiple Maven sub-modules per layer
- Separate artifacts per layer
- build-helper or custom source directory manipulation
- Layer directories at module root
- Missing required layer directory

The four layer directories must exist under:

src/main/java/

---

# 2. Required Layer Directories

Under:

src/main/java/

The following first-level directories MUST exist:

- domain/
- application/
- integration/
- infrastructure/

Forbidden:

- boundary/
- api/
- adapters/
- core/
- impl/
- services/
- Alternative architectural layer naming

Layer directories must be first-level under src/main/java.

---

# 3. No Layer Collapsing

Layer responsibilities must remain isolated.

Forbidden:

- integration code inside domain
- application code inside domain
- infrastructure code inside application
- integration merged into infrastructure
- commands or queries inside domain
- controllers inside domain
- Mixing multiple architectural layers in the same directory

Each architectural layer must remain structurally distinct.

---

# 4. Layer Responsibilities

## domain/

Contains ONLY:

- Core business models
- Aggregates
- Value objects
- Internal domain events
- Domain-specific errors
- Repository interfaces (persistence ports)
- Pure business logic

Must NOT contain:

- Command handlers
- Query handlers
- Application services
- Integration contracts
- Controllers
- Messaging adapters
- Persistence implementations
- Framework annotations

Domain must remain framework-independent.

---

## application/

Contains:

- Command handlers
- Query handlers
- Application services
- Use-case orchestration logic
- Outbound behavioral abstractions (ports)

May depend on:

- domain

Must NOT depend on:

- infrastructure

Application must not import infrastructure classes.

---

## integration/

Contains:

- External contract definitions
- Integration events
- Integration commands
- Mapping objects for external communication

Integration defines data contracts only.

Integration must not contain orchestration logic.
Integration must not contain infrastructure implementations.

---

## infrastructure/

Contains:

- REST controllers
- Messaging adapters
- Persistence implementations
- Framework configuration
- External system adapters

May depend on:

- domain
- application
- integration

No inward layer may depend on infrastructure.

---

# 5. Dependency Direction (Production Code)

Production code under:

src/main/java/

Must follow this direction:

infrastructure → application → domain  
infrastructure → integration

Allowed dependencies:

- application → domain
- infrastructure → application
- infrastructure → domain
- infrastructure → integration

Forbidden:

- domain → application
- domain → integration
- domain → infrastructure
- application → infrastructure
- integration → infrastructure
- integration → application
- Reverse or circular dependencies

---

# 6. Outbound Abstraction Ownership Rule

For any behavior that crosses a layer boundary outward:

- The inward layer MUST define the abstraction (interface).
- The outward layer MUST implement the abstraction.
- The abstraction MUST NOT reside in the outward layer.

Examples:

- Repository interfaces belong in domain.
- Event publishing interfaces belong in application.
- External adapter interfaces must be defined inward.

Forbidden:

- Placing an interface in infrastructure that is consumed by application.
- Placing abstractions in a more outward layer than their consumer.

Violation category:

- OUTBOUND_ABSTRACTION_MISPLACED

---

# 7. Test Code Policy

Test code under:

src/test/java/

May depend outward for wiring and integration testing.

Allowed in tests:

- application tests importing infrastructure
- integration tests importing application
- infrastructure tests importing domain

Forbidden in tests:

- Cross-module domain imports
- Sharing domain models across modules
- Violating module boundaries

Module isolation rules apply to both production and test code.

---

# 8. Java Package Naming Rules

Reverse-DNS naming is forbidden for internal modules.

Forbidden:

- package com.*
- package org.*
- package net.*
- package io.*
- Vendor/company-prefixed namespaces

Artifact identity is defined by Maven coordinates,
not by Java package names.

---

# 9. Package Structure Rules

Packages must begin with the architectural layer.

Valid root packages:

- domain
- application
- integration
- infrastructure

Sub-packages must represent meaningful grouping.

Allowed examples:

- domain/model
- domain/policy
- application/commands
- application/queries
- integration/contracts
- infrastructure/persistence

Forbidden:

- Repeating module name in package
- Repeating layer name redundantly
- Generic containers such as common, shared, utils without clear purpose

---

# 10. Structural Violations

The following constitute violations:

- STRUCTURE_MISSING_LAYER
- STRUCTURE_EXTRA_LAYER
- STRUCTURE_LAYER_COLLAPSE
- INVALID_LAYER_NAME
- INVALID_PACKAGE_NAMING
- IMPORT_DIRECTION_VIOLATION
- OUTBOUND_ABSTRACTION_MISPLACED
- CROSS_MODULE_DOMAIN_IMPORT
- TEST_POLICY_VIOLATION

Violations must fail validation.
