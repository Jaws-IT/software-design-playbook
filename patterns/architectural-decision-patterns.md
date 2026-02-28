# ARCHITECTURAL DECISION PATTERNS

*Version: 1.0 | Last Updated: January 22, 2026 | Strategic Decision Framework*

## Summary

### Core Architectural Principles
- **Testing Strategy Hierarchy** - Unit tests for logic, monitoring for production
- **Separation of Concerns in Testing** - Business logic vs operational reliability
- **Architectural Economics** - Coupling cost vs compute cost analysis
- **Infrastructure Boundary Pattern** - Platform BC for composition without coupling
- **Premature Optimization Warning** - Don't optimize for invisible problems
- **Operational Confidence** - You cannot test your way to production confidence

### Key Decision Frameworks
- **What to Test Where** - Business behavior, adapter contracts, production reliability
- **When to Use Platform BC** - Caching and composition as infrastructure concerns
- **Coupling vs Compute Trade-offs** - Hidden organizational costs vs visible infrastructure costs
- **Strategic Design Validation** - Apply mental models from patterns/strategic-design-patterns.md

---

## Architectural Decision Process

Before committing to any architectural decision, validate it using the strategic design patterns from **patterns/strategic-design-patterns.md**:

### The Validation Checklist

Every architectural decision should pass these validation tests:

1. **Extremefy** (patterns/strategic-design-patterns.md)
   - What happens with 1000x more load/data/concurrency?
   - Does the design break? Is that acceptable?
   - Example: Sequential processing of 10 items works; 1000 items reveals bottleneck

2. **Complexity Must Earn Its Keep** (patterns/strategic-design-patterns.md)
   - Can you explain the benefit in one sentence?
   - Have you measured the problem this complexity solves?
   - Would simpler code work?
   - Example: Caching adds complexity - is latency actually a measured problem?

3. **Aggregate Transaction Boundary** (patterns/strategic-design-patterns.md)
   - Are multiple aggregates updated in one transaction?
   - Do they share invariants that require atomic updates?
   - Should this be a saga instead?
   - Example: Order + Payment + Inventory in one transaction = coupling

4. **Validation Belongs in Operations** (patterns/strategic-design-patterns.md)
   - Is validation separate from state-changing operation?
   - What is the validation FOR?
   - Can race conditions occur between validate and create?

5. **Clock Abstraction** (patterns/strategic-design-patterns.md)
   - Does business logic depend on `Instant.now()`?
   - Is this making tests non-deterministic?
   - Should time be injected as a Clock dependency?

### Decision Process Flow

```
Architectural Decision Proposed
│
├─ Apply Extremefy
│   ├─ Scales well → Continue
│   └─ Breaks at scale → Is scale realistic?
│       ├─ Yes → Redesign
│       └─ No → Document limit, Continue
│
├─ Apply Complexity Test
│   ├─ Benefit clear & measured → Continue
│   └─ Benefit unclear → Remove complexity, Simplify
│
├─ Check Transaction Boundaries
│   ├─ Single aggregate → Continue
│   └─ Multiple aggregates → Redesign as saga
│
├─ Check Validation Strategy
│   ├─ Validation in operation → Continue
│   └─ Separate validation → Combine with operation
│
└─ Check Time Dependencies
    ├─ Clock abstraction used → Approve
    └─ Direct time calls → Refactor to Clock
```

### Example: Applying the Checklist

**Proposed Decision**: "Create denormalized cache for Order Details view to avoid HTTP calls"

**Validation**:

**1. Extremefy**:
- Current: 5 HTTP calls per request
- 1000x: Still 5 HTTP calls per request
- With parallel execution: ~50-150ms total
- ✅ Design scales fine without cache

**2. Complexity Test**:
- Benefit: "Faster response times"
- Measured? "No, we haven't measured actual latency"
- Simpler alternative? "Yes, parallel composition with local cache"
- ❌ Complexity doesn't earn its keep yet - measure first

**3. Transaction Boundaries**:
- N/A - this is a read operation
- ✅ No transaction coupling

**4. Validation**:
- N/A - not a validation scenario
- ✅ Not applicable

**5. Time Dependencies**:
- Cache uses TTL based on current time
- Should use Clock abstraction for testability
- ⚠️ Minor issue - fix before implementing

**VERDICT**: Don't implement denormalized cache yet. Start with parallel composition + local cache, measure, then optimize only if evidence demands it.

---

## Testing Strategy Principles

### The Fundamental Separation

Different concerns require different verification strategies:

| Concern | Verification Strategy | Tools |
|---------|----------------------|-------|
| **Business logic correctness** | Unit tests | In-memory implementations, fast tests |
| **Adapter contracts** | 1-2 integration tests | Real external systems (smoke tests) |
| **Production reliability** | Monitoring & observability | Metrics, alerts, health checks |
| **System capacity** | Load testing | Performance testing tools |
| **Failure recovery** | Chaos engineering | Runbooks, disaster recovery |

### The Category Error

**Common Mistake**: Trying to use code tests to gain operational confidence.

```kotlin
// ❌ This integration test doesn't prove production works
@Test
fun `session survives in Redis`() {
    val redis = RedisClient.connect("localhost:6379")
    val repo = RedisSessionRepository(redis)
    
    repo.save(session)
    
    assertEquals(session, repo.findById(session.id))
}

// This STILL doesn't prove production works because:
// - Production Redis might be misconfigured
// - Network might fail
// - Redis might run out of memory
// - Connection pool might be exhausted under load
// - Ops team might have different TTL settings
```

**The Truth**: You cannot test your way to production confidence.

### Business Requirements vs Architectural Decisions

**Example Business Requirement**: 
"If I'm logged in successfully and haven't actively logged out, when revisiting my account, I should not need to login."

This requirement implies **session durability** - sessions must survive server restarts.

**Testing Misconception**: "We need an in-memory database to unit test this."

**Reality**: You're testing behavior, not persistence technology.

The business requirement breaks down into testable behaviors:
1. Login creates a session → Unit testable
2. Valid session grants access → Unit testable
3. Logout invalidates session → Unit testable
4. Expired sessions are rejected → Unit testable

**None of these require testing "does Redis survive a restart?" - that's Redis's job, not yours.**

### The Clean Architecture Approach to Testing

```kotlin
// ✅ Domain contract - defines WHAT, not HOW
interface SessionRepository {
    fun save(session: Session)
    fun findById(sessionId: SessionId): Session?
    fun delete(sessionId: SessionId)
}

// ✅ In-memory for tests - satisfies the contract
class InMemorySessionRepository : SessionRepository {
    private val sessions = mutableMapOf<SessionId, Session>()
    
    override fun save(session: Session) { 
        sessions[session.id] = session 
    }
    
    override fun findById(sessionId: SessionId) = sessions[sessionId]
    
    override fun delete(sessionId: SessionId) { 
        sessions.remove(sessionId) 
    }
}

// ✅ Redis for production - also satisfies the contract
class RedisSessionRepository(private val redis: RedisClient) : SessionRepository {
    override fun save(session: Session) {
        redis.set(session.id.value, session.toJson(), Duration.ofHours(24))
    }
    
    override fun findById(sessionId: SessionId): Session? {
        return redis.get(sessionId.value)?.let { json -> Session.fromJson(json) }
    }
    
    override fun delete(sessionId: SessionId) {
        redis.delete(sessionId.value)
    }
}
```

**The Key Insight**: 

The requirement "session survives restart" is satisfied by choosing the right infrastructure - it's a **deployment decision**, not a code behavior. 

Your code doesn't know or care whether sessions survive restarts. It just calls `repository.findById()` and either gets a session or doesn't.

```kotlin
// ✅ This logic is IDENTICAL regardless of persistence
class AuthenticationService(
    private val sessionRepository: SessionRepository
) {
    fun validateSession(
        sessionId: SessionId, 
        clock: Clock
    ): Either<AuthError, Session> {
        val session = sessionRepository.findById(sessionId)
            ?: return Either.Left(AuthError.SessionNotFound)
        
        if (session.isExpired(clock)) {
            return Either.Left(AuthError.SessionExpired)
        }
        
        return Either.Right(session)
    }
}
```

**Unit test with InMemorySessionRepository. Deploy with RedisSessionRepository. Same code, same behavior, different durability guarantees.**

### What Gets Tested Where

| Concern | Test Type | What You're Verifying |
|---------|-----------|----------------------|
| "Login creates session" | Unit test | Business logic calls repository.save() |
| "Valid session grants access" | Unit test | Business logic correctly uses repository.findById() result |
| "Expired sessions rejected" | Unit test | Business logic checks expiration correctly |
| "Session survives restart" | Not a code test | Infrastructure choice (Redis vs in-memory) |
| "Redis adapter works correctly" | Integration test (1-2 smoke tests) | Your code talks to Redis properly |

### The Pragmatic Testing Strategy

**For any external system adapter (Redis, PostgreSQL, Kafka, etc.):**

1. **Unit test all business logic** with in-memory implementations
2. **One smoke test** that verifies basic adapter functionality
3. **Comprehensive monitoring** for production reliability

```kotlin
// ✅ The ONE integration test you need
@IntegrationTest
fun `can round-trip a session through Redis`() {
    // This catches:
    // - Serialization bugs
    // - TTL configuration issues
    // - Basic connectivity
    
    val session = createTestSession()
    
    repository.save(session)
    val retrieved = repository.findById(session.id)
    
    assertEquals(session, retrieved)
}
```

**That's it. One test.**

Not because we're lazy, but because additional integration tests don't provide proportional confidence.

### Gaining Production Confidence

**Wrong Question**: "How do we test that Redis works?"

**Right Question**: "If Redis fails in production, how will we know?"

**The Answer** (never "our integration tests will catch it"):
- Health checks on Redis connectivity
- Metrics dashboards (latency, error rates, cache hit rates)
- Alerting on session lookup failures
- Distributed tracing
- Log aggregation

```kotlin
// ✅ Production confidence through observability
class MonitoredSessionRepository(
    private val delegate: SessionRepository,
    private val metrics: MetricsService
) : SessionRepository {
    override fun findById(sessionId: SessionId): Session? {
        val startTime = System.currentTimeMillis()
        
        return try {
            delegate.findById(sessionId).also { session ->
                val latency = System.currentTimeMillis() - startTime
                
                metrics.record("session.lookup.latency", latency)
                metrics.increment("session.lookup.success")
                
                if (session == null) {
                    metrics.increment("session.lookup.not_found")
                }
            }
        } catch (e: Exception) {
            metrics.increment("session.lookup.error")
            logger.error("Session lookup failed", e)
            throw e
        }
    }
}
```

### Explaining to Skeptical Developers

**Developer Objection**: "Unit tests with in-memory repositories don't prove it works in production."

**Response**: "That's correct. But integration tests don't prove it either. Integration tests verify our code talks to Redis correctly - they run once in CI against a test Redis. Production reliability comes from monitoring - we observe real traffic against real Redis. These are different concerns. We can't integration-test our way to production confidence, so we invest our effort where it matters: fast unit tests for logic, minimal integration tests for adapters, and comprehensive monitoring for production."

### When Would You Write More Integration Tests?

**Only if** you're uncertain your adapter correctly implements the contract. But typically:

- **In-memory implementations**: Trust them (trivial code)
- **Redis/PostgreSQL/Kafka**: Trust the library/driver works
- **Your adapter code**: 1-2 smoke tests to catch serialization bugs

**Don't waste time** writing integration tests that verify Redis works. Redis already has tests.

---

## Architectural Economics

### The Hidden Cost Trade-off

Every architectural decision involves trade-offs. The most important trade-off is often invisible:

**Coupling Cost vs Compute Cost**

### Coupling Cost (Hidden & Expensive)

```
┌─────────────────────────────────────────────────────────────┐
│                     COUPLING COST                           │
├─────────────────────────────────────────────────────────────┤
│ • Team coordination overhead (meetings, Slack, waiting)     │
│ • Contract management (versioning, documentation)           │
│ • Breaking change impact (bugs, hotfixes, rollbacks)        │
│ • Deployment coupling (coordinated releases)                │
│ • Cognitive load (devs must understand other domains)       │
│ • Testing complexity (cross-BC integration tests)           │
│ • Slower feature velocity (dependencies block work)         │
│                                                             │
│ These costs are INVISIBLE in your cloud bill                │
│ But they show up in: slower delivery, more bugs, friction   │
└─────────────────────────────────────────────────────────────┘
```

**Key Characteristics:**
- **Not measurable** in traditional metrics
- **Scales non-linearly** with team size
- **Compounds over time**
- **Shows up as** missed deadlines, team friction, burnout

### Compute Cost (Visible & Cheap)

```
┌─────────────────────────────────────────┐
│          COMPUTE COST                   │
├─────────────────────────────────────────┤
│ • HTTP calls = clock cycles = $$        │
│ • Network latency                       │
│ • Infrastructure for composition layer  │
│                                         │
│ These costs are VISIBLE and measurable  │
└─────────────────────────────────────────┘
```

**Key Characteristics:**
- **Directly measurable** in cloud bills
- **Scales linearly** with load
- **Decreasing over time** (Moore's Law)
- **Optimizable** without organizational change

### The Hidden Truth

**Organizational costs scale non-linearly with team size. Compute costs scale linearly and are decreasing.**

```kotlin
// Example: Optimizing for compute cost
// Creates coupling cost that's 10x more expensive

// ❌ Denormalized cache to save HTTP calls
class OrderDetailsCache {
    // Duplicates data from:
    // - Order BC
    // - Customer BC
    // - Product BC
    // - Pricing BC
    // - Shipping BC
    
    // Now all these teams are coupled:
    // - Schema changes require coordination
    // - Cache invalidation is complex
    // - Tests require all services
    // - Deployments must be coordinated
}

// ✅ Composed view with local caching
class OrderDetailsView {
    suspend fun getOrderDetails(orderId: OrderId): OrderDetails {
        return coroutineScope {
            val order = async { orderService.getOrder(orderId) }
            val customer = async { customerService.getCustomer(order.customerId) }
            val products = async { productService.getProducts(order.productIds) }
            
            // Compose from autonomous services
            // Each team deploys independently
            // Local cache if needed for performance
            composeOrderDetails(order.await(), customer.await(), products.await())
        }
    }
}
```

### Decision Framework: When Does Each Cost Win?

**Coupling Cost Wins (Most Cases):**
- Multiple teams
- Frequent schema evolution
- High developer cost (expensive engineers)
- Need for independent deployability
- Long-lived system (multi-year)
- Complex domain requiring specialization

**Compute Cost Wins (Rare Cases):**
- Extreme scale (millions of requests/second)
- Single team owns everything anyway
- Schemas are truly stable (rare!)
- Latency-critical paths where milliseconds matter
- Short-lived tactical solutions

### Real-World Example: E-Commerce Order Details

**Scenario**: Display order details page showing order, customer, products, pricing, shipping.

**Option 1: Platform BC with Cached Composition**
```kotlin
// ❌ Optimizing for compute cost
// Creates invisible coupling cost

// Platform BC maintains denormalized view
class OrderDetailsProjection {
    // Subscribes to events from 5 different BCs
    // Maintains synchronized cache
    // All teams now coupled through this projection
    
    // Coupling costs:
    // - Schema changes need coordination across 5 teams
    // - Event ordering issues cause data inconsistency
    // - Tests require all 5 services running
    // - Deployment coordination required
    // - Troubleshooting requires understanding 5 domains
}

// Compute savings: 4 HTTP calls eliminated per request
// Coupling cost: 5 teams now coupled, slower delivery, more bugs
```

**Option 2: View Composition with Local Caching**
```kotlin
// ✅ Optimizing for coupling cost
// Accepts compute cost

class OrderDetailsService {
    suspend fun getOrderDetails(orderId: OrderId): OrderDetails {
        // Parallel composition - fast enough
        return coroutineScope {
            val order = async { getOrderWithCache(orderId) }
            val customer = async { getCustomerWithCache(order.customerId) }
            val products = async { getProductsWithCache(order.productIds) }
            val pricing = async { getPricingWithCache(order.pricingId) }
            val shipping = async { getShippingWithCache(order.shippingId) }
            
            compose(
                order.await(),
                customer.await(), 
                products.await(),
                pricing.await(),
                shipping.await()
            )
        }
    }
    
    // Local cache per service - no coupling
    private suspend fun getOrderWithCache(id: OrderId): Order {
        return cache.getOrPut("order:$id", ttl = 5.minutes) {
            orderService.getOrder(id)
        }
    }
}

// Compute cost: 5 HTTP calls per request (but parallel, fast)
// Coupling cost: Zero - each team fully autonomous
// Reality: Fast enough for most use cases, infinitely maintainable
```

**Analysis:**

- **Response time**: Option 2 with parallel calls + cache is typically 50-150ms - acceptable
- **Cost per request**: Maybe $0.0001 more for HTTP calls
- **Team velocity**: Option 2 teams can deploy anytime, independently
- **Maintenance cost**: Option 2 requires zero coordination
- **Long-term cost**: Coupling cost dominates over time

**The answer is clear: Option 2 wins** unless you're at extreme scale (Google/Amazon level).

---

## The Platform BC Pattern

### The Sweet Spot

The Platform BC pattern separates infrastructure concerns (composition, caching) from domain concerns (business logic).

```
┌────────────────────────────────────────────────────┐
│                 Platform BC                        │
│      (Infrastructure concern, NOT domain logic)    │
│                                                    │
│  • Owns the composition logic                      │
│  • Owns the cache (if needed)                      │
│  • Exposes view contracts                          │
│  • Teams can optimize HERE without coupling        │
└────────────────────────────────────────────────────┘
         │              │              │
         ▼              ▼              ▼
    Order BC      Customer BC     Product BC
    (Domain)       (Domain)        (Domain)
```

**Key Principle**: The Platform BC doesn't duplicate domain logic. It only handles cross-cutting infrastructure concerns.

```kotlin
// ✅ Platform BC - composition only, no domain logic
class OrderViewPlatform {
    suspend fun getOrderDetails(orderId: OrderId): OrderDetailsView {
        // Composition logic lives here
        // Caching strategy lives here
        // Domain logic stays in BCs
        
        return coroutineScope {
            val order = async { orderBC.getOrder(orderId) }
            val customer = async { customerBC.getCustomer(order.customerId) }
            
            OrderDetailsView(
                order = order.await(),
                customer = customer.await()
            )
        }
    }
}

// ❌ Platform BC that duplicates domain logic
class BadOrderViewPlatform {
    suspend fun getOrderDetails(orderId: OrderId): OrderDetailsView {
        val order = cache.get(orderId)
        
        // ❌ Domain logic leaked into platform!
        if (order.isPremiumCustomer()) {
            applyPremiumDiscounts(order)
        }
        
        // Now two places have pricing logic - coupling!
        return OrderDetailsView(order)
    }
}
```

### When to Use Platform BC

**Use Platform BC When:**
- Multiple consumers need the same composed view
- Caching strategy is complex and shared
- Infrastructure optimization is needed (CDN, compression)
- View composition logic is non-trivial
- You want to isolate view changes from domain BCs

**Don't Use Platform BC When:**
- Only one consumer needs the view (compose directly)
- Composition is simple (2-3 parallel calls)
- Each BC is already optimized
- You're prematurely optimizing

### Platform BC Guidelines

```kotlin
// ✅ Good Platform BC
class OrderPlatform {
    // ONLY infrastructure concerns
    
    suspend fun getOrderDetails(orderId: OrderId): OrderDetailsView {
        // Composition
        return compose(
            orderBC.getOrder(orderId),
            customerBC.getCustomer(...),
            productBC.getProducts(...)
        )
    }
    
    // Caching
    private val cache = LocalCache<OrderId, OrderDetailsView>(ttl = 5.minutes)
    
    // Monitoring
    private fun recordMetrics(operation: String, latency: Duration) { ... }
}

// ❌ Bad Platform BC
class BadOrderPlatform {
    suspend fun getOrderDetails(orderId: OrderId): OrderDetailsView {
        val order = orderBC.getOrder(orderId)
        
        // ❌ Business rule leaked into platform!
        if (order.total > Money(1000)) {
            order.applyVolumeDiscount()  // Domain logic!
        }
        
        return order.toView()
    }
}
```

---

## Premature Optimization Warning

### The Core Principle

**Don't prematurely optimize views just because you fear HTTP call overhead.**

Most view composition performance concerns are premature optimization based on incorrect assumptions.

### Common Wrong Assumptions

```kotlin
// ❌ Assumption: "Multiple HTTP calls are slow"
// Reality: Parallel async calls are fast enough

// This takes ~100ms with parallel execution
suspend fun getOrderDetails(orderId: OrderId): OrderDetails = coroutineScope {
    val order = async { orderService.getOrder(orderId) }        // 30ms
    val customer = async { customerService.getCustomer(...) }   // 40ms
    val products = async { productService.getProducts(...) }    // 50ms
    
    compose(order.await(), customer.await(), products.await())
}
// Total: 50ms (longest call), not 120ms (sum)
```

```kotlin
// ❌ Assumption: "We need a denormalized cache"
// Reality: Local caching + parallel is fast enough

// With local cache, second request is ~5ms
suspend fun getOrderDetailsWithCache(orderId: OrderId): OrderDetails {
    return cache.getOrPut("order:$orderId", ttl = 5.minutes) {
        getOrderDetails(orderId)  // Only called on cache miss
    }
}
```

```kotlin
// ❌ Assumption: "Compute cost will kill us"
// Reality: Coupling cost kills you first

// Compute cost: $0.0001 per request × 1M requests = $100/month
// Coupling cost: 2 weeks slower delivery = $50,000+ in opportunity cost
```

### When to Actually Optimize

**Optimize When** you have measured evidence of:
- P99 latency > 500ms causing user drop-off
- Cloud costs > $10K/month on HTTP calls alone
- Scale > 1M requests/second
- Business impact from slow responses

**Don't Optimize When**:
- You haven't measured anything yet
- Latency is < 200ms
- You're still building the feature
- Teams are not yet autonomous

### The Optimization Decision Tree

```
Is latency causing business impact?
│
├─ NO → Don't optimize, focus on features
│
└─ YES → Is it measured and significant?
    │
    ├─ NO → Measure first
    │
    └─ YES → Is it the HTTP calls?
        │
        ├─ NO → Optimize the actual bottleneck
        │
        └─ YES → Try these IN ORDER:
            │
            ├─ 1. Parallel execution (fastest to implement)
            ├─ 2. Local caching (per-service)
            ├─ 3. CDN/edge caching (for static content)
            ├─ 4. Platform BC with shared cache
            └─ 5. Denormalized projections (last resort)
```

### Real-World Example: Premature Optimization

**Scenario**: Team wants to create denormalized "Arrangement" view cache because "too many HTTP calls."

```kotlin
// ❌ Premature optimization
// Created before measuring actual performance

class ArrangementViewCache {
    // Duplicates data from 8 different BCs:
    // - Account BC
    // - Product BC
    // - Customer BC
    // - Transaction BC
    // - Balance BC
    // - Interest BC
    // - Fee BC
    // - Statement BC
    
    // Coupling cost:
    // - 8 teams now need to coordinate
    // - Event synchronization nightmare
    // - Schema evolution blocked
    // - Testing requires 8 services
    
    // Compute cost saved:
    // - 7 HTTP calls eliminated
    // - Savings: $0.0001 per request
}

// ✅ Start simple, measure, then optimize
class ArrangementViewService {
    suspend fun getArrangement(id: ArrangementId): ArrangementView = coroutineScope {
        // Start with parallel composition
        val account = async { accountService.get(id.accountId) }
        val product = async { productService.get(id.productId) }
        val customer = async { customerService.get(id.customerId) }
        // ... other calls in parallel
        
        compose(account.await(), product.await(), customer.await(), ...)
    }
    
    // Measure actual performance
    // If P99 > 500ms, THEN add local cache
    // If still slow, THEN consider shared cache
    // If still slow, THEN consider denormalization
}
```

**Outcome**: 
- Parallel composition: 150ms (acceptable)
- Local cache added later: 10ms on hits
- Total cost: Zero coupling, full autonomy
- Denormalized cache: Never needed

---

## Decision Guidelines Summary

### Testing Strategy

| Situation | Solution |
|-----------|----------|
| Business logic with external dependency | Use repository interface, unit test with in-memory |
| Need to verify adapter works | 1-2 integration smoke tests |
| Need production confidence | Monitoring, alerting, observability |
| Need to verify system handles load | Load testing, capacity planning |
| Need to verify system recovers | Chaos engineering, runbooks |

### Caching Strategy

| Situation | Solution |
|-----------|----------|
| Single consumer, simple composition | Compose directly, no cache |
| Multiple consumers, stable data | Local cache per service |
| High read load, stable data | Platform BC with shared cache |
| Complex composition logic | Platform BC (composition only) |
| Need for infrastructure optimization | Platform BC (CDN, compression) |
| Extreme scale (1M+ req/sec) | Consider denormalization (last resort) |

### Cost Trade-offs

| Factor | Favor Coupling Cost | Favor Compute Cost |
|--------|-------------------|-------------------|
| Team size | Multiple teams | Single team |
| Schema stability | Frequent changes | Truly stable |
| Developer cost | High ($$$) | Low |
| System scale | < 100K req/sec | > 1M req/sec |
| System lifetime | Multi-year | Short-lived |
| Time to market | Critical | Not critical |

### The Default Position

**When in doubt:**
1. Start with autonomous bounded contexts
2. Use parallel composition with local caching
3. Measure actual performance impact
4. Optimize only when evidence demands it
5. Prefer coupling cost over compute cost
6. **Validate using strategic design patterns** (see patterns/strategic-design-patterns.md)

**Remember**: 
- Coupling costs are invisible but dominant
- Compute costs are visible but decreasing
- Organizational friction compounds over time
- Infrastructure scales linearly
- **Apply Extremefy, Complexity Test, and other mental models before committing to design**

---

## Practical Examples

### Example 1: Session Management

**Requirement**: Sessions must survive server restarts.

**Wrong Approach**: Write integration tests proving Redis survives restarts.

**Right Approach**:
```kotlin
// 1. Unit tests for business logic
class AuthenticationServiceTest {
    private val repository = InMemorySessionRepository()
    private val service = AuthenticationService(repository)
    
    @Test
    fun `valid session grants access`() {
        val session = Session.create(userId, clock)
        repository.save(session)
        
        val result = service.validateSession(session.id, clock)
        
        assertThat(result).isSuccess()
    }
}

// 2. One smoke test for Redis adapter
@IntegrationTest
fun `can round-trip session through Redis`() {
    val session = Session.create(userId, clock)
    
    redisRepository.save(session)
    val retrieved = redisRepository.findById(session.id)
    
    assertEquals(session, retrieved)
}

// 3. Production monitoring
class MonitoredSessionRepository(
    private val delegate: SessionRepository,
    private val metrics: MetricsService
) : SessionRepository {
    override fun findById(sessionId: SessionId): Session? {
        return measureLatency("session.lookup") {
            delegate.findById(sessionId)
        }
    }
}
```

### Example 2: Order Details View

**Requirement**: Display order with customer, products, pricing, shipping.

**Wrong Approach**: Create denormalized cache to avoid HTTP calls.

**Right Approach**:
```kotlin
// Start simple - parallel composition
class OrderDetailsService {
    suspend fun getDetails(orderId: OrderId): OrderDetails = coroutineScope {
        async { orderService.get(orderId) }.await() to
        async { customerService.get(customerId) }.await() to
        async { productsService.get(productIds) }.await()
        // Compose results
    }
}

// Add local cache only if measured latency is too high
class CachedOrderDetailsService(
    private val delegate: OrderDetailsService,
    private val cache: Cache<OrderId, OrderDetails>
) {
    suspend fun getDetails(orderId: OrderId): OrderDetails {
        return cache.getOrPut(orderId, ttl = 5.minutes) {
            delegate.getDetails(orderId)
        }
    }
}

// Platform BC only if multiple consumers need same view
class OrderPlatform {
    suspend fun getOrderDetails(orderId: OrderId): OrderDetailsView {
        // Composition + caching
        // NO domain logic
        // Just infrastructure optimization
    }
}
```

### Example 3: Cost Analysis

**Scenario**: Team proposes denormalized cache for "Arrangements" to save on HTTP calls.

**Analysis**:
```
Compute Cost Savings:
- 7 HTTP calls eliminated per request
- Cost per call: ~$0.00001
- Savings: $0.00007 per request
- At 1M requests/month: $70/month

Coupling Cost Added:
- 8 teams need coordination
- 1 day/month in meetings: $10,000/month in eng time
- 2 week delay in schema changes: $100,000 in opportunity cost
- Increased bug rate: $50,000/year in fixes
- Slower feature delivery: Immeasurable

Verdict: Coupling cost is 100x+ higher than compute cost savings.
```

**Decision**: Use parallel composition with local caching instead.

---

## Anti-Patterns to Avoid

### Testing Anti-Patterns

❌ **Over-Integration Testing**
```kotlin
// Writing 50 integration tests to prove Redis works
// Redis already has tests - you're wasting time
```

❌ **Testing Infrastructure Instead of Behavior**
```kotlin
// Testing that database persists data
// Database's job - not yours
```

❌ **Using Tests for Operational Confidence**
```kotlin
// Trying to test that production won't fail
// Impossible - use monitoring instead
```

### Optimization Anti-Patterns

❌ **Premature Denormalization**
```kotlin
// Creating denormalized cache before measuring performance
// Optimizing for invisible problem, creating real coupling cost
```

❌ **Optimizing for Compute Cost Over Coupling Cost**
```kotlin
// Saving $100/month on HTTP calls
// Creating $10,000/month in coordination overhead
```

❌ **Platform BC with Domain Logic**
```kotlin
// Platform BC that duplicates business rules
// Now two places to maintain same logic - coupling!
```

### Architectural Anti-Patterns

❌ **Confusing Concerns**
```kotlin
// Mixing business requirements with infrastructure decisions
// "Session persistence" is infrastructure, not business behavior
```

❌ **Invisible Cost Optimization**
```kotlin
// Optimizing for visible metrics while ignoring hidden costs
// Saving $1K/month in infrastructure
// Losing $100K/year in team velocity
```

---

## Next Steps

For the mental models and validation techniques referenced in this document, see:
- **patterns/strategic-design-patterns.md** - Extremefy, Complexity Test, Aggregate Transaction Boundary, and other strategic thinking patterns

---

*Related files: principles/software-principles.md, principles/code-rules.md, principles/code-anti-patterns.md, patterns/testing-patterns.md, patterns/error-handling-patterns.md, patterns/strategic-design-patterns.md*
