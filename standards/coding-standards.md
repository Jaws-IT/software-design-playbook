# Coding Standards

Version: 1.5.0

Amended 2026-08-26: correlation identity extended from integration events to **every** event and
to everything arriving at a boundary; `Instant.now()` removed from the event examples, which
contradicted the injected-clock rule the standards elsewhere require; publication ordering
documented for the first time.

Amended 2026-08-27: the layer diagram now distinguishes the domain *layer* from the
`domain/` *region* in the grouped arrangement. Command/query definitions and handlers belong
to the application layer; the previous diagram incorrectly placed them in `domain/`.

## Language & Paradigm

- **Language**: Kotlin 2.1.0
- **Paradigm**: Functional-first with DDD tactical patterns
- **Style Preference**: Prefer declarative and functional composition over imperative control flow in domain and application logic
- **Error Handling**: Arrow's `Either<Error, Success>` - never throw exceptions for expected states

## Core Principles

### 0. Preserve Existing Interfaces Unless Their Removal Is Explicitly Requested

Removing a class's implementation of an interface does **not** authorize
removing the interface itself, its contract, or supporting wiring.

If an interface appears to have no remaining implementations or usages after a
scoped change, report that discovery and ask the user whether it should be
removed. Do not delete it as inferred dead-code cleanup.

**Rule**: Existing interfaces and abstractions are preserved unless their
removal is explicitly requested or the user approves removal after the
interface is identified as unused.

**Reason**: An abstraction can preserve an intentional design boundary,
extension point, or pending work that is not visible from current references.
Scope-limited implementation changes must not silently collapse that boundary.

### 1. No Exceptions for Expected States

```kotlin
// BAD - Throwing exception for expected condition
fun fetchWidget(intent: String): String {
    val url = registry[intent] ?: throw NoProviderException(intent)
    // ...
}

// GOOD - Return Either for expected failure case
fun fetchWidget(intent: String): Either<WidgetFetchError, String> {
    val url = registry[intent] ?: return WidgetFetchError.NoProvider(intent).left()
    // ...
}
```

**Rule**: If you have an `if` statement checking a condition, it's an expected state, not exceptional.

### 2. No Separate Validation Functions

```kotlin
// BAD - Separate validation that returns Unit
fun validateIdentityAvailable(claim: ClaimKey): Either<ValidationError, Unit>

// GOOD - Validation inside the operation that uses it
fun createIdentityRegistration(claim: ClaimKey): Either<RegistrationError, Identity>
```

**Reason**: Validation functions with `Unit` return don't add value - they fail the "intention is" test.

### 3. Prefer Either on Public Abstractions

```kotlin
// AVOID - Public repository contract returns absence only
interface IdentityRepository {
    fun add(identity: Identity): Option<IdentityError>
    fun findById(id: IdentityId): Option<Identity>
}

// PREFERRED - Public contract returns explicit outcome
interface IdentityRepository {
    fun add(identity: Identity): Either<IdentityError, Identity>
    fun findById(id: IdentityId): Either<IdentityError, Identity>
}
```

**Guideline**: On outermost abstraction layers such as repository interfaces, domain services, and other public ports, prefer `Either<Error, Success>` over `Option<T>`.

**Reason**: Public methods should express intention and outcome explicitly. `Either` preserves forward business meaning: the operation either succeeds with a meaningful result or returns a meaningful typed failure. `Option` is better kept as an internal modeling tool when presence or absence is only an implementation detail.

**Use `Option` internally when**:
- Modeling optional intermediate state inside an implementation
- Representing absence before converting to a typed public outcome
- Simplifying local transformations where no public business meaning is lost

**Boundary rule**: If an `Option` reaches a public method on a repository or interface, treat that as a design smell and ask whether the caller really needs an explicit success/failure outcome instead.

### 4. Mutating Repository Methods Must Return Meaningful Success Values

```kotlin
// AVOID - Command succeeds with no semantic result
interface AppointmentRepository {
    fun add(appointment: Appointment): Either<RepositoryError, Unit>
    fun update(appointment: Appointment): Either<RepositoryError, Unit>
}

// PREFERRED - Command returns the persisted or updated domain result
interface AppointmentRepository {
    fun add(appointment: Appointment): Either<RepositoryError, Appointment>
    fun update(appointment: Appointment): Either<RepositoryError, Appointment>
}
```

**Rule**: Public state-changing repository methods MUST return a meaningful success value, not `Unit`, when the operation produces or persists a domain object whose post-operation state matters to the caller.

**Reason**: `Either<Error, Unit>` preserves failure but erases success semantics. On command-style repository ports, success should still carry business meaning: the created aggregate, the updated aggregate, or another explicit command result.

**Use `Either<Error, Unit>` only when**:
- the operation has no meaningful domain result to return
- the caller does not need the post-operation state
- returning the aggregate would be artificial rather than intention-revealing

**Design test**: If the caller would naturally ask "what was created?", "what was updated?", or "what is the new state now?", returning `Unit` is a smell.

### 5. Clock Abstraction for Time

Never the system clock. Time is always injected, so it can be controlled — set the date to the
first of January and forecast, replay a month, freeze an instant. Test-driven development depends
on it.

**But an aggregate does not hold the Clock.** `functional-domain-constraints.md` is explicit that
an aggregate must not depend on repositories, buses, clocks or external services to decide facts.
The application layer holds the injected `Clock` and passes time in as a value; the aggregate
receives an instant, never a source of instants.

```kotlin
// BAD — the system clock, in the domain
class Order {
    fun place() = OrderPlaced(Instant.now())
}

// ALSO BAD — an injected service inside the aggregate, so the aggregate can decide when "now" is
class Order(private val clock: Clock) {
    fun place() = OrderPlaced(clock.now())
}

// GOOD — the application layer reads the injected Clock and supplies the value
class Order {
    fun place(at: Instant) = OrderPlaced(occurredAt = at)
}

class PlaceOrderHandler(private val clock: Clock) {
    fun handle(command: PlaceOrder) = order.place(at = clock.now())
}
```

*Amended 2026-08-26: the previous "GOOD" example injected a `Clock` into the aggregate, which
contradicts `functional-domain-constraints.md`. Both files agreed that the system clock is
forbidden; they disagreed about where the injected one lives. It lives in the application layer.*

### 6. Value Objects for Domain Primitives

```kotlin
@JvmInline
value class IdentityId(val value: UUID)

@JvmInline
value class DisplayName(val value: String) {
    init {
        require(value.length in 2..100) { "Display name must be 2-100 characters" }
    }
}
```

### 7. Sealed Classes for Domain Errors

```kotlin
sealed class IdentityError : DomainError {
    data class AlreadyActive(val identityId: IdentityId) : IdentityError()
    data class ClaimAlreadyAttached(val claimKey: ClaimKey) : IdentityError()
    data object CannotLockProspect : IdentityError()
}
```

### 8. Prefer Fold for Sequential Failure-Aware Processing

```kotlin
// AVOID - Manual recursion with explicit termination logic
private Either<Error, Result> processAll(List<Item> remaining, List<Output> accumulated)

// PREFERRED - Fold with Either accumulator
private Either<Error, Result> processAll(List<Item> items)
```

**Guideline**: When processing a collection sequentially where each step can fail and successful steps accumulate into a result, prefer `foldLeft`/`foldRight` with an `Either` accumulator over manual recursion.

**Reason**: Fold handles the empty case naturally, keeps the control flow declarative, and makes failure short-circuiting explicit through `flatMap`.

## Hexagonal Architecture Layers

Every bounded context has four distinct layers: domain, application,
integration, and infrastructure. Command/query definitions and their handlers
belong to the application layer; they never belong to the domain layer.

Two directory arrangements are permitted:

```
# Flat
domain/              <- Pure business logic, no framework dependencies
application/         <- Command/query handlers and use-case orchestration
integration/         <- External contracts and integration events
infrastructure/      <- HTTP, messaging, persistence, and other adapters
```

```
# Grouped (onion)
configuration/       <- Composition root
domain/              <- Inward region, not the domain layer itself
├── aggregates/      <- Domain layer: aggregates, value objects, domain events,
│                      repository interfaces, and pure business logic
└── application/     <- Application layer
    ├── commands/    <- Command definitions and handlers
    └── queries/     <- Query definitions and handlers

boundary/            <- Outward region
├── integration/     <- Integration layer: external contracts and integration events
└── infrastructure/  <- Infrastructure layer: HTTP, messaging, persistence adapters
```

`domain/` is a region in the grouped arrangement. The domain layer proper is
`domain/aggregates/`; its name must not be used to justify placing application
code under `domain/commands/` or `domain/queries/`.

`standards/architecture-enforcement-spec.md` is authoritative for structural
enforcement, dependency direction, and layer responsibility placement.

## Repository Placement Rule

Repository interfaces live in the domain layer.

They are colocated with the aggregate they manage,
or in an aggregate-local package directly organized around that aggregate.

They are defined using the ubiquitous language
of the owning bounded context.

They are not generic or shared.

Implementations live in infrastructure.

Repositories expose intent,
not generic data access.

Required rules:

- repository interfaces live in the domain layer
- repository interfaces are colocated with the aggregate they manage
- repository contracts are defined in ubiquitous language
- repository contracts are not generic or shared
- repository implementations live in infrastructure
- repository methods express business intent, not raw CRUD mechanics

Allowed example:

```kotlin
interface InvoiceRepository {
    fun loadInvoice(invoiceId: InvoiceId): Either<RepositoryError, Invoice>
    fun saveRejectedInvoice(invoice: Invoice): Either<RepositoryError, Invoice>
}
```

Avoid:

```kotlin
interface GenericRepository<T, ID> {
    fun findById(id: ID): T?
    fun save(entity: T): T
}
```

Putting repositories next to aggregates reinforces authority:

- aggregate owns its behavior
- aggregate owns its events
- aggregate defines how it is retrieved

Everything else is an implementation detail around that authority.

## Persistence Technology Default

Do not introduce JPA, Hibernate, or a relational database by default.

Prefer:
- in-memory implementations for tests and early modeling
- simple persistence adapters that preserve the domain model without ORM-driven shaping
- non-relational or file/document-style persistence when persistence is needed but relational requirements are not explicit

Avoid:
- introducing JPA entities, ORM mapping layers, or relational schema design as the default persistence choice
- designing aggregates around table structure, joins, or ORM lifecycle constraints
- adding PostgreSQL, MySQL, or similar relational infrastructure unless the requirement is explicit

**Rule**: Relational databases and JPA-style ORM are opt-in only. They may be used when explicitly requested or when relational constraints are a confirmed architectural requirement, not as a generated default.

**Reason**: Defaulting to relational persistence introduces accidental complexity, schema-driven modeling, and framework coupling too early. The domain model and repository ports should drive persistence, not the other way around.

## Integration Events vs Domain Events

Domain Events are internal to a bounded context and should never cross boundaries. Integration Events are for cross-BC communication and use business language rather than internal domain concepts.

```kotlin
// Domain Events - Internal to BC, never cross boundaries
// Use internal identifiers (IdentityId) and internal concepts (Claim, Prospect)
data class ProspectCreated(
    val identityId: IdentityId,
    override val correlationId: CorrelationId,
    override val eventId: EventId,
    override val occurredAt: Instant          // supplied by the caller from the injected Clock
) : DomainEvent

data class IdentityEnrolled(
    val identityId: IdentityId,
    val claimKey: ClaimKey,
    override val correlationId: CorrelationId,
    override val eventId: EventId,
    override val occurredAt: Instant
) : DomainEvent

// Integration Events - Cross BC communication, use business language
// Use external identifiers (UserId) and hide internal concepts
data class IdentityEstablished(
    val userId: UserId,           // External identifier, not internal IdentityId
    val username: String,         // Business term, not ClaimKey
    override val correlationId: CorrelationId,
    override val eventId: EventId,
    override val occurredAt: Instant
) : IntegrationEvent

data class UserLoggedOn(
    val userId: UserId,
    val displayName: String,
    override val correlationId: CorrelationId,
    override val eventId: EventId,
    override val occurredAt: Instant
) : IntegrationEvent
```

**Key Differences**:
- Domain Events use internal identifiers (`IdentityId`, `ClaimKey`)
- Integration Events use external identifiers (`UserId`, `username`)
- **Every** event carries a `correlationId` — domain and integration alike. It is not a cross-BC concern only; a trace that starts at the boundary and stops at the domain edge is not a trace
- Integration Events represent business milestones, not internal state changes
- Other BCs subscribe to Integration Events, never to Domain Events

**No event stamps its own time.** `occurredAt` is supplied by the caller from the injected
`Clock`; `Instant.now()` inside an event — including as a default argument — is the system clock
in the domain, and defeats the control over time that test-driven development depends on. You
cannot set the date to the first of January and forecast if the event reads the wall.

## Correlation Identity

Every event carries a correlation identity, and so does everything arriving at a boundary —
HTTP requests, API calls, consumed messages, scheduled triggers.

**Rule**:

- If an inbound request carries a correlation identity, it is **propagated unchanged**.
- If it does not, one is **minted at the edge** — never deeper.
- Every event raised while handling that request carries it, domain events included.
- A consumer that mints a fresh identity for work caused by an inbound fact breaks the trace at
  exactly the point tracing exists for.

**Reason**: a correlation identity restricted to integration events can only answer "which
contexts were involved". Carried on domain events too, it answers "what actually happened, in
what order, because of what" — which is the question asked when something has gone wrong.

## Publication Ordering

An aggregate generates events; it does not publish them. The application layer persists the new
state and publishes. The **order of those two acts is a decision**, and it must be made
deliberately rather than fallen into.

**Default: commit, then dispatch.** State is durable before anyone is told about it. Nothing is
announced that did not happen.

**Alternative: dispatch, then commit.** Chosen when throughput matters more than never losing an
event — the trade HTTP makes, flooding statelessly for speed and reconciling ordering later. It
accepts that an event may be published for a commit that then fails.

**Rule**: the choice is recorded per context, or per event where they differ, with the reason.
Neither is universally correct; what is forbidden is leaving it to whichever the implementer
happened to write first.

### Event Fact Typing Convention

Model event meaning explicitly as one of:

- Commitment fact: intent or reservation accepted
- Outcome fact: final business result became true

Example:

- `SlotReserved` (commitment)
- `ReservationConfirmed` (outcome)

Enforcement convention:

- Prefer naming-based classification and an event catalog over mandatory folder splits
- Keep one `events/` location unless scale requires further organization
- If split is needed, use `events/commitment/` and `events/outcome/` as an optional navigation aid
- Never require consumers to infer outcomes from commitments; publish explicit outcome facts

### Domain Event Placement Rule

Domain events live inside the bounded context that owns the model.

Within that bounded context,
domain events live next to the aggregate that emits them,
or in an aggregate-local package directly organized around that emitter.

Do not create a central domain `events/` folder
that becomes a shared semantic bucket for unrelated aggregates.

Why:

- a central events folder leads to semantic coupling
- reusing event classes across aggregates leads to model leakage
- aggregates emitting shared truths breaks authority boundaries

Required rules:

- domain events live inside the bounded context
- domain events live next to the aggregate that emits them
- domain events are not shared across aggregates or contexts
- domain events express local business facts only
- integration events are separate representations derived from domain events

Allowed example:

```kotlin
domain/
  invoice/
    Invoice.kt
    InvoiceRejected.kt
    InvoiceApproved.kt
```

Avoid:

```kotlin
domain/
  events/
    Approved.kt
    Rejected.kt
    StatusChanged.kt
```

The aggregate owns the meaning of its domain events.
Other aggregates and other bounded contexts must not treat them
as reusable shared truth objects.

If another bounded context needs to react,
publish a separate integration event through the integration layer.

## AndJoin Pattern

The AndJoin pattern is used when multiple conditions must ALL be met to trigger a final event. The conditions can be satisfied in any order - whichever comes last triggers the final event.

```kotlin
// AndJoin: Multiple conditions must ALL be met to trigger final event
// Used in Identity enrollment: claim + persona + verified channel = enrolled
class Identity private constructor(
    // ...
    private var _personaAttached: Boolean = false,
    private var _channelVerified: Boolean = false,
    private var _established: Boolean = false,
    // ...
) {
    fun activateWithClaim(claimKey: ClaimKey): Either<IdentityError, Unit> {
        // ... activate logic ...
        checkAndRaiseEstablished()
        return Unit.right()
    }

    fun attachPersona(): Either<IdentityError, Unit> {
        _personaAttached = true
        checkAndRaiseEstablished()
        return Unit.right()
    }

    fun attachVerifiedChannel(): Either<IdentityError, Unit> {
        _channelVerified = true
        checkAndRaiseEstablished()
        return Unit.right()
    }

    /**
     * AndJoin check: when claim + persona + verified channel are ALL attached,
     * raise IdentityEnrolled.
     *
     * The order doesn't matter - whichever comes last triggers enrollment.
     */
    private fun checkAndRaiseEstablished() {
        val hasClaimAttached = attachedClaims.isNotEmpty()

        if (hasClaimAttached && _personaAttached && _channelVerified && !_established) {
            _established = true
            domainEvents.add(IdentityEnrolled(identityId, attachedClaims.first()))
        }
    }
}
```

**Use Cases**:
- Identity establishment (claim + persona + verified channel)
- Order fulfillment (payment confirmed + items shipped)
- Document approval (all required signatures received)

## Server-Authoritative State

UI updates when the SERVER confirms an action, not optimistically. The server pushes state changes to browsers via WebSocket.

```kotlin
// BFF subscribes to auth events and broadcasts to connected browsers
class BffModule(private val eventBus: EventBus) {
    private val authStateBroadcaster = AuthStateBroadcaster()

    init {
        // Subscribe to auth events and broadcast to connected browsers
        eventBus.subscribe(UserLoggedOn::class.java) { event ->
            authStateBroadcaster.broadcastLogin(event.userId.value, event.displayName)
        }

        eventBus.subscribe(UserLoggedOff::class.java) { event ->
            authStateBroadcaster.broadcastLogout(event.userId.value)
        }
    }
}

// AuthStateBroadcaster pushes to all connected WebSocket clients
class AuthStateBroadcaster {
    fun broadcastLogin(identityId: String, displayName: String) {
        val message = """{"type":"LOGIN","identityId":"$identityId","displayName":"$displayName"}"""
        // Send to all connected WebSocket sessions
        userConnections[identityId]?.forEach { session -> session.send(message) }
        anonymousConnections.forEach { session -> session.send(message) }
    }

    fun broadcastLogout(identityId: String) {
        val message = """{"type":"LOGOUT","identityId":"$identityId"}"""
        userConnections[identityId]?.forEach { session -> session.send(message) }
    }
}
```

**Benefits**:
- UI is always in sync with server state
- Multi-tab synchronization (logout in one tab updates all tabs)
- Session expiration handling (server can push logout)
- No optimistic updates that need rollback on failure

## Naming Conventions

### Files
- Aggregate: `{AggregateName}.kt` (e.g., `Identity.kt`)
- Value Objects: `ValueObjects.kt` per aggregate
- Commands: `{Context}Commands.kt` (e.g., `IdentityCommands.kt`)
- Events: `{Context}Events.kt`
- Integration Events: `{Context}IntegrationEvents.kt` (in `domain/integration/`)
- Module Config: `{Context}Module.kt`

### Classes
- Aggregate Errors: `{Aggregate}Error` sealed class
- Commands: Verb-noun (e.g., `CreateIdentityProspect`, `RegisterIdentity`)
- Events: Past tense (e.g., `IdentityProspectCreated`, `IdentityActivated`)
- Events: Never use a bare noun as an event name; prefer explicit facts like `AppointmentScheduled` or `AppointmentCreated`
- Integration Events: Business milestone language (e.g., `UserLoggedOn`, `IdentityEstablished`)
- Query: Imperative (e.g., `PresentSignUpActorTypes`)
- Event semantics: make commitment vs outcome explicit in the event name

### Test Prefixes
- Expected values: `expectedEvent`, `expectedResult`
- Fixed time: `fixedTime`, `testClock`

## CQRS Pattern

```kotlin
// Command - changes state
data class CreateAdvertisement(
    val profileId: AdvertisementId,
    val providerId: ProviderId,
    val displayName: DisplayName,
    val description: Description
)

// Query - reads state
data class GetAdvertisementById(val id: AdvertisementId)

// Handlers separate from domain
class AdvertisementCommandHandler(
    private val repository: AdvertisementRepository,
    private val eventBus: EventBus
) {
    fun handle(command: CreateAdvertisement): Either<CommandError, Advertisement>
}
```

## Event-Driven Design

When a command emits a fact that is supposed to keep UI state, read models,
or cross-context reactions consistent, implement the reaction in the same slice.
The command entrypoint and its event listener/projector should be registered together
by module composition and verified together by tests.

Do not make aggregates aware of listeners, and do not invent local events just
to satisfy structure. The pairing rule applies only when there is real derived
state or a real reaction to own.

```kotlin
// Aggregate records events
class Identity private constructor(...) {
    private val _events = mutableListOf<DomainEvent>()
    val events: List<DomainEvent> get() = _events.toList()

    fun clearEvents() = _events.clear()

    fun activate(): Either<IdentityError, Identity> {
        // ... logic
        _events.add(IdentityActivated(id, clock.now()))
        return this.right()
    }
}

// Handler publishes events after persistence
fun handle(command: ActivateIdentity): Either<Error, Identity> {
    return repository.findById(command.id)
        .flatMap { it.activate() }
        .onRight { identity ->
            repository.save(identity)
            identity.events.forEach { eventBus.publish(it) }
            identity.clearEvents()
        }
}
```

Practical guard:

- If a command claims to update event-derived state, its listener/projector must exist.
- If no listener/projector exists, either the command is incomplete or the state is not truly event-derived.
- If the event carries no real business fact, remove the event and wire the local dependency explicitly.

## Module Boundaries

- **No circular dependencies** between bounded contexts
- **Event-based communication** between modules (via Integration Events)
- **SharedKernel**: Only domain primitives (`DomainEvent`, `IntegrationEvent`, `DomainError`, `Clock`, `UserId`)
- **Platform**: Shared infrastructure (`EventBus`, `WidgetProvider`, `EmailService`)

## Testing

- Use `FixedClock` for deterministic time
- Use in-memory repositories
- Prefix expected values with `expected`
- Test domain logic in isolation from infrastructure

```kotlin
@Test
fun `should enroll identity when all conditions are met`() {
    val fixedTime = Instant.parse("2024-01-01T10:00:00Z")
    val testClock = FixedClock(fixedTime)

    val identity = Identity.createAsProspect(ActorType.Provider).getOrNull()!!
    identity.activateWithClaim(ClaimKey.of("test@example.com", ClaimType.Email))
    identity.attachPersona()
    identity.attachVerifiedChannel()

    val expectedEvent = identity.pullDomainEvents().filterIsInstance<IdentityEnrolled>().first()

    assertTrue(identity.isEstablished)
    assertEquals(identity.identityId, expectedEvent.identityId)
}
```
