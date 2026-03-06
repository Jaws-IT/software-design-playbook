# SOFTWARE PRINCIPLES

Version: 2.1  
Last Updated: January 17, 2026  
Includes Clean Code Integration

---

## Summary

- Tell Don't Ask — Tell domain objects what to do, do not query their state
- Intention-Revealing Names and Functions — Names and method signatures reveal true intent
- Avoid Meaningless Suffixes — No -Manager, -Handler, -Processor suffixes
- Explicit over Implicit — Clear intent over clever code
- Make Errors Explicit and Illegal States Impossible — Use type system + proper error handling
- Objects Hide Data, Expose Behavior — Objects vs data structures distinction
- Compositional Inside, Semantic at Boundaries — Optimize for composition internally, clarity externally
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

---

Related files:
[principles/code-rules.md](principles/code-rules.md)  
[principles/code-anti-patterns.md](principles/code-anti-patterns.md)  
[patterns/testing-patterns.md](patterns/testing-patterns.md)  
[standards/clean-code-formatting.md](standards/clean-code-formatting.md)
