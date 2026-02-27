# Code Rules

Version: 2.2  
Last Updated: February 27, 2026  
Status: Authoritative  
Scope: All bounded contexts  
Applies to: Domain, Application, Integration, Infrastructure

These rules define coding-level constraints that preserve architectural integrity.

---

# 1. Domain Purity

Code inside domain/ MUST:

- Contain business logic only.
- Be framework-independent.
- Be free of infrastructure concerns.

Code inside domain/ MUST NOT depend on:

- org.springframework..
- jakarta.persistence..
- javax.persistence..
- org.hibernate..
- web frameworks
- messaging frameworks
- database frameworks
- infrastructure packages

Domain must compile without any framework present.

---

# 2. Functional Error Handling Doctrine

Business rule violations MUST NOT be expressed using exceptions.

The following are strictly forbidden inside domain/ and application/:

- throw IllegalArgumentException
- throw IllegalStateException
- throw RuntimeException
- throw custom business exceptions
- any throw statement for validation or rule enforcement

Business rule failures MUST be represented as Either.

All validation, invariant violations, and rule conflicts must return Either.

Void methods that may fail are forbidden.

Implicit failure is forbidden.

---

# 3. Exception Boundary Rule

Exceptions are allowed ONLY:

- In infrastructure
- For technical failures
- For framework integration boundaries
- For external IO failures

Infrastructure may translate technical exceptions into:

- DomainError
- IntegrationError
- Or Either

Domain and application layers must never propagate raw framework exceptions.

---

# 4. No Anemic Domain Model

Aggregates MUST contain behavior.

The following is forbidden:

- Pure data containers
- Getter/setter-only domain objects
- Business logic implemented outside aggregates

Behavior must live where the invariants live.

---

# 5. No Procedural Domain Orchestration

Domain services MUST NOT:

- Orchestrate application flows
- Coordinate cross-aggregate processes
- Act as transaction scripts

Application layer coordinates.
Domain layer enforces invariants.

---

# 6. Explicit Intent

Public methods MUST express business intent.

Forbidden naming patterns:

- verify()
- process()
- handle()
- doSomething()
- util()

Allowed examples:

- attachClaim()
- confirmBooking()
- reserveCapacity()
- approveApplication()
- completeInquiry()
- recordAvailability()

Intent must be explicit.

---

# 7. No Framework Annotations in Domain

Domain MUST NOT contain:

- @Entity
- @Component
- @Service
- @Repository
- @Controller
- Any framework annotation

Annotations belong in infrastructure.

---

# 8. No Hidden Coupling

Domain code MUST NOT:

- Call external services
- Inject infrastructure components
- Access other bounded contexts directly

Cross-context interaction occurs only through integration layer.

---

# 9. No Layer Leakage

Application MUST NOT:

- Access database implementations directly
- Use framework controllers
- Access infrastructure adapters directly

Integration MUST NOT:

- Contain business logic
- Modify domain invariants

Infrastructure MUST NOT:

- Contain business rules
- Modify domain invariants

---

# 10. Deterministic Return Types

If a method can fail due to business rules, it MUST return Either.

Void methods that may fail are forbidden.

Implicit failure is forbidden.

---

# 11. Streaming Discipline for Potentially Large Sequences

When a method may produce a potentially large or conceptually unbounded sequence,
it SHOULD favor streaming over eager materialization.

Avoid inside domain:

- map → collect → re-iterate patterns
- Double traversal of large collections
- Premature intermediate list construction

Prefer:

- Single-pass transformations
- Stream API usage for transformation chains
- Compositional flow

Streaming is not mandatory for clearly bounded small collections.

Architecture must survive growth.

---

# 12. No Interrogative Invariant Exposure (CRITICAL)

Aggregates MUST NOT expose public boolean or primitive state queries
that derive invariant logic from internal collections or internal state.

Forbidden patterns:

- public boolean isComplete()
- public boolean hasX()
- public int remainingCount()
- public boolean isValid()
- Any public method exposing derived state based on internal collections.

Rationale:

Interrogative invariant exposure encourages procedural orchestration
outside the aggregate and leaks internal decision logic.

Completion, validation, and state transitions MUST be expressed
as intention-driven commands.

Correct pattern:

Instead of:

    public boolean isComplete()

Use:

    public Either<DomainError, CompletionResult> complete()

The aggregate must own the transition,
not expose derived status for external branching.

Violation Severity: CRITICAL

---

End of Code Rules.