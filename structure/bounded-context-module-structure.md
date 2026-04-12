# PROJECT STRUCTURE AND LAYERING SPECIFICATION

Version: 1.2.0

This document defines the required project structure, layering rules,
package rules, and dependency constraints.

These rules are mandatory and enforceable.

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
- Separate artifacts for domain/application/integration/infrastructure
- Custom source directory hacks
- build-helper plugin to simulate layering
- Layer directories at module root

The four layers must exist under:

src/main/java/

---

# 2. Required Layer Directories

Each module MUST contain exactly four first-level directories under:

src/main/java/

Required:

src/main/java/domain/
src/main/java/application/
src/main/java/integration/
src/main/java/infrastructure/

Forbidden:

- boundary/
- api/
- adapters/
- core/
- impl/
- services/
- Any alternative layer naming

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
- mixing multiple layers into a single folder

Each layer must have a clearly separated directory.

---

# 4. Layer Responsibilities

## domain/

Contains ONLY:

- Core business models
- Aggregates
- Value objects
- Internal domain events
- Domain-specific errors
- Repository interfaces
- Pure business logic

Must NOT contain:

- Command handlers
- Query handlers
- Application services
- Integration events
- Controllers
- Messaging adapters
- Database implementations
- Framework annotations

Domain must remain framework-independent.

---

## application/

Contains:

- Command handlers
- Query handlers
- Application services
- Orchestration logic

May depend on domain.

Must NOT depend on infrastructure.

---

## integration/

Contains:

- External contracts
- Integration events
- Integration commands
- Translation logic between domain and external representations

Must be:

- Technology-agnostic
- Transport-independent

Must NOT contain infrastructure implementation details.

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

Other layers must not depend on infrastructure.

---

# 4A. Domain Event Placement

Internal domain events must stay inside the bounded context
and be organized with the aggregate that emits them.

Preferred structure:

- `domain/<aggregate>/Aggregate.kt`
- `domain/<aggregate>/<AggregateEvent>.kt`

Allowed variation:

- `domain/<aggregate>/events/<AggregateEvent>.kt`

Forbidden:

- `domain/events/` as a shared folder for all aggregates
- generic cross-aggregate event buckets
- domain event classes reused by multiple aggregates
- domain event classes imported across bounded contexts

Rationale:

- central event folders create semantic coupling
- shared event reuse leaks one model into another
- aggregate-local placement preserves authority boundaries

Domain events express local business facts only.
They are not shared truths for the whole system.

If information must cross a bounded-context boundary,
translate the domain event into a separate integration representation
under `src/main/java/integration/`.

---

# 4B. Repository Placement

Repository interfaces must stay inside the domain layer
and be organized with the aggregate they manage.

Preferred structure:

- `domain/<aggregate>/Aggregate.kt`
- `domain/<aggregate>/<Aggregate>Repository.kt`

Allowed variation:

- `domain/<aggregate>/repositories/<Aggregate>Repository.kt`

Infrastructure implementations belong under infrastructure,
for example:

- `infrastructure/persistence/<Aggregate>RepositoryImpl.kt`

Forbidden:

- `domain/repositories/` as a shared bucket for all aggregates
- generic repository abstractions reused across unrelated aggregates
- repository contracts shared across bounded contexts
- repository interfaces defined in application or infrastructure

Rationale:

- colocated repositories reinforce aggregate authority
- generic repository reuse weakens ubiquitous language
- infrastructure implementations are details, not owners of retrieval semantics

Repository contracts must express intent in business language,
not generic data-access mechanics.

---

# 5. Dependency Direction Rules (Production Code)

Production code under:

src/main/java/

Must follow this direction:

infrastructure → integration → application → domain

Forbidden:

- domain importing application
- domain importing integration
- domain importing infrastructure
- application importing infrastructure
- integration importing infrastructure
- reverse dependencies between layers

---

# 6. Test Code Policy

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

# 7. Java Package Naming Rules

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

# 8. Package Structure Rules

Packages must begin with the architectural layer.

Correct examples:

domain
application
integration
infrastructure

Sub-packages must express meaningful grouping.

Allowed examples:

domain/model
domain/policy
application/commands
application/queries
integration/contracts
infrastructure/persistence

Forbidden:

- Repeating module name in package
- Repeating layer name redundantly
- Generic containers such as common, shared, utils without clear purpose

---

# 9. Structural Violations

The following constitute violations:

- Missing required layer directory
- Additional architectural layer directory
- Alternative layer naming
- Layer collapsing
- Reverse dependency direction in production code
- Cross-module domain imports
- Reverse-DNS package naming
- Redundant package naming
- Import direction violations

Violations must fail validation.
