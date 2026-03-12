# Code Rules

Version: 2.3  
Last Updated: February 28, 2026  
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

- get*() / set*()
- verify()
- process()
- handle()
- doSomething()
- util()

Accessor-style methods expose internal state for external decisions.
Methods should reveal intent, not implementation access patterns.

Allowed examples:

- attachClaim()
- confirmBooking()
- reserveCapacity()
- approveApplication()
- completeInquiry()
- recordAvailability()

Intent must be explicit.

---

# 7. Command Query Separation

Functions SHOULD either:

- perform a state-changing action
- answer a question

They SHOULD NOT do both in one operation unless the returned value is the explicit result of the command itself.

Forbidden patterns:

- query methods with hidden mutation
- setter-style commands that also return unrelated derived data
- methods whose naming suggests a read but performs a write

Allowed patterns:

- `loadCustomer(id): Either<Error, Customer>`
- `confirmBooking(command): Either<BookingError, BookingConfirmed>`
- `withUpdatedAddress(address): Customer`

Avoid APIs that force readers to guess whether an operation is interrogating or mutating state.

---

# 8. Function Arity Discipline

Prefer:

- zero-argument queries when context is already held
- one-argument operations
- two-argument operations only when the pair is natural

Three arguments SHOULD trigger a design review.

Four or more arguments SHOULD be replaced by:

- a command object
- a value object
- a builder
- a more intention-revealing intermediate type

Flag arguments are forbidden.

Boolean parameters that switch behavior usually indicate that one function is doing multiple things.

---

# 9. WET Before Premature DRY

Do not abstract merely because code looks similar once.

Duplication becomes a real abstraction candidate only when:

- the duplicated behavior is semantically the same
- the duplication is stable
- the abstraction reduces complexity instead of moving it

Prefer a small amount of obvious duplication over a premature shared abstraction that leaks accidental complexity across contexts or layers.

This rule protects:

- semantic clarity
- bounded context independence
- easier refactoring

Abstraction must earn its keep.

---

# 10. Single Log Point

The same failure SHOULD be logged once at the boundary that owns the final handling decision.

Forbidden patterns:

- log and rethrow
- logging the same recoverable failure at every layer
- logging expected business-rule failures deep inside the domain

Preferred behavior:

- domain returns explicit errors
- application translates or propagates explicit errors
- infrastructure or outer entrypoints log terminal failures with context

Logs should add operational value, not duplicate noise.

---

# 11. No Framework Annotations in Domain

Domain MUST NOT contain:

- @Entity
- @Component
- @Service
- @Repository
- @Controller
- Any framework annotation

Annotations belong in infrastructure.

---

# 12. No Hidden Coupling

Domain code MUST NOT:

- Call external services
- Inject infrastructure components
- Access other bounded contexts directly

Cross-context interaction occurs only through integration layer.

---

# 13. No Layer Leakage

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

# 14. Deterministic Return Types

If a method can fail due to business rules, it MUST return Either.

Void methods that may fail are forbidden.

Implicit failure is forbidden.

---

# 15. Streaming Discipline for Potentially Large Sequences

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

# 16. No Interrogative Invariant Exposure (CRITICAL)

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

# 17. Event Fact Typing and Naming

Business events MUST be named as facts and typed by intent:

- Commitment fact: a promise or intent accepted (for example `SlotReserved`)
- Outcome fact: a business result became true (for example `ReservationConfirmed`)

Event names MUST:

- Be past-tense business facts
- Use ubiquitous language of the owning bounded context
- Make commitment vs outcome semantics explicit in wording

Forbidden patterns:

- Generic lifecycle names that hide meaning (`Updated`, `Processed`, `Handled`)
- Technical names instead of business facts
- Consumers inferring outcome facts from commitment facts without an explicit outcome event

Cross-context consumers must react to explicit published facts, not inferred state.

---

End of Code Rules.
