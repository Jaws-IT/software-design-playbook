# Architectural Integrity Constraints

This document defines non-negotiable architectural constraints that protect domain purity, contract stability, and infrastructural replaceability.

These rules are structural, not stylistic.

---

# 1. Layer Dependency Rule (Onion Principle)

Dependencies must always point inward:

infrastructure → integration → application → domain

Never the reverse.

Violations:
- Domain importing infrastructure classes
- Integration importing infrastructure frameworks
- Application importing transport adapters
- Cross-layer circular dependencies

---

# 2. Domain Purity Rule

The domain layer must remain pure.

Domain must not:
- Import REST libraries
- Import messaging libraries
- Import persistence frameworks
- Contain JSON annotations
- Contain serialization annotations
- Contain versioning logic
- Contain integration event classes

Domain contains only business meaning.

If domain knows about transport or versioning, authority has leaked.

---

# 3. Integration Contract Integrity Rule

Integration represents published language.

Integration must:
- Be transport-agnostic
- Be framework-agnostic
- Be explicitly versioned
- Be stable over time

Integration must not:
- Contain Kafka annotations
- Contain REST annotations
- Contain ORM mappings
- Contain database logic

If integration becomes infrastructure-shaped, contract integrity is lost.

---

# 4. Infrastructure Isolation Rule

Infrastructure handles technical delivery only.

Infrastructure may depend on:
- integration
- application
- domain

But nothing may depend on infrastructure.

Infrastructure must not:
- Contain business rules
- Contain domain decisions
- Contain domain invariants

Infrastructure implements delivery, not meaning.

---

# 5. Translation Rule

All cross-layer semantic transitions must be explicit.

Inbound:
Infrastructure → Integration → Application → Domain

Outbound:
Domain → Application → Integration → Infrastructure

No direct jumps.

Examples of violations:
- Infrastructure directly invoking domain aggregates
- Domain emitting integration events directly
- Application publishing Kafka messages directly

Translation boundaries must be visible in code.

---

# 6. Cross-Bounded Context Collaboration Rule

Bounded contexts must not:
- Call each other's domain layer directly
- Import each other's aggregates
- Share internal models

Collaboration must occur via:
- Integration events
- Published language
- Explicit contracts

Synchronous in-memory cross-BC calls are strongly discouraged.
If used, they must be explicitly justified.

---

# 7. Exception Policy

For production systems, these constraints are mandatory.

For prototypes or disposable tools:
Simplification is allowed only after explicitly answering:

“Why is architectural separation unnecessary here?”

Convenience is not justification.

Intentional deviation is allowed.
Accidental collapse is not.

---

# 8. Architectural Rationale

Architectural integrity protects:

- Domain authority
- Contract stability
- Replaceable infrastructure
- Coupling control
- Failure-chain risk reduction

Collapsing layers creates:

- Authority leakage
- Semantic confusion
- Versioning instability
- Hidden coupling

Structure is not cosmetic.
Folder placement encodes responsibility.
