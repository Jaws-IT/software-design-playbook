# ANTI-PATTERNS

*Version: 2.0 | Last Updated: January 17, 2026 | Enhanced with Clean Code Anti-Patterns*

## Summary

- **Generated Code Internally** - Avoid code generation within the system
- **Rules in Config** - Business rules belong in code, not configuration
- **Runtime Validation Instead of Compile-Time Types** - Use type system, not runtime checks
- **Anemic Domain Models** - Data without behavior (with ADT clarification)
- **God Objects/God Classes** - Classes doing too much
- **Primitive Obsession** - Using String/Int instead of domain types
- **Leaky Abstractions** - Implementation details in interfaces
- **Train Wreck Code** - Method chaining through object graphs
- **Double Dispatch Problem** - Complex type checking for behavior
- **Testing Implementation** - Testing privates instead of behavior
- **Temporal Coupling** - Methods that must be called in specific order
- **Strongly Typed Code** - Using strings for everything
- **Shotgun Surgery** - One change requires modifications everywhere
- **Magic Numbers/Strings** - Unexplained literals scattered through code
- **Null Checks Everywhere** - Forcing callers to handle nulls
- **Constructor Coupling** - Too many dependencies in constructors
- **Low-Level Controlling High-Level** - Violates Hollywood Principle
- **Long Functions** - Functions longer than 20 lines (Clean Code)
- **Flag Arguments** - Boolean parameters controlling function behavior (Clean Code)
- **Comment Clutter** - Comments that don't add value (Clean Code)
- **Mixed Levels of Abstraction** - One function operating at multiple abstraction levels (Clean Code)

---

## Detailed Anti-Patterns

[Previous anti-patterns remain the same...]

### Long Functions (From Clean Code)
Functions should be small - ideally 5-20 lines. Long functions are hard to understand, test, and maintain.
```kotlin
// ❌ Long function - 50+ lines doing multiple things
fun processOrder(request: OrderRequest): OrderResponse {
    // Validation block (15 lines)
    if (request.customerId.isBlank()) {
        logger.error("Customer ID is blank")
        return OrderResponse.error("Invalid customer ID")
    }
    
    if (request.items.isEmpty()) {
        logger.error("No items in order")  
        return OrderResponse.error("Empty order")
    }
    
    for (item in request.items) {
        if (item.quantity <= 0) {
            logger.error("Invalid quantity: ${item.quantity}")
            return OrderResponse.error("Invalid item quantity")
        }
        if (item.productId.isBlank()) {
            logger.error("Product ID is blank")
            return OrderResponse.error("Invalid product ID")  
        }
    }
    
    // Business logic block (20 lines)
    var total = 0.0
    val orderItems = mutableListOf<OrderItem>()
    
    for (item in request.items) {
        val product = productService.findById(item.productId)
        if (product == null) {
            logger.error("Product not found: ${item.productId}")
            return OrderResponse.error("Product not found")
        }
        
        val lineTotal = product.price * item.quantity
        total += lineTotal
        
        orderItems.add(OrderItem(product, item.quantity, lineTotal))
    }
    
    // Apply discounts
    val customer = customerService.findById(request.customerId)
    if (customer?.isPremium == true) {
        total *= 0.9  // 10% discount
    }
    
    // Persistence block (15 lines)
    val order = Order(
        customerId = request.customerId,
        items = orderItems,
        total = total,
        createdAt = Instant.now()
    )
    
    try {
        val savedOrder = orderRepository.save(order)
        inventoryService.reserveItems(orderItems)
        
        emailService.sendOrderConfirmation(savedOrder)
        
        auditService.logOrderCreation(savedOrder)
        
        return OrderResponse.success(savedOrder)
    } catch (e: Exception) {
        logger.error("Failed to save order", e)
        return OrderResponse.error("Order processing failed")
    }
}

// ✅ Broken into focused, small functions
class OrderProcessor {
    fun processOrder(request: OrderRequest): Either<OrderError, Order> {
        return validateRequest(request)
            .flatMap { createOrder(it) }
            .flatMap { persistOrder(it) }
    }
    
    private fun validateRequest(request: OrderRequest): Either<OrderError, ValidatedRequest> {
        // 5-8 lines of focused validation
    }
    
    private fun createOrder(request: ValidatedRequest): Either<OrderError, Order> {
        // 8-12 lines of business logic
    }
    
    private fun persistOrder(order: Order): Either<OrderError, Order> {
        // 5-8 lines of persistence logic
    }
}
```

### Flag Arguments (From Clean Code)
Passing boolean parameters to control function behavior is evil - it immediately means the function is doing more than one thing.
```kotlin
// ❌ Flag argument - what does true/false mean?
fun render(content: Content, isComplex: Boolean): String

// Usage is confusing
val simple = render(content, false)  // What's false?
val complex = render(content, true)  // What's true?

// ❌ Multiple flags are even worse
fun processData(data: Data, useCache: Boolean, validate: Boolean, compress: Boolean): Result

// ✅ Split into intention-revealing functions
fun renderSimple(content: Content): String
fun renderComplex(content: Content): String

// ✅ Or use sealed classes for options
sealed class RenderOptions {
    object Simple : RenderOptions()
    object Complex : RenderOptions()
}

fun render(content: Content, options: RenderOptions): String

// ✅ Or use method chaining/builder pattern
fun render(content: Content): RenderBuilder
class RenderBuilder {
    fun withComplexFormatting(): RenderBuilder
    fun withSimpleFormatting(): RenderBuilder  
    fun execute(): String
}
```

### Comment Clutter (From Clean Code)
Comments that don't add value, restate the obvious, or are misleading.
```kotlin
// ❌ Noise comments - restating the obvious
class User {
    private var name: String = ""  // The user's name
    
    // Set the user's name
    fun setName(name: String) {
        this.name = name  // Set name to the parameter
    }
    
    // Get the user's name  
    fun getName(): String {
        return name  // Return the name
    }
}

// ❌ Misleading comments
// Utility method to add two numbers
fun multiply(a: Int, b: Int): Int {  // Comment says add, code multiplies!
    return a * b
}

// ❌ Journal comments
/*
 * Changes:
 * 2023-01-15: Added validation - John
 * 2023-02-20: Fixed bug with negative numbers - Sarah  
 * 2023-03-10: Refactored for performance - Mike
 */
fun calculateTotal(items: List<Item>): Money {
    // This is what version control is for!
}

// ✅ Good comments - explain WHY, not WHAT
class PrimeGenerator {
    /**
     * This array is just the right size to sieve all primes up to 1000.
     * The algorithm used here is the Sieve of Eratosthenes.
     * Unfortunately, the algorithm can run no faster because it
     * has to examine every candidate up to the square root of the
     * maximum value.
     */
    private val crossedOut = BooleanArray(1000)
}

// ✅ Warning comments
fun startReactor(password: String): ReactorStatus {
    // Don't run unless you have some time to kill.
    // This method takes 2-3 minutes to complete.
    return reactor.start(password)
}

// ✅ TODO comments (but sparingly)
fun calculateCommission(sales: Money): Money {
    // TODO: This should be configurable based on employee level
    return sales * 0.05
}
```

### Mixed Levels of Abstraction (From Clean Code)
Functions should operate at a single level of abstraction. Mixing high-level concepts with low-level details makes code hard to follow.
```kotlin
// ❌ Mixed abstraction levels in one function
fun generateReport(userId: String): String {
    // High level - get user
    val user = userService.findById(userId)
    
    // Low level - string manipulation  
    val header = StringBuilder()
    header.append("Report for: ")
    header.append(user.name)
    header.append("\n")
    header.append("Generated: ")
    header.append(SimpleDateFormat("yyyy-MM-dd").format(Date()))
    header.append("\n")
    header.append("-".repeat(50))
    header.append("\n")
    
    // High level - get orders
    val orders = orderService.getOrdersForUser(userId)
    
    // Low level - more string building
    val body = StringBuilder()
    for (order in orders) {
        body.append("Order #")
        body.append(order.id)
        body.append(" - $")
        body.append(String.format("%.2f", order.total))
        body.append(" on ")
        body.append(SimpleDateFormat("MM/dd/yyyy").format(order.date))
        body.append("\n")
    }
    
    return header.toString() + body.toString()
}

// ✅ Separate abstraction levels
fun generateReport(userId: String): Either<ReportError, Report> {
    return getUserData(userId)
        .flatMap { user -> getOrderData(userId).map { orders -> user to orders } }
        .map { (user, orders) -> createReport(user, orders) }
        .map { report -> formatReport(report) }
}

private fun getUserData(userId: String): Either<ReportError, User> {
    // High-level user retrieval
}

private fun getOrderData(userId: String): Either<ReportError, List<Order>> {
    // High-level order retrieval  
}

private fun createReport(user: User, orders: List<Order>): Report {
    // High-level report creation
}

private fun formatReport(report: Report): Report {
    // Delegates to low-level formatting functions
    return report.copy(
        header = formatHeader(report.user, report.generatedAt),
        body = formatOrderList(report.orders)
    )
}

private fun formatHeader(user: User, date: LocalDateTime): String {
    // Low-level string formatting
}

private fun formatOrderList(orders: List<Order>): String {
    // Low-level string formatting
}
```

[Other existing anti-patterns remain the same...]

---

*Related files: 01-principles.md, 02-code-rules.md, 04-testing-patterns.md, 05-clean-code-formatting.md*