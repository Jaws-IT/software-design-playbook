# Architecture Enforcement Specification

Status: Authoritative
Scope: All bounded contexts inside modules/
Applies to: CI enforcement, LLM agents, code review

This document defines:

1. Enforced Rules (CI-Failing Violations)
2. Advisory Rules (Non-CI, Review/Agent Enforced)

Only Section 1 rules must fail the build.

---

# SECTION 1 — ENFORCED RULES (CI FAIL)

---

## 1. Bounded Context Layer Structure

Each bounded context MUST contain exactly four peer directories:

- domain/
- application/
- integration/
- infrastructure/

Forbidden layer directory names:

- boundary/
- api/
- adapters/
- core/
- impl/
- services/

Missing required layers is a violation.

---

## 2. No Layer Collapsing

Forbidden:

- Integration code inside domain/
- Application code inside domain/
- Infrastructure code inside domain/
- Integration code inside infrastructure/
- Combining multiple layers into one directory

Layer responsibility must be encoded by directory placement.

---

## 3. Dependency Direction Rule

Allowed direction:

infrastructure → integration → application → domain

Forbidden:

- domain → application
- domain → integration
- domain → infrastructure
- application → infrastructure
- integration → infrastructure

Reverse dependency is a violation.

---

## 4. Domain Purity Rule

Code inside domain/ MUST NOT depend on:

- org.springframework..
- jakarta.persistence..
- javax.persistence..
- org.hibernate..
- web frameworks
- messaging frameworks
- database frameworks
- infrastructure packages

---

## 5. Functional Error Handling Enforcement

Code inside domain/ and application/ MUST NOT:

- Use `throw` for business validation
- Instantiate IllegalArgumentException
- Instantiate IllegalStateException
- Instantiate RuntimeException
- Instantiate custom business exceptions

Business failures MUST be expressed using Either.

---

## 6. Layer Responsibility Placement

Required placement:

- Aggregates → domain/
- Value Objects → domain/
- Domain Events → domain/
- Repository interfaces → domain/

- Command Handlers → application/
- Query Handlers → application/
- Application Services → application/

- Integration Events → integration/
- Integration Commands → integration/
- Translators → integration/

- Controllers → infrastructure/
- Messaging Adapters → infrastructure/
- Persistence Implementations → infrastructure/

Misplacement is a violation.

---

## 7. Cross–Bounded Context Isolation

A bounded context MUST NOT:

- Import another bounded context's domain package
- Depend directly on another bounded context's application layer
- Access another bounded context's repository implementation

Cross-context interaction MUST occur via integration layer only.

---

# SECTION 2 — ADVISORY RULES

These do NOT fail the build.

---

## 8. Package Naming Discipline

Java packages SHOULD NOT:

- Use reverse-DNS vendor naming
- Repeat bounded context name
- Repeat layer name

Packages should express semantic grouping only.

---

## 9. Modeling Quality

Review for:

- Anemic domain models
- Generic modeling
- Getter/setter exposure
- Behavior outside aggregates

---

## 10. Naming Clarity

Commands, events, and types should:

- Express business intent
- Avoid generic naming

---

## 11. Process Modeling Discipline

Processes spanning aggregates or contexts should:

- Be explicit
- Prefer events over synchronous coupling

---

## 12. Design Extremification Principle

Architectural designs must be stress-tested conceptually before implementation.

When evaluating a design, intentionally increase:

- Data volume
- Concurrency
- Distribution
- Latency
- Failure scenarios
- Cross-context interaction complexity

If increasing these factors causes:

- Boundary blurring
- Responsibility leakage
- Domain-to-integration collapse
- Layer violations
- Hidden orchestration
- Performance fixes that require structural compromise

Then the design is structurally weak.

Architecture must survive scale conceptually before it is exposed to scale operationally.

Extremification is not premature optimization.
It is structural validation.

Design as if growth is inevitable.
If the model collapses under thought-experiment scale, it is already flawed.

This principle guides:

- Architectural reviews
- Agent reasoning
- Refactoring decisions
- Performance discussions

Scale reveals structural truth.

---

# SECTION 3 — INFRASTRUCTURE NAMING DOCTRINE

Status: Authoritative
Scope: Integration and Infrastructure layers
Applies to: Class naming and semantic boundaries

---

## 13. Principle

Business semantics must not leak into infrastructure implementation class names.

Infrastructure represents technical mechanisms, not domain meaning.

Semantic naming belongs exclusively to:

- Application layer ports
- Integration layer contracts
- Domain types

Infrastructure implementations must remain mechanism-only.

---

## 14. Layered Naming Split

A strict separation is required:

### A. Semantic Layer (Application / Integration)

Examples:

- AvailabilityRequestPublisherPort
- AvailabilityResultConsumerPort
- BookingCommandGateway
- ExecutionSuggestionEventContract

These names may contain domain/business nouns.

They define intent and meaning.

---

### B. Infrastructure Layer (Mechanism Only)

Examples:

- InMemoryMessagePublisher
- KafkaMessagePublisher
- HttpMessageSender
- BrokerConnectionHealthProbe
- PostgresEventStore
- JdbcRepositoryAdapter

Infrastructure names must:

- Describe technical mechanism
- Describe protocol or technology
- Describe storage or transport
- Avoid business nouns

Forbidden in infrastructure names:

- Availability
- Booking
- Capacity
- Suggestion
- Customer
- Any bounded-context semantic term

---

## 15. Wiring Responsibility

Semantic ports are bound to infrastructure implementations in configuration.

Example mapping:

    AvailabilityRequestPublisherPort
        -> KafkaMessagePublisher

The wiring layer performs the binding.

Infrastructure must not encode business intent in its name.

---

## 16. Rationale

This doctrine enforces:

- Clean onion boundaries
- Replaceable infrastructure
- Business/mechanism separation
- Clear semantic ownership
- Reduced conceptual leakage

If infrastructure contains business nouns,
semantic responsibility has collapsed outward.

---

## 17. Enforcement Strategy

This rule may be validated by:

- Static naming scans
- ArchUnit rules checking package + class name patterns
- CI checks disallowing domain nouns in infrastructure packages

Violation of this doctrine indicates layer responsibility breach.

---

# SECTION 4 — ADVISORY UI ARCHITECTURE PATTERN

Status: Advisory  
Scope: Graphical or interactive frontend systems only  
Does NOT fail CI

This section applies only when building UI systems.  
It does not apply to backend-only bounded contexts.

---

## 18. Canvas-Based Shell Pattern

When building a UI, prefer:

- A single shell
- Multiple canvases (render targets)
- Micro-frontends activated inside canvases
- Navigation defined as activation of a capability, not page navigation

Navigation SHOULD mean:

    "Activate micro-frontend Y in canvas Z"

Not:

    "Navigate to page X"

---

## 19. Ownership Model

Shell owns:

- Canvas layout
- History management
- URL-to-canvas resolution
- Micro-frontend registration
- Activation mapping

Micro-frontend owns:

- Its trigger UI
- Its content UI
- Its internal state
- Its internal transitions
- Its real-time connections

A micro-frontend owns both its trigger and its content.

---

## 20. History Discipline

Browser history is a shell concern.

Widgets must not implement browser back behavior.

Widgets move forward only.

Shell restores canvas state when popstate occurs.

---

## 21. Forward-Only State Modeling

UI state transitions SHOULD:

- Be explicit
- Be modeled as sealed state hierarchies
- Use forward-only transitions
- Use railway-style error handling
- Avoid try/catch as control flow

Cancel and Undo are forward transitions, not backward jumps.

---

## 22. Menu as Composition Point

Menus SHOULD:

- Be composed
- Allow micro-frontends to register contributions
- Not be owned by a single UI component

This aligns with plugin-style composition and inversion of control.

---

## 23. When to Apply Micro-Frontend Architecture

Consider this pattern when:

- Multiple bounded contexts expose UI capabilities
- Independent deployment is required
- UI ownership mirrors domain ownership
- Strong isolation is necessary

Do not apply when:

- The system is small
- One team owns all UI
- Domain boundaries do not justify separation

Architecture must follow domain boundaries.
Never the reverse.

---

End of Architecture Enforcement Specification.