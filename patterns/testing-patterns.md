# TESTING PATTERNS

*Version: 2.1 | Last Updated: February 27, 2026 | Enhanced with Clean Code Testing Practices*

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

    // ❌ Slow test - hits database, network
    @Test
    fun `user registration saves to database`() {
        val database = MySQLDatabase()
        val emailService = SMTPEmailService()
        
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

**I - Independent**: Tests should not depend on each other

    // ❌ Dependent tests
    class UserServiceTest {
        companion object {
            var userId: String? = null
        }
        
        @Test
        fun `test 1 - create user`() {
            val result = service.createUser("John", "john@example.com")
            userId = result.id
            assertNotNull(userId)
        }
        
        @Test  
        fun `test 2 - update user`() {
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
    }

**R - Repeatable**

    // ❌ Not repeatable
    @Test
    fun `user session expires after 1 hour`() {
        val session = createUserSession()
        Thread.sleep(3600000)
        assertFalse(session.isValid())
    }

    // ✅ Repeatable
    @Test
    fun `user session expires after 1 hour`() {
        val clock = FakeClock()
        val session = createUserSession(clock)
        clock.advanceBy(Duration.ofHours(1))
        assertFalse(session.isValid())
    }

**S - Self-Validating**

    // ❌ Manual verification
    @Test
    fun `generates user report`() {
        val service = ReportService()
        val report = service.generateUserReport(userId)
        println(report)
    }

    // ✅ Self-validating
    @Test  
    fun `user report contains expected sections`() {
        val service = ReportService()
        val report = service.generateUserReport(userId)
        assertTrue(report.hasSection("Personal Information"))
        assertEquals(3, report.sectionCount())
    }

**T - Timely**

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

---

### Testing Under Scale Assumptions

When designing domain logic that may operate over large or unbounded sequences,
tests should validate behavior under increased scale.

Do not assume small collections.

Instead:

- Test with larger datasets when relevant.
- Validate correctness independent of collection size.
- Ensure algorithms remain deterministic.
- Confirm no hidden state accumulates across iterations.

Example:

    @Test
    fun `suggestion algorithm produces consistent results for large input`() {
        val largeInput = generateLargeTestDataset(10_000)
        val result = suggestionEngine.process(largeInput)
        
        assertTrue(result.isValid())
        assertEquals(expectedCount, result.count())
    }

Scale testing does not require production-level volume,
but the design should survive conceptual growth.

---

### Do Not Test Laziness Internals

Streaming or lazy composition is an implementation detail.

Tests must validate observable behavior,
not whether a Stream, Sequence, or pipeline was used internally.

Forbidden:

- Verifying number of iterations.
- Asserting internal method invocation counts.
- Mocking to detect pipeline steps.
- Testing for specific collection types.

Correct:

    @Test
    fun `returns only active users`() {
        val users = listOf(
            User("A", active = true),
            User("B", active = false)
        )
        
        val result = userService.findActive(users)
        
        assertEquals(1, result.size)
        assertEquals("A", result.first().name)
    }

The test asserts business outcome,
not how the sequence was processed.

Behavior is stable.
Implementation may evolve.

---

*Related files: principles/software-principles.md, principles/code-rules.md, principles/code-anti-patterns.md, standards/clean-code-formatting.md*
