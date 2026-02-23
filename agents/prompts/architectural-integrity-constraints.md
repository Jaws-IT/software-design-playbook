# Architectural Integrity Constraints

This document defines non-negotiable architectural rules.

These constraints override convenience and local optimizations.

---

## 1. Onion Architecture Rule

Dependency direction must always point inward:

infrastructure → integration → application → domain

Inner layers must never depend on outer layers.

The domain layer must remain framework-independent.

---

## 2. Domain Purity Rule

The domain layer may contain ONLY:

- Aggregates
- Value Objects
- Domain Events
- Domain Errors
- Repository interfaces (ports)
- Pure domain services

The domain layer must NOT contain:

- Integration events
- REST DTOs
- Messaging DTOs
- Controllers
- Database implementations
- Framework annotations
- Serialization logic

---

## 3. Integration Ownership Rule

Domain emits Domain Events.

Integration layer translates Domain Events into Integration Events.

Infrastructure publishes Integration Events.

Integration events must be:

- Technology-agnostic
- Transport-independent
- Explicitly versioned
- Stable contracts

Integration contracts belong to the bounded context,
but outside the domain layer.

---

## 4. Cross–Bounded Context Rule

Bounded contexts MUST NOT communicate via:

- Direct in-memory calls
- Direct service injection
- Repository access across contexts
- Shared domain objects

Even inside a modular monolith.

All cross-BC communication MUST occur through:

- Integration Commands
- Integration Events
- Explicit translation in the integration layer

There must always be a semantic boundary.

No bounded context may depend directly on another bounded context’s domain model.

---

## 5. No Structural Collapsing

The following collapses are forbidden:

- Placing integration inside domain
- Placing infrastructure inside domain
- Merging application and infrastructure layers
- Bypassing integration when communicating across BCs

Architectural separation must remain explicit.

---

## 6. Authority Protection Rule

If you share internal domain data structures across bounded contexts,
you are handing over semantic authority.

This is forbidden.

Only integration contracts may cross boundaries.

---

## 7. Validation Priority

When architectural constraints conflict with convenience,
the constraints win.

Architecture governs code, not the other way around.
