# Bounded Context Structure Constraints

These constraints are mandatory during implementation.

---

## Module Boundary

- One bounded context per module.
- No cross-module domain imports.
- Cross-context communication must occur via integration events only.

---

## Domain Layer

- Domain contains aggregates, value objects, domain events, domain errors, and repository interfaces only.
- Domain must not contain integration events.
- Domain must not contain versioning logic.
- Domain must not import framework or infrastructure libraries.
- Domain must not depend on boundary or infrastructure.

Domain events represent internal state changes only.
Domain events are not published contracts.

---

## Integration Layer (Published Language)

- Integration events live in `integration/`.
- Integration events are external contracts of the bounded context.
- Integration events may be versioned.
- Integration events must be transport-agnostic.
- No framework annotations.
- No broker metadata.
- No transport-specific fields.
- Integration must not depend on infrastructure.

---

## Boundary Layer

- Boundary translates Domain Events into Integration Events.
- Boundary translates external Integration Events into Commands.
- Boundary may depend on domain and integration.
- Boundary must not contain transport framework implementations.

---

## Infrastructure Layer

- Infrastructure contains transport adapters only.
- Infrastructure may depend on boundary and integration.
- Infrastructure must not depend on domain directly.
- Infrastructure must not contain business logic.

---

## Event Translation Rules

- Domain emits Domain Events.
- Boundary maps Domain Events → Integration Events.
- Infrastructure publishes Integration Events.
- External Integration Events must be translated into Commands before entering domain.
- No external event may become a domain event directly.

---

## Dependency Direction

Allowed:
- application → domain
- integration → domain (mapping only)
- boundary → domain
- boundary → integration
- infrastructure → boundary
- infrastructure → integration

Forbidden:
- domain → integration
- domain → boundary
- domain → infrastructure
- integration → infrastructure
- cross-module domain imports

---

## Coupling Control

- No synchronous cross-module calls.
- No direct repository access across modules.
- No REST-style internal calls between bounded contexts.
- Treat coupling as architectural risk.

---

## Enforcement Rule

If implementation introduces:
- Framework imports in domain
- Transport concerns in integration
- Contract logic in infrastructure
- Cross-module domain access

Stop and refactor before proceeding.
