# Functional Domain Constraints

Version: 1.0.0

These constraints are mandatory when implementing or modifying domain code.

## Immutability

- Aggregates must be immutable.
- State changes return new instances.
- No mutable public fields.
- No setter methods.

---

## No Getters for Business Logic

- Do not expose internal state for external decision-making.
- No getter-driven domain logic.
- No read-then-decide patterns outside aggregates.
- If a caller needs a decision, expose an intention method instead.

---

## Intention-Based APIs

- Public methods must express intention.
- Avoid generic method names like get, set, update, process, handle.
- Methods must represent meaningful domain behavior.

---

## No Anemic Domain Models

- Aggregates must own invariants.
- Business rules must live inside aggregates.
- Do not move domain decisions to services unnecessarily.

---

## Error Handling

- Do not throw exceptions for domain flow.
- Use Either / Result / Option types.
- Domain failures must be explicit and typed.
- No try/catch in domain for control flow.

---

## Event-Derived State

- State transitions must emit domain events.
- Do not mutate state silently.
- Domain events represent facts that occurred.
- Aggregate decision logic should be understood as:
  - aggregate + command -> domain events
  - aggregate + domain events -> new aggregate state
- State is derived from facts; it is not the source of truth.
- Aggregates must not publish events directly.
- Aggregates must not depend on repositories, buses, clocks, or external services to decide facts.
- Application layer loads state, invokes aggregate decision logic, applies emitted events, persists resulting state, and publishes events.

---

## No Framework Dependencies

- Domain must not import framework libraries.
- Domain must not depend on HTTP, persistence, broker, or infrastructure types.
- Domain may depend only on pure language constructs and internal domain types.

---

## No Cross-Module Coupling

- Do not import domain types from other bounded contexts.
- Do not access repositories across modules.
- Do not perform synchronous cross-module calls.

---

## Enforcement Rule

If implementation requires exposing state, introducing mutation, importing framework code, or delegating invariants outside aggregates, stop and refactor.
