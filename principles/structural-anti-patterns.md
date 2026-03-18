# Structural Anti Patterns

Version: 1.0.0

This document defines structural and modeling anti-patterns that violate architectural integrity.

These are not stylistic disagreements.
They are authority and coupling violations.

---

# Structural Anti-Patterns

## 1. Illegal Layer Dependency

Anti-pattern:
- domain imports application
- domain imports integration
- domain imports infrastructure
- integration imports infrastructure
- application imports infrastructure

Why this is harmful:
Layer inversion breaks onion architecture and creates hidden coupling.

Rule:
Dependencies must always point inward:

infrastructure → integration → application → domain

Never the reverse.

Severity: CRITICAL

---

## 2. Framework Leakage into Domain

Anti-pattern:
- REST annotations inside domain
- Messaging annotations inside domain
- Serialization annotations inside domain
- ORM mappings inside domain
- Transaction annotations inside domain
- Framework configuration classes inside domain

Why this is harmful:
Domain authority is compromised.
Business logic becomes tied to technical frameworks.

Rule:
Domain must remain framework-agnostic and transport-agnostic.

Severity: CRITICAL

---

## 3. Integration Contract Pollution

Anti-pattern:
- Kafka annotations inside integration
- REST annotations inside integration
- JSON framework bindings inside integration
- Database logic inside integration
- Messaging headers embedded in integration contracts

Why this is harmful:
Integration contracts become infrastructure-shaped.
Versioning and semantic stability are compromised.

Rule:
Integration represents published language.
It must remain technology-agnostic.

Severity: HIGH

---

## 4. Infrastructure Containing Business Logic

Anti-pattern:
- Business rule validation in controllers
- Domain invariants enforced in adapters
- Aggregate state changes in infrastructure
- Decision branching based on business rules outside domain

Why this is harmful:
Meaning leaks outward.
Coupling increases.
Testability decreases.

Rule:
Infrastructure handles delivery only.
It must not define business meaning.

Severity: CRITICAL

---

## 5. Direct Cross–Bounded Context Invocation

Anti-pattern:
- One BC imports another BC's domain package
- One BC instantiates another BC aggregate
- One BC directly calls another BC application service

Why this is harmful:
Boundaries collapse.
Autonomy disappears.
Failure chains increase.

Rule:
Bounded contexts collaborate via integration contracts only.

Severity: CRITICAL

---

## 6. Domain Emitting Integration Events Directly

Anti-pattern:
- Domain referencing integration event classes
- Domain publishing integration events
- Domain containing versioned contract objects

Why this is harmful:
Domain becomes aware of external contract concerns.
Versioning responsibility leaks inward.

Rule:
Domain emits domain events only.
Translation to integration events happens outside the domain layer.

Severity: HIGH

---

## 7. Collapsed Contract and Infrastructure Layer

Anti-pattern:
- No integration layer present
- Mixing semantic contracts and transport mechanisms in a single layer
- Collapsing integration and infrastructure into one concept

Why this is harmful:
Contract stability and transport independence become ambiguous.
Cognitive confusion increases.

Rule:
Maintain explicit separation between:
- domain (internal truth)
- integration (published language)
- infrastructure (technical delivery)

Severity: WARNING (unless production system)

---

## 8. Anemic or Generic Modeling

Anti-pattern:
- Public getters exposing aggregate state
- Setters mutating state without intention
- Domain logic located outside aggregate/service
- Generic “Manager” or “Service” classes holding domain rules

Why this is harmful:
Hidden coupling.
Loss of invariants.
Loss of domain authority.

Rule:
Use intention-based methods.
Encapsulate invariants inside aggregates or domain services.

Severity: HIGH

---

## 9. Hidden Synchronous Cross-BC Coupling

Anti-pattern:
- In-memory service calls across bounded contexts
- Shared interfaces implemented across BC boundaries
- Implicit consistency assumptions across BCs

Why this is harmful:
Creates illusion of strong consistency.
Increases risk of failure chaining.
Reduces autonomy.

Rule:
Prefer integration-based collaboration.
If synchronous calls are used, justification must be explicit.

Severity: WARNING or HIGH depending on architecture policy

---

# Core Principle

Coupling is not inherently bad.

Uncontrolled, hidden, or authority-leaking coupling is.

Structural clarity is risk management.
