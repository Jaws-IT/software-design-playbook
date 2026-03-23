# Code Rules

Version: 2.5.0  
Last Updated: March 20, 2026  
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

# 3.1 Sequential Failure Flow Must Be Functional

In domain/ and application/, sequential workflows that can fail MUST use typed functional composition.

Required:

- Use `Either` / `Result` as the accumulator for multi-step operations
- Prefer `foldLeft` / `foldRight` when iterating through collections with possible failure
- Use `flatMap` to short-circuit through explicit failure types

Forbidden:

- `for` / `while` loops with `return Left(...)` or `return Right(...)` inside the loop body
- mutable accumulation combined with early-return failure exits
- imperative loop-based orchestration of business success/failure flow

Rationale:

- early returns inside loops obscure the control model
- `Either`-based folds make success/failure propagation explicit
- business flow should read as composition, not control jumping

---

# 4. No Anemic Domain Model

Aggregates MUST contain behavior.

The following is forbidden:

- Pure data containers
- Getter/setter-only domain objects
- Business logic implemented outside aggregates

Behavior must live where the invariants live.

Aggregates MUST NOT expose public accessor surfaces for persistence support,
read-model support, repository convenience, or query convenience.

The following are forbidden on aggregates:

- sections named `Query Accessors`, `Read Model Accessors`, or equivalent
- comments such as "used for read models", "used for repository lookups", or "do not use for decision-making"
- public zero-argument field-style methods whose primary purpose is exposing aggregate state to external callers

Allowed alternatives:

- explicit snapshot or projection methods returning dedicated read types
- query-side read models built outside the aggregate
- infrastructure mapping approaches that do not widen the aggregate's public API

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

# 7.1 Mutating Repository Ports Must Not Erase Success Semantics

Public repository methods that mutate state MUST return an explicit success value when the post-operation domain result matters.

Forbidden:

- `Either<Error, Unit>` for `add`, `save`, `update`, `create`, or similar mutating repository methods when the updated or persisted aggregate is the natural outcome
- command ports that preserve typed failure but discard meaningful success state
- repository contracts that force callers to re-query solely to recover the state just written

Allowed:

- `Either<RepositoryError, Appointment>` for create or update operations on an `AppointmentRepository`
- `Either<Error, Aggregate>` when persistence may enrich, normalize, or otherwise finalize the returned aggregate
- `Either<Error, CommandResult>` when the command result is not the aggregate itself but is still the explicit business outcome

Exception:

- `Either<Error, Unit>` is acceptable only when the command truly has no meaningful domain result and returning one would be artificial

Rationale:

- repositories are public ports and must preserve business meaning on both failure and success
- `Unit` on mutating ports hides outcome semantics and encourages extra lookup calls
- command/query separation allows commands to return the explicit result of the command itself

---

# 7.2 Relational Persistence Is Not The Default

JPA, Hibernate, and relational databases MUST NOT be introduced by default in generated or proposed designs.

Forbidden:

- selecting PostgreSQL, MySQL, MariaDB, or similar relational infrastructure without an explicit requirement
- introducing JPA entities or ORM mappings as the assumed persistence model
- shaping aggregates or repository contracts around relational schema concerns by default

Allowed:

- relational persistence when the user explicitly asks for it
- relational persistence when audited requirements clearly demand relational constraints, joins, reporting, or interoperability that justify it
- simple infrastructure adapters that keep persistence decisions behind repository ports

Rationale:

- persistence technology must follow domain needs, not generator habit
- JPA and relational defaults tend to pull schema and ORM concerns into the model too early
- unnecessary relational infrastructure increases complexity and narrows design options without proven need

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

The callee MUST report failure; it MUST NOT decide handling policy.

Required:

- Return a typed error to the caller (for example `Either.Left(ResourceNotFound)`)
- Preserve enough context for caller-side policy decisions

Forbidden:

- Silent no-op on failed state mutation attempts
- Logging-only handling for business failures in inner layers
- Throwing runtime exceptions for expected business failures

Handling policy (retry, degrade, abort, alert) belongs to the caller boundary.

---

# 15. Streaming Discipline for Potentially Large Sequences

When a method may produce a potentially large or conceptually unbounded sequence,
it SHOULD favor streaming over eager materialization.

Avoid inside domain:

- map → collect → re-iterate patterns
- Double traversal of large collections
- Premature intermediate list construction
- Redundant `isEmpty()` guards before loops/maps/filters/folds where empty behavior is already naturally correct

Prefer:

- Single-pass transformations
- Stream API usage for transformation chains
- Compositional flow

Streaming is not mandatory for clearly bounded small collections.
Only use explicit empty guards when empty input has distinct business semantics that differ from natural iteration outcomes.

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

# 18. Atomic Check-and-Act for Shared State (CRITICAL)

If correctness depends on evaluating a condition and then mutating shared state,
the evaluation and mutation MUST be atomic at the ownership boundary.

Forbidden patterns:

- `if (canX()) { doX() }` on shared mutable state without atomic guarantees
- Read-then-write flows that rely on stale snapshots for invariant enforcement
- Split check and mutation across layers without a transactional/locking/CAS boundary

Required patterns (choose one appropriate mechanism):

- Atomic compare-and-set operations
- Lock-protected critical sections
- Database transaction with correct isolation plus constraint enforcement
- Single-writer serialized command handling

Severity guidance:

- CRITICAL when invariant violations are possible (oversell, double-booking, duplicate commitment)
- MAJOR when only non-invariant side effects are duplicated

The owning boundary must expose intention-driven atomic operations
(for example `reserveIfAvailable`) instead of exposing separate check and act primitives.

---

End of Code Rules.
