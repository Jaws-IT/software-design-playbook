# STRATEGIC DESIGN PATTERNS

*Version: 1.0.0 | Last Updated: January 22, 2026 | Mental Models for Design Validation*

## Summary

These are mental models and design validation techniques that help architects make better decisions. Unlike tactical patterns (how to write code), these are strategic patterns (how to think about design).

### Core Mental Models
- **Extremefy** - Scale design by 1000x to expose structural limitations
- **Complexity Must Earn Its Keep** - Every complexity needs demonstrable value
- **Aggregate Transaction Boundary** - Transaction scope reveals coupling
- **Validation Belongs in Operations** - Validate as part of state changes
- **The Intention Test** - Method names must pass "the intention is..." test
- **Clock Abstraction** - Never allow direct time dependencies

---

## Extremefy

**Definition**: A design validation technique where you mentally scale a system's load, data volume, or concurrency by orders of magnitude to expose structural limitations.

### The Technique

1. Take any design decision (data structure, algorithm, coordination pattern)
2. Ask: **"What if there were 1000x more of this?"**
3. Identify breaking points: sequential bottlenecks, memory limits, coordination overhead
4. Decide if the design needs to change or if the extreme scenario is genuinely out of scope

### Why It Works

Many designs work fine at small scale but have hidden O(n) or O(n²) behaviors that only manifest at scale. **Extremefy reveals these before they become production problems.**

Junior and mid-level developers often miss this step because their mental models are based on small-scale testing. They think "it works with 3 items" means "it works."

```kotlin
// ❌ Works fine with 3 resources
fun claimResources(resources: List<ResourceId>): ClaimResult {
    // Claim each resource sequentially
    for (resource in resources) {
        claim(resource)           // Network call
    }
    
    // Then confirm all
    for (resource in resources) {
        confirm(resource)         // Another network call
    }
    
    return ClaimResult.success()
}
// Extremefy Question: What if there were 1000 resources?
// Answer: 2000 sequential network calls! Total time = 1000 * latency
// This design doesn't scale - needs parallel processing

// ✅ Extremefy-validated design
suspend fun claimResources(resources: List<ResourceId>): ClaimResult = coroutineScope {
    // Claim all in parallel
    val claims = resources.map { resource ->
        async { claim(resource) }
    }.awaitAll()
    
    // Confirm all in parallel
    val confirmations = claims.map { claim ->
        async { confirm(claim) }
    }.awaitAll()
    
    return ClaimResult.success()
}
// Extremefy Answer: With 1000 resources, still just ~latency time
// This design scales linearly
```

### Examples of Extremefy in Action

| Design Decision | Extremefy Question | Potential Issue Exposed |
|-----------------|-------------------|------------------------|
| "We process orders sequentially" | What happens with 1000 orders/second? | Sequential bottleneck - need async processing |
| "We load all users into memory" | What happens with 1,000,000 users? | Memory exhaustion - need pagination/streaming |
| "We claim all resources before confirming any" | What happens with 1000 resources? | 2000 sequential operations - need parallelization |
| "We validate by loading full history" | What happens with 10 years of data? | Query performance degrades - need snapshots |
| "We hold locks while making HTTP calls" | What happens with 100 concurrent requests? | Lock contention causes thread starvation |
| "We sync state with database on every change" | What happens with 10,000 changes/second? | Database becomes bottleneck - need batching |

### When to Apply Extremefy

Apply this mental model:

- **During design reviews** - Before committing to an approach
- **When a solution "feels" complex** - Complexity often hides scale problems
- **When someone asks "why is it done this way?"** - Extremefy explains the reasoning
- **Before committing to synchronous/sequential patterns** - These rarely scale
- **When adding loops or batch operations** - Loop over what? How many?

### The Process

```kotlin
// Step 1: Identify the scale variable
fun processPayments(payments: List<Payment>) {
    // Scale variable: size of payments list
}

// Step 2: Ask "what if 1000x more?"
// Current: 10 payments
// Extremefy: 10,000 payments

// Step 3: Identify bottlenecks
for (payment in payments) {
    validate(payment)           // DB query per payment = 10,000 queries
    processWithGateway(payment) // HTTP call per payment = 10,000 calls
    saveResult(payment)         // DB write per payment = 10,000 writes
}
// Total: 30,000 sequential operations!

// Step 4: Redesign or accept
// If 10,000 payments is realistic → redesign for parallelism + batching
// If 10,000 payments is impossible → accept current design
```

### Real-World Example: Multi-Aggregate Coordination

**Original Design**: Claim all parking slots sequentially, then confirm all sequentially.

```kotlin
// ❌ Fails Extremefy test
class ParkingCoordinator {
    fun reserveParking(slots: List<SlotId>): Either<ReservationError, Reservation> {
        val claims = mutableListOf<ClaimedSlot>()
        
        // Sequential claiming
        for (slot in slots) {
            val claim = slotAggregate.claim(slot)
            if (claim.isFailure()) {
                // Compensate all previous claims
                claims.forEach { compensate(it) }
                return Either.Left(ReservationError.ClaimFailed)
            }
            claims.add(claim)
        }
        
        // Sequential confirmation
        for (claim in claims) {
            slotAggregate.confirm(claim)
        }
        
        return Either.Right(Reservation(claims))
    }
}

// Extremefy Question: What if there were 1000 parking slots?
// Answer: 
// - 1000 sequential claim operations
// - If one fails, 999 compensations
// - Then 1000 sequential confirmations
// - Total: potentially 3000 sequential operations
// - Time: 3000 * latency (could be 30+ seconds!)
```

**Extremefy-Validated Design**: Parallel claiming with streaming confirmation.

```kotlin
// ✅ Passes Extremefy test
class ParkingCoordinator {
    suspend fun reserveParking(slots: List<SlotId>): Either<ReservationError, Reservation> = coroutineScope {
        // Parallel claiming - all slots claimed simultaneously
        val claimResults = slots.map { slot ->
            async { slotAggregate.claim(slot) }
        }.awaitAll()
        
        // Check if all succeeded
        val failures = claimResults.filter { it.isFailure() }
        if (failures.isNotEmpty()) {
            // Parallel compensation
            claimResults.filter { it.isSuccess() }.map { claim ->
                async { compensate(claim) }
            }.awaitAll()
            return Either.Left(ReservationError.ClaimFailed)
        }
        
        // Parallel confirmation
        val confirmations = claimResults.map { claim ->
            async { slotAggregate.confirm(claim) }
        }.awaitAll()
        
        return Either.Right(Reservation(confirmations))
    }
}

// Extremefy Answer: With 1000 parking slots:
// - All claims happen in parallel: ~latency time (not 1000x latency)
// - Compensation if needed: parallel, not sequential
// - All confirmations in parallel: ~latency time
// - Total: ~3x latency (regardless of slot count)
// - Time: ~300ms instead of 30+ seconds
```

### Anti-Pattern It Prevents

**Premature optimization based on assumptions that don't survive scale testing.**

```kotlin
// ❌ Assumption: "We must claim all before confirming any"
// Sounds logical for 3 resources
// Becomes 2000 operations for 1000 resources

// Why do we need this order?
// Extremefy forces you to question the assumption

// ✅ Reality: Parallel claiming + streaming confirmation
// Works for 3 resources AND 1000 resources
```

### What Extremefy Is NOT

**Not**: Premature optimization
- Extremefy doesn't mean "optimize everything for 1M users"
- It means "understand where this design breaks"

**Not**: Always choosing complex solutions
- Sometimes Extremefy reveals "we'll never have 1000x"
- Then simple sequential code is fine

**Not**: Performance testing
- This is a mental model, not a benchmark
- Use it during design, not after implementation

### Decision Tree

```
Design Decision Made
│
├─ Identify scale variable (list size, request rate, data volume)
│
├─ Ask: "What if 1000x more?"
│
├─ Does design break?
│   │
│   ├─ YES → Is 1000x realistic?
│   │   │
│   │   ├─ YES → Redesign for scale
│   │   │
│   │   └─ NO → Accept current design, document limit
│   │
│   └─ NO → Design is sound, proceed
│
└─ Document reasoning
```

### Extremefy in Code Reviews

**Reviewer**: "Why are we processing these in parallel?"

**Developer (without Extremefy)**: "Uh, performance?"

**Developer (with Extremefy)**: "We could have up to 500 items in this list in production. Sequential processing would take 500 * 50ms = 25 seconds. Parallel processing takes ~50ms regardless of count. Extremefy showed sequential doesn't scale."

**Reviewer**: "Got it. Approved."

---

## Complexity Must Earn Its Keep

**Principle**: Every piece of complexity should provide demonstrable value. If someone asks "why is this here?" and you can't immediately explain the concrete benefit, the complexity is suspect.

### The Test

Before adding complexity, answer these three questions:

1. **Can you explain the benefit in one sentence?**
2. **Have you validated that the benefit actually occurs?**
3. **Would simpler code with derived state work instead?**

If you can't clearly answer all three, the complexity probably isn't justified.

### Example: Unearned Complexity

```kotlin
// ❌ Complex phase tracking
enum class ReservationPhase {
    CLAIMING,
    CONFIRMING,
    COMPENSATING,
    COMPLETED,
    FAILED
}

class Reservation(
    private var phase: ReservationPhase = ReservationPhase.CLAIMING,
    private val claims: MutableList<Claim> = mutableListOf()
) {
    fun addClaim(claim: Claim): Reservation {
        // Why this guard? What does it prevent?
        if (phase != ReservationPhase.CLAIMING) {
            return this  // Silently ignore - what problem does this solve?
        }
        claims.add(claim)
        return this
    }
    
    fun confirm(): Reservation {
        // More phase checking
        if (phase != ReservationPhase.CLAIMING) {
            return this
        }
        phase = ReservationPhase.CONFIRMING
        // ... confirmation logic
        return this
    }
}

// Questions that reveal unearned complexity:
// Q: "Why do we need phase tracking?"
// A: "To prevent invalid state transitions"
// Q: "What invalid transitions are possible?"
// A: "Uh... not sure. Maybe confirming twice?"
// Q: "Can that actually happen with our design?"
// A: "Well, no, because we only call confirm once..."
// VERDICT: Complexity doesn't earn its keep - remove it
```

### Example: Earned Complexity

```kotlin
// ✅ Complexity justified by clear benefit
sealed class ReservationState {
    data class Claiming(val claims: List<Claim>) : ReservationState()
    data class Confirmed(val confirmation: Confirmation) : ReservationState()
    data class Failed(val reason: FailureReason) : ReservationState()
}

// Q: "Why use sealed class instead of boolean flags?"
// A: "Makes illegal states impossible - can't be confirmed AND failed simultaneously"
// Q: "Does this problem actually occur?"
// A: "Yes, in async systems, concurrent updates could set both flags"
// Q: "Could simpler code work?"
// A: "No, boolean flags allow 4 states (true/true, true/false, etc) when only 3 are valid"
// VERDICT: Complexity earns its keep - justified
```

### Applying the Test

**Scenario**: Developer adds caching layer.

```kotlin
// Added complexity: Cache with TTL, invalidation, warming
class CachedUserRepository(
    private val delegate: UserRepository,
    private val cache: Cache<UserId, User>
) {
    // 50 lines of caching logic
}
```

**The Test**:
1. **Benefit in one sentence?** "Reduces database load and improves response time"
2. **Validated benefit?** "Measured: p99 latency from 250ms to 50ms, DB queries reduced 80%"
3. **Simpler alternative?** "No - tried in-memory list, but couldn't handle 100K users"

**VERDICT**: Complexity earns its keep.

**Counter-example**:
1. **Benefit in one sentence?** "Might improve performance someday"
2. **Validated benefit?** "Not measured yet, but theoretically..."
3. **Simpler alternative?** "Well, we could just query the database..."

**VERDICT**: Premature optimization - complexity doesn't earn its keep.

### Red Flags

These phrases indicate unearned complexity:

- "We might need this later"
- "It's more flexible this way"
- "Best practice says..."
- "I saw this pattern in a blog post"
- "It's more enterprise-grade"
- "We need to be prepared for..."

### The Simplicity Bias

**Default to simple.** Only add complexity when:
- You can explain the concrete benefit
- You've measured the problem
- You've tried simpler solutions first

```kotlin
// ❌ "Flexible" complexity
interface PaymentStrategy {
    fun process(payment: Payment): Result
}
class CreditCardStrategy : PaymentStrategy { ... }
class PayPalStrategy : PaymentStrategy { ... }
class StrategyFactory {
    fun getStrategy(type: PaymentType): PaymentStrategy { ... }
}

// Q: "Do we actually need this abstraction?"
// A: "Well, we only have one payment method right now..."
// VERDICT: YAGNI - complexity doesn't earn its keep yet

// ✅ Simple, direct
fun processPayment(payment: Payment): Result {
    return creditCardGateway.charge(payment)
}

// When second payment method is ACTUALLY needed, THEN abstract
```

---

## Aggregate Transaction Boundary

**Principle**: An aggregate is a transactional consistency boundary. Updating multiple aggregates in one transaction means their invariants are implicitly coupled.

### The Implication

If you find yourself needing to update multiple aggregates atomically, you have two choices:

1. **Redesign them as a single aggregate** (if they truly share invariants)
2. **Coordinate through an explicit process/saga** (if they are independent but need coordination)

### The Smell

```kotlin
// ❌ Multiple aggregates in one transaction = implicit coupling
@Transactional
fun reserveParkingWithPayment(userId: UserId, slotId: SlotId, amount: Money) {
    // Three aggregates updated atomically
    val slot = parkingSlotAggregate.claim(slotId)       // Aggregate 1
    val payment = paymentAggregate.charge(userId, amount) // Aggregate 2
    val reservation = reservationAggregate.create(userId, slot, payment) // Aggregate 3
    
    // All succeed together or all fail together
    // But why? Do they REALLY share invariants?
}

// Problems:
// 1. Implicit coupling - can't change one without affecting others
// 2. Can't scale - single transaction across multiple aggregates
// 3. Can't distribute - all aggregates must be in same database
// 4. Unclear invariants - what consistency rule requires all three together?
```

### The Fix: Model Coordination Explicitly

```kotlin
// ✅ Explicit process coordination (Saga pattern)
class ParkingReservationProcess {
    suspend fun execute(
        userId: UserId, 
        slotId: SlotId, 
        amount: Money
    ): Either<ProcessError, Reservation> {
        // Each aggregate update is its own transaction
        
        // Step 1: Claim parking slot
        val slotClaim = parkingSlotAggregate.claim(slotId)
        if (slotClaim.isFailure()) {
            return Either.Left(ProcessError.SlotUnavailable)
        }
        
        // Step 2: Process payment
        val payment = paymentAggregate.charge(userId, amount)
        if (payment.isFailure()) {
            // Compensate: release the slot
            parkingSlotAggregate.release(slotClaim)
            return Either.Left(ProcessError.PaymentFailed)
        }
        
        // Step 3: Create reservation
        val reservation = reservationAggregate.create(userId, slotClaim, payment)
        if (reservation.isFailure()) {
            // Compensate: refund payment and release slot
            paymentAggregate.refund(payment)
            parkingSlotAggregate.release(slotClaim)
            return Either.Left(ProcessError.ReservationFailed)
        }
        
        return Either.Right(reservation)
    }
}

// Benefits:
// 1. Explicit coordination - clear what happens when
// 2. Scalable - each aggregate can be in different database
// 3. Distributable - aggregates can be in different services
// 4. Clear invariants - process handles coordination, aggregates handle their own rules
```

### How to Decide: One Aggregate or Saga?

**Ask**: "Do these entities share an invariant that must be checked atomically?"

```kotlin
// ✅ Single aggregate - shared invariant
class BankAccount(
    private val balance: Money,
    private val overdraftLimit: Money
) {
    fun withdraw(amount: Money): Either<InsufficientFunds, BankAccount> {
        // Invariant: balance - amount >= -overdraftLimit
        // Balance and overdraft MUST be checked together atomically
        return when {
            balance - amount < -overdraftLimit -> 
                Either.Left(InsufficientFunds)
            else -> 
                Either.Right(copy(balance = balance - amount))
        }
    }
}

// ✅ Saga - no shared invariant
class TransferProcess {
    suspend fun transfer(from: AccountId, to: AccountId, amount: Money): Either<TransferError, Transfer> {
        // No shared invariant between accounts
        // Account A doesn't need to know about Account B's balance
        
        val debit = accountAggregate.debit(from, amount)
        if (debit.isFailure()) return Either.Left(TransferError.InsufficientFunds)
        
        val credit = accountAggregate.credit(to, amount)
        if (credit.isFailure()) {
            accountAggregate.credit(from, amount) // Compensate
            return Either.Left(TransferError.CreditFailed)
        }
        
        return Either.Right(Transfer(debit, credit))
    }
}
```

### Common Mistake: Transaction Scope Creep

```kotlin
// ❌ Started simple, grew into coupling
@Transactional
fun placeOrder(customerId: CustomerId, items: List<Item>) {
    val order = orderAggregate.create(customerId, items)  // Aggregate 1
    
    // Later: "We need to update inventory"
    inventoryAggregate.reserve(items)  // Aggregate 2
    
    // Later: "We need to charge payment"
    paymentAggregate.charge(customerId, order.total)  // Aggregate 3
    
    // Later: "We need to update loyalty points"
    loyaltyAggregate.addPoints(customerId, order.total)  // Aggregate 4
    
    // Now we have 4 aggregates in one transaction!
    // All coupled, can't scale, can't distribute
}

// ✅ Recognized coupling, made coordination explicit
class OrderPlacementProcess {
    suspend fun execute(customerId: CustomerId, items: List<Item>): Either<OrderError, Order> {
        val order = orderAggregate.create(customerId, items)
        
        val inventory = inventoryAggregate.reserve(items)
        if (inventory.isFailure()) return compensateOrder(order)
        
        val payment = paymentAggregate.charge(customerId, order.total)
        if (payment.isFailure()) return compensateInventory(inventory, order)
        
        val loyalty = loyaltyAggregate.addPoints(customerId, order.total)
        // Loyalty is not critical - log failure but don't compensate
        
        return Either.Right(order)
    }
}
```

---

## Validation Belongs in State-Changing Operations

**Principle**: Avoid standalone "validate" functions that don't change state. Validation should be part of the operation that uses it.

### The Smell

```kotlin
// ❌ Separate validation function
interface IdentityService {
    fun validateIdentityAvailable(claim: Claim): Unit  // Returns nothing useful
    fun createIdentityRegistration(claim: Claim): Identity
}

// Usage forces two calls
fun registerIdentity(claim: Claim): Either<RegistrationError, Identity> {
    // Call 1: Validate
    try {
        identityService.validateIdentityAvailable(claim)
    } catch (e: IdentityNotAvailableException) {
        return Either.Left(RegistrationError.NotAvailable)
    }
    
    // Call 2: Create
    val identity = identityService.createIdentityRegistration(claim)
    return Either.Right(identity)
}
```

**The Problem**: `validateIdentityAvailable` fails "The Intention Test."

**Question**: "The intention is... validateIdentityAvailable"
**Response**: "Validate for WHAT? What happens after validation?"
**Answer**: "To create an identity registration"

**The REAL intention is**: `createIdentityRegistration` - that's the actual goal.

### The Fix

```kotlin
// ✅ Validation happens inside the state-changing operation
interface IdentityService {
    fun createIdentityRegistration(claim: Claim): Either<RegistrationError, Identity>
}

class IdentityServiceImpl : IdentityService {
    override fun createIdentityRegistration(claim: Claim): Either<RegistrationError, Identity> {
        // Validation is PART of creation
        if (!isIdentityAvailable(claim)) {
            return Either.Left(RegistrationError.IdentityNotAvailable)
        }
        
        if (!isValidFormat(claim.identityNumber)) {
            return Either.Left(RegistrationError.InvalidFormat)
        }
        
        // Create the identity
        val identity = Identity.create(claim)
        return Either.Right(identity)
    }
    
    // Private validation helpers - not exposed
    private fun isIdentityAvailable(claim: Claim): Boolean { ... }
    private fun isValidFormat(identityNumber: String): Boolean { ... }
}
```

### Why This Matters

**Standalone validation creates problems:**

1. **Race conditions**: State could change between validate and create
2. **Duplication**: Creation probably validates again anyway
3. **Unclear intention**: Validation for what purpose?
4. **Extra calls**: Two round-trips instead of one

```kotlin
// ❌ Race condition with separate validation
fun registerUser(email: String): Either<Error, User> {
    // Thread 1 checks - email available
    userService.validateEmailAvailable(email)  
    
    // Thread 2 creates user with same email - succeeds
    
    // Thread 1 tries to create - CONFLICT!
    userService.createUser(email)
}

// ✅ Atomic check-and-create
fun createUser(email: String): Either<Error, User> {
    // Validation + creation in single operation
    // No race condition possible
    return if (emailExists(email)) {
        Either.Left(Error.EmailTaken)
    } else {
        Either.Right(User.create(email))
    }
}
```

### When Validation IS Separate

**Legitimate cases for standalone validation:**

```kotlin
// ✅ UI validation before submission
class RegistrationForm {
    fun validateBeforeSubmit(): List<ValidationError> {
        // Fast client-side validation
        // Gives immediate feedback
        // But server STILL validates on create
    }
}

// ✅ Validation rules query (no state change intended)
class ValidationRules {
    fun getPasswordRequirements(): PasswordPolicy {
        // Returning policy information, not validating specific password
        return PasswordPolicy(minLength = 8, requiresSpecialChar = true)
    }
}
```

---

## Capability-Based Policy Enforcement

**Principle**: Enforce policies outside the aggregate by requiring a capability object whose presence proves the policy has already been satisfied.

### Intent

An aggregate must not evaluate policy. It may require proof that the policy decision was already made.

### Why

- Aggregates protect invariants, not contextual policy
- Policy ownership stays outside the aggregate
- The method signature makes prior authorization explicit
- The aggregate avoids hidden dependencies on external knowledge

### The Pattern

```kotlin
// Policy evaluation happens before aggregate invocation
data class CancellationAuthorized private constructor(val reservationId: ReservationId) {
    companion object {
        fun grantedFor(reservationId: ReservationId): CancellationAuthorized =
            CancellationAuthorized(reservationId)
    }
}

class CancellationPolicy {
    fun authorize(reservation: Reservation, actor: Actor): Either<PolicyError, CancellationAuthorized> =
        if (actor.canCancel(reservation)) {
            Either.Right(CancellationAuthorized.grantedFor(reservation.id))
        } else {
            Either.Left(PolicyError.CancellationNotAllowed)
        }
}

class Reservation(
    val id: ReservationId,
    private val status: ReservationStatus
) {
    fun cancel(capability: CancellationAuthorized): Either<ReservationError, Reservation> =
        when {
            status != ReservationStatus.Active ->
                Either.Left(ReservationError.NotActive)
            else ->
                Either.Right(copy(status = ReservationStatus.Cancelled))
        }
}
```

```kotlin
// Application/service layer coordinates policy + aggregate
fun cancelReservation(reservationId: ReservationId, actor: Actor): Either<Error, Reservation> {
    val reservation = reservationRepository.load(reservationId)

    val capability = cancellationPolicy.authorize(reservation, actor)
        .mapLeft { Error.Policy(it) }
        .getOrElse { return Either.Left(it) }

    return reservation.cancel(capability)
        .mapLeft { Error.Domain(it) }
}
```

### Rule

- Policy evaluation produces a capability object
- The aggregate requires that capability in the command method
- The aggregate does not perform policy evaluation
- The aggregate still enforces its own invariants

### What To Avoid

```kotlin
// ❌ Aggregate evaluates policy directly
class Reservation {
    fun cancel(actor: Actor, policy: CancellationPolicy, clock: Clock): Either<ReservationError, Reservation> {
        if (!policy.isCancellationAllowed(this, actor, clock)) {
            return Either.Left(ReservationError.NotAllowed)
        }

        if (status != ReservationStatus.Active) {
            return Either.Left(ReservationError.NotActive)
        }

        return Either.Right(copy(status = ReservationStatus.Cancelled))
    }
}
```

This mixes policy authority with invariant protection and leaks external knowledge into the aggregate.

```java
// ❌ Minimal anti-pattern: aggregate coupled to external policy service
public Either<ActionError, Aggregate> performAction(Data data, ExternalPolicyService externalService) {
    if (!externalService.isAllowed(data)) {
        return Either.left(ActionError.PolicyNotSatisfied);
    }

    return Either.right(applyAction(data));
}
```

This is still wrong even though it does not throw.
The problem is not only exception style.
The problem is that the aggregate is evaluating policy by consulting an external dependency.

### Notes

- Capability objects should be intention-revealing, not generic markers
- The aggregate may require the capability without branching on external policy logic
- If the aggregate needs data for its own invariant, model that data explicitly as part of the command or domain state rather than hiding it in policy evaluation

---

## Clock Abstraction for Time Dependencies

**Principle**: Never allow direct time dependencies (`Instant.now()`, `System.currentTimeMillis()`) in domain logic. Depend on a Clock abstraction instead.

### Why

- **Tests become deterministic** - no flaky time-based tests
- **Time-based business rules are testable** - can test "what happens after 1 hour"
- **Dependencies are explicit** - code that depends on time shows it

### The Anti-Pattern

```kotlin
// ❌ Direct time dependency - untestable
class Session(
    val userId: UserId,
    val createdAt: Instant
) {
    fun isExpired(): Boolean {
        val now = Instant.now()  // Direct dependency on system time!
        return Duration.between(createdAt, now) > Duration.ofHours(1)
    }
}

// How do you test expiration? 
// - Thread.sleep(3600000)? Too slow!
// - Mock Instant.now()? Can't mock static methods in Kotlin!
// - Change system time? Breaks other tests!
```

### The Pattern

```kotlin
// ✅ Clock abstraction - fully testable
interface Clock {
    fun now(): Instant
}

class SystemClock : Clock {
    override fun now(): Instant = Instant.now()
}

class FixedClock(private val fixedTime: Instant) : Clock {
    override fun now(): Instant = fixedTime
}

class Session(
    val userId: UserId,
    val createdAt: Instant
) {
    fun isExpired(clock: Clock): Boolean {
        val now = clock.now()
        return Duration.between(createdAt, now) > Duration.ofHours(1)
    }
}

// ✅ Test is deterministic
@Test
fun `session expires after 1 hour`() {
    val createdAt = Instant.parse("2025-01-22T10:00:00Z")
    val session = Session(userId, createdAt)
    
    // Test exactly 1 hour later
    val clockAfterOneHour = FixedClock(Instant.parse("2025-01-22T11:00:00Z"))
    assertFalse(session.isExpired(clockAfterOneHour))
    
    // Test exactly 1 hour + 1 second later
    val clockAfterExpiry = FixedClock(Instant.parse("2025-01-22T11:00:01Z"))
    assertTrue(session.isExpired(clockAfterExpiry))
}
```

### Usage in Aggregates

```kotlin
// ✅ All time-based business logic uses Clock
class Order(
    val id: OrderId,
    val customerId: CustomerId,
    private val items: List<OrderItem>,
    private val createdAt: Instant,
    private val status: OrderStatus
) {
    fun cancel(clock: Clock): Either<OrderError, Pair<Order, OrderCancelled>> {
        // Business rule: Can only cancel within 24 hours
        val hoursSinceCreation = Duration.between(createdAt, clock.now()).toHours()
        
        return when {
            status != OrderStatus.Pending ->
                Either.Left(OrderError.CannotCancelProcessedOrder)
            hoursSinceCreation >= 24 ->
                Either.Left(OrderError.CancellationWindowExpired)
            else -> {
                val cancelledOrder = copy(status = OrderStatus.Cancelled)
                val event = OrderCancelled(id, clock.now())
                Either.Right(cancelledOrder to event)
            }
        }
    }
}

// ✅ Test is fast and deterministic
@Test
fun `cannot cancel order after 24 hours`() {
    val createdAt = Instant.parse("2025-01-22T10:00:00Z")
    val order = Order.create(customerId, items, createdAt)
    
    // Advance time by 24 hours and 1 second
    val clock = FixedClock(Instant.parse("2025-01-23T10:00:01Z"))
    
    val result = order.cancel(clock)
    
    assertThat(result).isFailure()
    assertThat(result.error).isInstanceOf<OrderError.CancellationWindowExpired>()
}
```

### Clock Injection Pattern

```kotlin
// ✅ Inject clock at service/aggregate creation
class OrderService(
    private val orderRepository: OrderRepository,
    private val clock: Clock  // Injected dependency
) {
    fun placeOrder(customerId: CustomerId, items: List<Item>): Either<OrderError, Order> {
        val order = Order.create(
            customerId = customerId,
            items = items,
            createdAt = clock.now()  // Use injected clock
        )
        return orderRepository.save(order)
    }
}

// Production: Use system clock
val productionService = OrderService(
    orderRepository = PostgresOrderRepository(),
    clock = SystemClock()
)

// Tests: Use fixed clock
val testService = OrderService(
    orderRepository = InMemoryOrderRepository(),
    clock = FixedClock(Instant.parse("2025-01-22T10:00:00Z"))
)
```

---

## Summary: When to Apply These Mental Models

| Mental Model | Apply When | Validates Against |
|--------------|-----------|-------------------|
| **Extremefy** | Designing any process/algorithm | Hidden O(n) behaviors, sequential bottlenecks |
| **Complexity Must Earn Its Keep** | Adding abstraction/pattern | Over-engineering, premature abstraction |
| **Aggregate Transaction Boundary** | Multiple aggregates in transaction | Implicit coupling, unclear invariants |
| **Validation in Operations** | Creating separate validate method | Race conditions, unclear intention |
| **Clock Abstraction** | Time-based business logic | Untestable time dependencies |

### The Design Review Checklist

Before approving any design, ask:

- [ ] **Extremefy**: What happens with 1000x more? Does it break?
- [ ] **Complexity**: Can you explain the benefit in one sentence? Is it measured?
- [ ] **Transactions**: Are multiple aggregates coupled? Should this be a saga?
- [ ] **Validation**: Is validation separate from state change? Why?
- [ ] **Time**: Does code call `Instant.now()`? Should it use Clock?

---

*Related files: principles/software-principles.md, principles/code-rules.md, patterns/architectural-decision-patterns.md*
