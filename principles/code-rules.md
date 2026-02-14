# CODE RULES

*Version: 2.0 | Last Updated: January 17, 2026 | Enhanced with Clean Code Practices*

## Summary

- **Objects Hide Data, Expose Behavior** - No getters/setters, only behavior
- **Single Log Point** - Only log at the outermost container
- **WET over DRY** - Write Everything Twice before abstracting
- **100% Test Coverage** - All classes and endpoints must have tests
- **No Exceptions for Business Logic** - Use Result types for expected errors
- **Functional Style** - Always RETURN values, PURE functions, no SIDE EFFECTS
- **Test Behavior Only** - Never test private methods or internal state
- **Small Functions** - Functions should be 5-20 lines maximum
- **Command Query Separation** - Functions either DO something or RETURN something, never both
- **Function Arguments** - Minimize arguments (0-2 ideal, 3+ requires justification)

---

## Detailed Code Rules

### Objects Hide Data, Expose Behavior
[Previous "No Getters" content enhanced with Clean Code's objects vs data structures]

### Small Functions (From Clean Code)
Functions should be small - ideally 5-20 lines maximum. If a function is longer, it's probably doing more than one thing.
```kotlin
// ❌ Long function doing multiple things (45+ lines)
fun processOrder(orderData: Map<String, Any>): OrderResult {
    // Validation (8 lines)
    if (orderData["customerId"] == null) return OrderResult.error("Missing customer")
    if (orderData["items"] == null) return OrderResult.error("Missing items") 
    val items = orderData["items"] as? List<*> ?: return OrderResult.error("Invalid items")
    if (items.isEmpty()) return OrderResult.error("Empty order")
    // ... more validation
    
    // Business logic (15 lines)
    var total = 0.0
    val validItems = mutableListOf<Item>()
    for (itemData in items) {
        val item = itemData as Map<String, Any>
        val price = item["price"] as? Double ?: return OrderResult.error("Invalid price")
        val quantity = item["quantity"] as? Int ?: return OrderResult.error("Invalid quantity")
        total += price * quantity
        validItems.add(Item(price, quantity))
    }
    // Apply discounts, calculate tax, etc...
    
    // Persistence (10 lines)
    val customer = customerRepository.findById(customerId)
    val order = Order(customer, validItems, total)
    try {
        orderRepository.save(order)
        inventoryService.reserve(validItems)
        emailService.sendConfirmation(order)
    } catch (e: Exception) {
        return OrderResult.error("Failed to save: ${e.message}")
    }
    
    return OrderResult.success(order)
}

// ✅ Broken into small, focused functions
fun processOrder(orderData: Map<String, Any>): Either<OrderError, Order> {
    return validateOrderData(orderData)
        .flatMap { createOrderFromData(it) }
        .flatMap { saveOrderAndNotify(it) }
}

private fun validateOrderData(data: Map<String, Any>): Either<OrderError, ValidatedOrderData> {
    // 3-5 lines of focused validation
}

private fun createOrderFromData(data: ValidatedOrderData): Either<OrderError, Order> {
    // 5-8 lines of order creation logic
}

private fun saveOrderAndNotify(order: Order): Either<OrderError, Order> {
    // 4-6 lines of persistence and notification
}
```

**Benefits of Small Functions:**
- Easy to test each piece in isolation
- Easy to understand and reason about
- Easy to reuse and compose
- Easy to name meaningfully

### Command Query Separation (From Clean Code)
Functions should either **do something** (command) or **return something** (query), but never both.
```kotlin
// ❌ Violates Command Query Separation
fun setAndReturnAge(person: Person, age: Int): Int {
    person.age = age        // Command (doing something)
    return person.age       // Query (returning something)
}

// Usage creates confusion:
if (setAndReturnAge(person, 25) > 18) {  // Is this checking or setting?
    // What's happening here?
}

// ✅ Separate commands from queries
fun setAge(person: Person, age: Int): Unit {  // Command - does something
    person.age = age
}

fun getAge(person: Person): Int {             // Query - returns something
    return person.age
}

// ✅ Even better - immutable approach
fun withAge(person: Person, age: Int): Person {  // Pure function
    return person.copy(age = age)
}

fun age(person: Person): Int {                   // Query
    return person.age
}
```

### Function Arguments (From Clean Code)
The ideal number of arguments for a function is zero. Next comes one, followed closely by two. Three arguments should be avoided where possible, and more than three requires special justification.
```kotlin
// ❌ Too many arguments
fun createUser(
    firstName: String,
    lastName: String, 
    email: String,
    phone: String,
    address: String,
    city: String,
    country: String,
    age: Int,
    isActive: Boolean
): User

// ✅ Use argument objects
data class CreateUserCommand(
    val firstName: String,
    val lastName: String,
    val email: String,
    val phone: String,
    val address: Address,
    val age: Int,
    val isActive: Boolean = true
)

fun createUser(command: CreateUserCommand): Either<UserCreationError, User>

// ✅ For simple cases, use builder pattern
class UserBuilder {
    fun name(first: String, last: String) = apply { ... }
    fun contact(email: String, phone: String) = apply { ... }
    fun address(address: Address) = apply { ... }
    fun build(): User = ...
}
```

**Argument Guidelines:**
- **0 arguments (niladic)**: Perfect
- **1 argument (monadic)**: Very good - asking a question or transforming
- **2 arguments (dyadic)**: Good - natural pairs like Point(x, y)
- **3 arguments (triadic)**: Questionable - consider argument objects
- **4+ arguments**: Almost certainly wrong - use objects or builders

**Flag Arguments are Evil:**
```kotlin
// ❌ Flag arguments are confusing
fun render(page: Page, isSuite: Boolean)

// What does this mean?
render(page, true)   // Is it a suite? What's a suite?
render(page, false)  // Not a suite?

// ✅ Split into separate functions
fun renderSingleTest(page: Page)
fun renderTestSuite(page: Page)
```

[Other existing code rules remain with any Clean Code enhancements...]

---

*Related files: 01-principles.md, 03-anti-patterns.md, 04-testing-patterns.md, 05-clean-code-formatting.md*