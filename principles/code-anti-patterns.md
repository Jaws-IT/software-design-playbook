# ANTI-PATTERNS

*Version: 3.0 | Last Updated: February 27, 2026 | Enhanced with Premature Collection | Eager Materialization*

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
- **Eager Materialization** - Building unnecessary intermediate collections
- **Premature Collection** - Collecting data when a single-pass pipeline would suffice
- **Domain–Integration Collapse for Performance** - Merging models to “save mapping”
- **Boundary Violation for Micro-Optimization** - Breaking architecture for perceived speed

---

## Detailed Anti-Patterns

[Previous anti-patterns remain the same...]

---

### Long Functions (From Clean Code)

Functions should be small - ideally 5-20 lines. Long functions are hard to understand, test, and maintain.

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

---

### Flag Arguments (From Clean Code)

Passing boolean parameters to control function behavior is evil.

    // ❌ Flag argument
    fun render(content: Content, isComplex: Boolean): String

    // ❌ Multiple flags
    fun processData(data: Data, useCache: Boolean, validate: Boolean, compress: Boolean): Result

    // ✅ Intention-revealing functions
    fun renderSimple(content: Content): String
    fun renderComplex(content: Content): String

---

### Comment Clutter (From Clean Code)

Comments that restate the obvious or mislead.

    // ❌ Noise comments
    class User {
        private var name: String = ""  // The user's name

        fun setName(name: String) {
            this.name = name
        }

        fun getName(): String {
            return name
        }
    }

Good comments explain WHY, not WHAT.

---

### Mixed Levels of Abstraction (From Clean Code)

Functions should operate at one level of abstraction.

    // ❌ Mixed abstraction levels
    fun generateReport(userId: String): String {
        val user = userService.findById(userId)

        val header = StringBuilder()
        header.append("Report for: ")
        header.append(user.name)

        val orders = orderService.getOrdersForUser(userId)

        val body = StringBuilder()
        for (order in orders) {
            body.append(order.id)
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

---

### Eager Materialization

Building intermediate collections unnecessarily.

    // ❌ Double traversal
    val slots = generateTimeSlots()
    val probes = slots.map { it.toProbe() }
    for (probe in probes) {
        capacityService.check(probe)
    }

    // ✅ Lazy pipeline
    generateTimeSlots()
        .map { it.toProbe() }
        .forEach { capacityService.check(it) }

---

### Premature Collection

Collecting data when only one pass is needed.

    // ❌ Collect then pick first
    val results = users
        .filter { it.isActive }
        .map { transform(it) }
        .toList()

    return results.firstOrNull()

    // ✅ Direct pipeline
    return users
        .asSequence()
        .filter { it.isActive }
        .map { transform(it) }
        .firstOrNull()

---

### Domain–Integration Collapse for Performance

    // ❌ Using integration DTO in domain
    class BookingService {
        fun suggest(dto: AvailabilityResponseDto): Suggestion {
            ...
        }
    }

Integration types must not leak into domain logic.

---

### Boundary Violation for Micro-Optimization

    // ❌ Domain calling infrastructure directly
    class BookingAggregate {
        fun reserveSlot(slot: TimeSlot): Either<BookingError, Booking> {
            val availability = externalAvailabilityService.check(slot)
            ...
        }
    }

Optimization must not compromise architecture.

---