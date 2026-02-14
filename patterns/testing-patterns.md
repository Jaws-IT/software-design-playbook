# TESTING PATTERNS

*Version: 2.0 | Last Updated: January 17, 2026 | Enhanced with Clean Code Testing Practices*

## Summary

### Testing Patterns (DO)
- **Arrange-Act-Assert (AAA)** - Clear test structure
- **Test Behavior, Not Implementation** - Focus on observable outcomes
- **Objects Should Test Themselves** - Self-validating domain objects
- **Null Object Pattern** - Eliminate null checks in tests
- **Command Pattern Testing** - Test business operations as objects
- **State Pattern Testing** - Test state transitions safely
- **F.I.R.S.T Principles** - Fast, Independent, Repeatable, Self-Validating, Timely (Clean Code)
- **One Assert Per Test** - Each test should verify one thing (Clean Code)
- **Domain-Specific Testing Language** - Build abstractions for test readability (Clean Code)

### Testing Anti-Patterns (DON'T)
- **Testing Implementation Details** - Testing private methods or internal state
- **Excessive Mocking** - Mocking everything instead of using real objects
- **Testing HOW Instead of WHAT** - Verifying method calls instead of outcomes
- **Temporal Test Dependencies** - Tests that must run in specific order
- **Magic Test Data** - Unexplained test values without business meaning
- **One Giant Test** - Testing multiple behaviors in single test
- **Dirty Tests** - Tests harder to read than production code (Clean Code)

---

## Clean Code Testing Enhancements

### F.I.R.S.T Principles (From Clean Code)
Every test should follow these principles:

**F - Fast**: Tests should run quickly (milliseconds, not seconds)
```kotlin
// ❌ Slow test - hits database, network
@Test
fun `user registration saves to database`() {
    val database = MySQLDatabase()  // Real database connection
    val emailService = SMTPEmailService()  // Real email service
    
    val service = UserService(database, emailService)
    val result = service.register("test@example.com", "password")
    
    val savedUser = database.query("SELECT * FROM users WHERE email = ?", "test@example.com")
    assertNotNull(savedUser)
}

// ✅ Fast test - in-memory implementations
@Test  
fun `user registration creates user with correct details`() {
    val repository = InMemoryUserRepository()
    val emailService = FakeEmailService()
    
    val service = UserService(repository, emailService)
    val result = service.register("test@example.com", "password")
    
    assertTrue(result.isSuccess)
    assertEquals("test@example.com", result.user.email)
}
```

**I - Independent**: Tests should not depend on each other
```kotlin
// ❌ Dependent tests
class UserServiceTest {
    companion object {
        var userId: String? = null  // Shared state!
    }
    
    @Test
    fun `test 1 - create user`() {
        val result = service.createUser("John", "john@example.com")
        userId = result.id  // Setting shared state
        assertNotNull(userId)
    }
    
    @Test  
    fun `test 2 - update user`() {
        // Depends on test 1 running first!
        service.updateUser(userId!!, "Jane")
        val user = service.getUser(userId!!)
        assertEquals("Jane", user.name)
    }
}

// ✅ Independent tests
class UserServiceTest {
    @Test
    fun `creates user with correct details`() {
        val service = UserService(InMemoryRepository())
        
        val result = service.createUser("John", "john@example.com")
        
        assertTrue(result.isSuccess)
        assertEquals("John", result.user.name)
        assertEquals("john@example.com", result.user.email)
    }
    
    @Test
    fun `updates user name successfully`() {
        val repository = InMemoryRepository()
        val service = UserService(repository)
        val user = service.createUser("John", "john@example.com").user
        
        val result = service.updateUser(user.id, "Jane")
        
        assertTrue(result.isSuccess)
        assertEquals("Jane", result.user.name)
    }
}
```

**R - Repeatable**: Tests should produce same results in any environment
```kotlin
// ❌ Not repeatable - depends on current time
@Test
fun `user session expires after 1 hour`() {
    val session = createUserSession()
    
    // This will fail at different times!
    Thread.sleep(3600000)  // Sleep for 1 hour
    
    assertFalse(session.isValid())
}

// ✅ Repeatable - inject time dependency  
@Test
fun `user session expires after 1 hour`() {
    val clock = FakeClock()
    val session = createUserSession(clock)
    
    clock.advanceBy(Duration.ofHours(1))
    
    assertFalse(session.isValid())
}
```

**S - Self-Validating**: Tests should have boolean output (pass/fail)
```kotlin
// ❌ Requires manual verification
@Test
fun `generates user report`() {
    val service = ReportService()
    
    val report = service.generateUserReport(userId)
    
    println("Report generated:")
    println(report)  // Manual inspection required!
    // No assertions!
}

// ✅ Self-validating
@Test  
fun `user report contains expected sections`() {
    val service = ReportService()
    
    val report = service.generateUserReport(userId)
    
    assertTrue(report.hasSection("Personal Information"))
    assertTrue(report.hasSection("Order History"))
    assertTrue(report.hasSection("Account Status"))
    assertEquals(3, report.sectionCount())
}
```

**T - Timely**: Tests should be written just before production code (TDD)
```kotlin
// ✅ Write test first (Red)
@Test
fun `calculates compound interest correctly`() {
    val calculator = InterestCalculator()
    
    val result = calculator.calculateCompoundInterest(
        principal = 1000.0,
        rate = 0.05,
        periods = 2
    )
    
    assertEquals(1102.50, result, 0.01)
}

// ✅ Then write minimal code to pass (Green)
class InterestCalculator {
    fun calculateCompoundInterest(principal: Double, rate: Double, periods: Int): Double {
        return principal * Math.pow(1 + rate, periods.toDouble())
    }
}

// ✅ Then refactor (Refactor)
```

### One Assert Per Test Rule (From Clean Code)
Each test should test one thing and have one assertion (or a small number of closely related assertions).
```kotlin
// ❌ Multiple unrelated assertions
@Test
fun `user service test`() {
    val service = UserService()
    
    // Testing user creation
    val user = service.createUser("John", "john@example.com")
    assertNotNull(user)
    assertEquals("John", user.name)
    
    // Testing user validation (different concern!)
    assertTrue(service.isValidEmail("test@example.com"))
    assertFalse(service.isValidEmail("invalid-email"))
    
    // Testing user deletion (third concern!)
    service.deleteUser(user.id)
    assertNull(service.findUser(user.id))
}

// ✅ Separate tests for separate concerns
@Test
fun `creates user with provided name and email`() {
    val service = UserService()
    
    val user = service.createUser("John", "john@example.com")
    
    assertNotNull(user)
    assertEquals("John", user.name)
    assertEquals("john@example.com", user.email)
}

@Test
fun `validates email format correctly`() {
    val service = UserService()
    
    assertTrue(service.isValidEmail("test@example.com"))
}

@Test
fun `rejects invalid email format`() {
    val service = UserService()
    
    assertFalse(service.isValidEmail("invalid-email"))
}

@Test
fun `deleted user cannot be found`() {
    val service = UserService()
    val user = service.createUser("John", "john@example.com")
    
    service.deleteUser(user.id)
    
    assertNull(service.findUser(user.id))
}
```

### Domain-Specific Testing Language (From Clean Code)
Build helper functions and abstractions to make tests more readable and express domain concepts.
```kotlin
// ❌ Tests full of setup noise
@Test
fun `premium customer gets discount on large order`() {
    val customer = Customer()
    customer.id = "CUST001"
    customer.name = "John Doe"
    customer.tier = CustomerTier.PREMIUM
    customer.joinDate = LocalDate.of(2020, 1, 1)
    customer.isActive = true
    
    val item1 = Item()
    item1.id = "ITEM001"
    item1.name = "Laptop"
    item1.price = Money(1500.0)
    item1.category = "Electronics"
    
    val item2 = Item()
    item2.id = "ITEM002" 
    item2.name = "Mouse"
    item2.price = Money(50.0)
    item2.category = "Electronics"
    
    val order = Order()
    order.customer = customer
    order.items = listOf(item1, item2)
    order.createdAt = LocalDateTime.now()
    
    val pricingEngine = PricingEngine()
    val result = pricingEngine.calculateTotal(order)
    
    assertEquals(Money(1395.0), result)  // 10% premium discount
}

// ✅ Domain-specific test language
@Test
fun `premium customer gets discount on large order`() {
    val customer = aPremiumCustomer()
    val order = anOrderWith(
        items = listOf(
            laptop(price = 1500.dollars),
            mouse(price = 50.dollars)
        )
    )
    
    val total = calculateTotalFor(customer, order)
    
    assertThat(total).isEqualTo(1395.dollars)  // 10% premium discount
}

// Helper functions create domain-specific language
private fun aPremiumCustomer(): Customer = 
    CustomerBuilder().premium().build()
    
private fun anOrderWith(items: List<Item>): Order = 
    OrderBuilder().withItems(items).build()
    
private fun laptop(price: Money): Item = 
    ItemBuilder().laptop().withPrice(price).build()
    
private fun mouse(price: Money): Item = 
    ItemBuilder().mouse().withPrice(price).build()
    
private fun calculateTotalFor(customer: Customer, order: Order): Money =
    PricingEngine().calculateTotal(order.withCustomer(customer))

// Extension properties for readability
private val Int.dollars: Money get() = Money(this.toDouble())
```

### Dirty Tests Anti-Pattern (From Clean Code)
Tests that are harder to read than the production code they test.
```kotlin
// ❌ Dirty test - hard to understand
@Test
fun test1() {
    val w = Widget(1, 2, 3)
    val r1 = w.process(Data(4, 5, 6, true, false, "test", 
        mapOf("k1" to "v1", "k2" to "v2"), listOf(7, 8, 9)))
    val r2 = w.process(Data(10, 11, 12, false, true, "test2",
        mapOf("k3" to "v3"), listOf(13, 14)))
    
    assertEquals(42, r1.value)
    assertEquals(24, r2.value) 
    assertTrue(r1.flag)
    assertFalse(r2.flag)
}

// ✅ Clean test - intention clear
@Test
fun `widget processes high priority data with bonus calculation`() {
    val widget = Widget(
        baseMultiplier = 1,
        bonusThreshold = 2, 
        maxItems = 3
    )
    val highPriorityData = DataBuilder()
        .withValues(4, 5, 6)
        .highPriority()
        .withBonusEnabled()
        .build()
    
    val result = widget.process(highPriorityData)
    
    assertThat(result.calculatedValue).isEqualTo(42)
    assertThat(result.bonusApplied).isTrue()
}
```

[Previous testing patterns remain with any relevant enhancements...]

---

*Related files: 01-principles.md, 02-code-rules.md, 03-anti-patterns.md, 05-clean-code-formatting.md*