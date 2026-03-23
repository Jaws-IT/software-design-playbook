# SOFTWARE PRINCIPLES

Version: 2.3.0  
Last Updated: March 20, 2026  
Includes Clean Code Integration

---

## Summary

- Tell Don't Ask — Tell domain objects what to do, do not query their state
- Process Ownership Near the Domain Model — Keep workflow authority close to the model that owns the rules
- Capability-Proven Policy Enforcement — Pass proof of satisfied policy without making aggregates evaluate policy
- Intention-Revealing Names and Functions — Names and method signatures reveal true intent
- Avoid Meaningless Suffixes — No -Manager, -Handler, -Processor suffixes
- Explicit over Implicit — Clear intent over clever code
- Make Errors Explicit and Illegal States Impossible — Use type system + proper error handling
- Objects Hide Data, Expose Behavior — Objects vs data structures distinction
- Compositional Inside, Semantic at Boundaries — Optimize for composition internally, clarity externally
- Prefer Declarative and Functional Style Over Imperative Control Flow — Express transformations and outcomes directly
- Integration Events Are Irreversible Facts — Publish completed business facts, not transient states
- Lazy Over Eager When Scale Is Plausible — Prefer lazy composition when sequence size is unknown or potentially large
- Interface Discovery Through Usage — Design APIs from caller's perspective
- The Boy Scout Rule — Always leave code cleaner than you found it
- One Thing Rule — Each function/class does exactly one thing

---

## Detailed Principles

### Tell (so that others) Don't (need to) Ask

Tell objects what to do. Do not extract internal state in order to decide business behavior somewhere else.

Good domain design keeps decisions near the invariants they depend on.

Prefer:

- `booking.confirm()`
- `claim.attachDocument(document)`
- `account.withdraw(amount)`

Avoid:

- `if (booking.isConfirmable()) { ... }`
- `if (claim.documents().size < 3) { ... }`
- `if (account.balance() >= amount) { ... }`

If outside code must inspect internal state to decide what should happen,
behavior has leaked out of the model.

Tell-style APIs preserve:

- invariant ownership
- boundary clarity
- lower coupling
- intention-revealing code

When information must cross a boundary for read models, reporting, or integration,
return dedicated projections or DTOs rather than exposing domain internals for orchestration.

Do not address read-model or persistence needs by adding public query accessors to aggregates
and then documenting that callers should avoid using them for decisions.

That is still a Tell-Don't-Ask violation. A warning comment does not neutralize the smell.

If state must cross a boundary, prefer one of:

- an explicit snapshot or projection type
- a dedicated read model on the query side
- infrastructure-only mapping that does not widen the aggregate's public behavioral API

---

### Process Ownership Near the Domain Model

Process ownership should live as close to the domain model as possible.

If a process is primarily enforcing the rules, sequencing, or invariants of one domain concept,
that process belongs with the model that owns those rules.

Keep workflow authority near:

- the aggregate that protects the invariant
- the policy that decides what may happen
- the bounded context that is semantically responsible

Do not move process ownership outward merely because multiple steps exist.
Multiple steps do not automatically justify a detached orchestrator.

Pull process ownership away from the model only when:

- the workflow truly coordinates multiple independent authorities
- the process has its own cross-context policy
- the sequencing cannot be owned meaningfully by a single model

When process ownership drifts too far from the domain model:

- invariants become procedural checks
- authority becomes ambiguous
- orchestration starts making domain decisions
- coupling increases across boundaries

The default is simple:

- if the model owns the rule, keep the process there
- if no single model owns the rule, model the coordination explicitly

---

### Capability-Proven Policy Enforcement

Policies and invariants are not the same kind of rule.

Doctrine shorthand:

`Policies produce capabilities, Aggregates require them.`

- Invariants must be enforced inside the aggregate that owns them.
- Policies decide whether an operation may proceed in a given context.
- Policies must be enforced before the aggregate is invoked.

When an operation requires prior policy approval, pass a capability object as proof that the policy has already been satisfied.

The capability object exists to express authorized intent at the boundary.
The aggregate may require that object as a parameter, but it must not evaluate policy by querying external services, other bounded contexts, or orchestration state.

Use this pattern when:

- the policy is owned outside the aggregate
- the aggregate must not depend on policy evaluation logic
- the call should make prior authorization explicit in the type signature

Do not:

- add `verify`, `validate`, `isAllowed`, or similar policy checks inside the aggregate
- make the aggregate call out to repositories, services, other bounded contexts, or clocks just to decide if the policy allows the action
- expose interrogative methods so callers can perform policy branching on aggregate internals

The intent is simple:

- policy evaluation happens before aggregate invocation
- capability proves the policy decision already happened
- aggregate performs the state transition and still protects its own invariants

This keeps policy authority explicit without leaking policy logic into the aggregate.

---

### Intention-Revealing Names and Functions (Enhanced from Clean Code)

Both variable names and function names must clearly express their intent without requiring comments or investigation.

For Names:

Example (Kotlin):

// ❌ Mental mapping required  
val d = 5  
val users = getUsers()

// ✅ Intention-revealing names  
val daysSinceCreation = 5  
val activeUsers = getActiveUsers()

For Functions (The "Intention Is" Test):

A method name must pass this test:

"The intention is [method name]."

If this sentence does not make sense or prompts "Why?", the method name fails.

Example:

// ❌ Fails the test  
fun getAccount(): Account

// ✅ Passes the test  
fun withdrawMoney(amount: Money): Either<InsufficientFunds, Account>

Use searchable names for anything referenced multiple times.  
Single-letter variables are allowed only for short loop counters.

---

### Avoid Meaningless Suffixes

Names such as `Manager`, `Handler`, `Processor`, `Helper`, and `Util`
usually hide missing domain language.

If a type needs one of these suffixes, stop and ask:

- what business responsibility it actually owns
- what decision it makes
- what role it plays in the domain

Prefer names that reveal purpose:

- `CapacityPolicy` instead of `CapacityManager`
- `BookingConfirmation` instead of `BookingProcessor`
- `ClaimAttachmentService` only if it is truly an application service

Generic suffixes are acceptable only for technical infrastructure roles
when the role is genuinely technical and widely understood.

---

### Explicit Over Implicit

Code should reveal business intent directly.

Prefer:

- explicit types over raw strings and maps
- explicit failure models over hidden exceptions
- explicit transitions over boolean state flags
- explicit boundaries over convenience shortcuts

Avoid clever compression that makes the reader infer domain meaning from implementation details.

If the design forces the reader to reverse-engineer intent,
the code is too implicit.

---

### Prefer Declarative and Functional Style Over Imperative Control Flow

Default to declarative and functional composition when expressing business logic.

Prefer:

- `map`, `flatMap`, `fold`, and typed composition over step-by-step mutation
- expression-oriented code over procedural control flow
- transformations over manual state management
- explicit outcome types such as `Either` / `Result` over hidden control transfer

Avoid:

- imperative loops when collection combinators express the intent directly
- manual recursion where `fold` captures the pattern more clearly
- mutable accumulators for sequential transformations
- branching-heavy orchestration that obscures the success/failure flow

Additional rule for sequential business workflows:

- In domain and application logic, do not model failure flow with imperative `for` / `while` loops that `return` early from inside the loop.
- Do not use loop-body `return Left(...)` / `return Right(...)` as a control-flow shortcut for business orchestration.
- When processing a collection where each step can fail, prefer `foldLeft` / `foldRight` with an `Either` / `Result` accumulator.
- Let the accumulator carry success/failure forward instead of escaping the function from inside the loop.

Preferred:

- `items.foldLeft(Either.right(initial), step)`
- `stream.map(...).flatMap(...)`
- explicit typed composition where failure short-circuits through `Either`

Avoid:

- imperative loops with mutable accumulators plus early `return`
- “glorified goto” failure exits from inside loop bodies
- procedural control flow disguised as business orchestration

Exception:

- Imperative loops are ONLY acceptable for low-level technical mechanics when functional composition would make the code less clear, but this exception does not apply to business-rule flow in domain or application logic.

The preference is straightforward:

- functional style for business logic
- declarative flow for orchestration
- imperative style only when it materially improves clarity for low-level mechanics

---

### The Boy Scout Rule

Always leave the code cleaner than you found it.

Example improvement:

fun calculateTotal(items: List<Item>): Money {
var total = Money.ZERO
for (item in items) {
total += item.price * item.quantity
}
return total
}

Small improvements compound over time.

---

### One Thing Rule

Each function should do one thing, do it well, and do it only.  
This applies to classes as well.

Example:

fun validateUserData(userData: Map<String, String>): Either<ValidationError, ValidatedUserData>  
fun createUser(validatedData: ValidatedUserData): User  
fun saveUser(user: User): Either<SaveError, SavedUser>  
fun sendWelcomeEmail(user: User): Either<EmailError, Unit>

---

### Objects Hide Data, Expose Behavior

Objects encapsulate state and expose behavior.

Data structures expose data and contain no behavior.

Do not create hybrids.

Aggregates must not grow "query accessor" surfaces for repository lookups,
read models, or query convenience.

If a type owns invariants, expose behavior and keep state hidden.
If a type mainly exposes state, model it as a DTO, projection, snapshot, or other data structure.

Example (Object):

class Account private constructor(private val balance: Money) {

    fun withdraw(amount: Money): Either<WithdrawalError, Account> {
        return when {
            balance < amount -> Either.Left(InsufficientFunds)
            else -> Either.Right(Account(balance - amount))
        }
    }

}

Example (Data Structure):

data class UserDto(
val name: String,
val email: String,
val createdAt: Instant
)

---

### Compositional Inside, Semantic at Boundaries

Inside implementations → optimize for compositional power.  
At boundaries → optimize for semantic clarity.

This rule governs abstraction decisions.

Inside implementations (domain internals, application orchestration, infrastructure mechanisms):

Favor:

- Functional composition
- Higher-order functions
- Generic combinators
- Reusable transformations
- Structural power over narrative wording

Implementation code may prioritize composability.

At boundaries (public APIs, integration contracts, ports, domain events, external interfaces):

Favor:

- Clear domain terminology
- Intent-revealing names
- Stable semantics
- Business language

Boundaries communicate meaning, not internal flexibility.

This principle is not anti-functional.  
It is anti-accidental-abstraction.

Accidental abstraction occurs when:

- Internal combinators leak into public contracts
- Generic names replace domain meaning
- Functional machinery obscures business intent
- Abstractions exist without semantic necessity

Functional power belongs inside.  
Semantic clarity belongs at boundaries.

---

### Integration Events Are Irreversible Facts

Integration events should represent irreversible business facts.

Publish:

- `PaymentCaptured`
- `ReservationExpired`
- `ShipmentDelivered`
- `CustomerRegistered`

These are facts, not generic states.

Do not publish ambiguous or technical state markers as boundary contracts.
Cross-context consumers must react to explicit business facts, not infer outcomes from partial lifecycle signals.

---

### Lazy Over Eager When Scale Is Plausible

When working with collections or sequences, consider whether the size is:

- Small and bounded
- Potentially large
- Conceptually unbounded

If the sequence is small and clearly limited, simple lists and loops are perfectly fine.

However, when scale is plausible or unknown:

Favor:

- Lazy composition
- Streaming pipelines
- Functional chaining
- Single-pass transformations

Avoid:

- map → collect → re-iterate patterns
- Double traversal of large collections
- Building large intermediate lists unnecessarily
- Eager materialization for convenience

Example (avoid double materialization):

// ❌ Eager + double traversal  
val slots = generateTimeSlots()  
val probes = slots.map { it.toProbe() }  
for (probe in probes) { ... }

// ✅ Lazy pipeline  
generateTimeSlots()
.map { it.toProbe() }
.forEach { ... }

Lazy composition preserves:

- Memory efficiency
- Structural clarity
- Compositional power

Do not collapse domain and integration concepts merely to “save cycles.”

Streaming is not dogma.  
It is discipline when scale makes it relevant.

Clarity first.  
Then efficiency.  
Prefer designs that survive growth.

---

### Interface Discovery Through Usage

Design APIs from the caller's perspective, not from the implementer's internal structure.

An interface is good when the required operation reads naturally at the call site.

Bad interface design often starts by exposing raw data and expecting callers to assemble behavior themselves.

Prefer:

- `availability.reserve(slot)`
- `payment.capture(command)`
- `identityRegistry.register(identity)`

Avoid:

- `availability.getSlots()` followed by external selection logic
- `payment.getStatus()` followed by branching that performs business decisions elsewhere
- generic parameter bags that force callers to know too much

Usage should make the correct path easy and the incorrect path awkward.

---

### Make Errors Explicit and Illegal States Impossible

Expected business errors → Either / Result types

Example:

fun transfer(from: Account, to: Account, amount: Money): Either<TransferError, TransferReceipt>

Unexpected system failures → Exceptions

Example:

fun loadAccount(id: AccountId): Account {
return try {
database.load(id)
} catch (e: IOException) {
throw SystemException("Database unavailable", e)
}
}

Use the type system to eliminate illegal states.

Failure reporting and failure policy are separate concerns:

- Callee reports outcome explicitly (`Either.Left` / `Either.Right`)
- Caller decides policy (retry, compensate, surface, halt, ignore with intent)
- Callee must not silently swallow a failed state transition

Short rule: callee reports, caller decides.

---

Related files:
[principles/code-rules.md](principles/code-rules.md)  
[principles/code-anti-patterns.md](principles/code-anti-patterns.md)  
[patterns/testing-patterns.md](patterns/testing-patterns.md)  
[standards/clean-code-formatting.md](standards/clean-code-formatting.md)
