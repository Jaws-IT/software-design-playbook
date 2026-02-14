# CLEAN CODE FORMATTING

*Version: 1.0 | Last Updated: January 17, 2026 | Based on Clean Code Chapter 5*

## Summary

- **Newspaper Metaphor** - Code should read like a well-written newspaper article
- **Vertical Formatting** - Use blank lines to separate concepts
- **Vertical Density** - Keep related code close together
- **Horizontal Formatting** - Keep lines short, use white space meaningfully
- **Indentation** - Show structure and hierarchy clearly
- **Team Rules** - The team's formatting style trumps individual preference

---

## Detailed Formatting Rules

### The Purpose of Formatting
Code formatting is about **communication**. Code is read far more than it's written, so it must communicate clearly.

> "Code formatting is important. It is too important to ignore and it is too important to treat religiously. Code formatting is about communication, and communication is the professional developer's first order of business."
>
> — Robert C. Martin

### Newspaper Metaphor
Code should read like a well-written newspaper article:

- **Headline** (class/file name) tells you what the story is about
- **First paragraph** (top methods) give you the synopsis
- **Details** follow as you read down
- **Paragraphs** (functions) are separated by blank lines
```kotlin
// ✅ Newspaper structure
class OrderProcessor {
    // Public API first - the "headline" methods
    fun processOrder(request: OrderRequest): Either<OrderError, Order> {
        return validateRequest(request)
            .flatMap { createOrderFromRequest(it) }
            .flatMap { applyBusinessRules(it) }
            .flatMap { persistOrder(it) }
    }
    
    fun cancelOrder(orderId: OrderId): Either<OrderError, CancelledOrder> {
        // High-level cancellation logic
    }
    
    // Private implementation details follow
    private fun validateRequest(request: OrderRequest): Either<OrderError, ValidatedRequest> {
        // Detailed validation logic
    }
    
    private fun createOrderFromRequest(request: ValidatedRequest): Either<OrderError, Order> {
        // Detailed creation logic  
    }
    
    // More private methods...
}
```

### Vertical Formatting

#### Vertical Openness Between Concepts
Use blank lines to separate different concepts:
```kotlin
// ✅ Concepts separated by blank lines
class CustomerService(
    private val repository: CustomerRepository,
    private val emailService: EmailService
) {

    fun registerCustomer(request: RegistrationRequest): Either<RegistrationError, Customer> {
        return validateRegistrationData(request)
            .flatMap { createCustomer(it) }
            .flatMap { saveCustomer(it) }
            .flatMap { sendWelcomeEmail(it) }
    }

    fun updateCustomerProfile(customerId: CustomerId, profile: Profile): Either<UpdateError, Customer> {
        return findCustomer(customerId)
            .flatMap { customer -> customer.updateProfile(profile) }
            .flatMap { saveCustomer(it) }
    }

    private fun validateRegistrationData(request: RegistrationRequest): Either<RegistrationError, ValidatedData> {
        if (request.email.isBlank()) {
            return Either.Left(RegistrationError.InvalidEmail)
        }
        
        if (request.password.length < 8) {
            return Either.Left(RegistrationError.WeakPassword)
        }
        
        return Either.Right(ValidatedData(request.email, request.password))
    }

    private fun findCustomer(customerId: CustomerId): Either<UpdateError, Customer> {
        return repository.findById(customerId)
            ?.let { Either.Right(it) }
            ?: Either.Left(UpdateError.CustomerNotFound)
    }
}
```

#### Vertical Density
Keep closely related code together:
```kotlin
// ❌ Related code spread apart
class User {
    val name: String
    
    fun getName(): String {
        return name
    }
    
    val email: String
    
    fun getEmail(): String {  
        return email
    }
    
    val createdAt: Instant
    
    fun getCreatedAt(): Instant {
        return createdAt  
    }
}

// ✅ Related code kept together
class User(
    val name: String,
    val email: String,
    val createdAt: Instant
) {
    fun isActive(): Boolean = 
        createdAt.isAfter(Instant.now().minus(Duration.ofDays(30)))
        
    fun displayName(): String = 
        if (name.isNotBlank()) name else email.substringBefore("@")
}
```

#### Vertical Distance
- **Variable declarations** should be close to their usage
- **Functions** should be close to where they're called
- **Related concepts** should be close together
```kotlin
// ✅ Variables close to usage
fun calculateOrderTotal(items: List<Item>): Money {
    var subtotal = Money.ZERO        // Declared close to usage
    
    for (item in items) {
        subtotal += item.price * item.quantity
    }
    
    val taxRate = getTaxRate()       // Declared close to usage
    val tax = subtotal * taxRate
    
    return subtotal + tax
}

// ✅ Functions in order of calling (stepdown rule)
class ReportGenerator {
    fun generateReport(userId: UserId): Report {
        val user = loadUser(userId)           // Calls loadUser (defined below)
        val data = collectReportData(user)    // Calls collectReportData (defined below)
        return formatReport(data)             // Calls formatReport (defined below)
    }
    
    private fun loadUser(userId: UserId): User {
        // Implementation
    }
    
    private fun collectReportData(user: User): ReportData {
        // Implementation  
    }
    
    private fun formatReport(data: ReportData): Report {
        // Implementation
    }
}
```

### Horizontal Formatting

#### Line Length
Keep lines short - ideally under 80-120 characters:
```kotlin
// ❌ Long line - hard to read
val result = someService.processComplexOperation(parameter1, parameter2, parameter3, parameter4, parameter5, parameter6)

// ✅ Broken into readable chunks
val result = someService.processComplexOperation(
    parameter1, parameter2, parameter3,
    parameter4, parameter5, parameter6
)

// ✅ Or use intermediate variables
val operation = ComplexOperation(parameter1, parameter2, parameter3)
val context = ProcessingContext(parameter4, parameter5, parameter6)
val result = someService.process(operation, context)
```

#### Horizontal White Space
Use white space to show precedence and separation:
```kotlin
// ✅ White space shows precedence
val discriminant = b*b - 4*a*c           // Multiplication has precedence
val root1 = (-b + sqrt(discriminant)) / (2*a)  // Parentheses and division clear

// ✅ White space around assignments and operators
val customerName = request.name
val isValid = customerName.isNotBlank() && customerName.length >= 2

// ✅ Function parameters - space after commas
fun createOrder(customerId: CustomerId, items: List<Item>, discount: Percentage): Order
```

#### Horizontal Alignment
Don't align variable declarations - it draws attention to the wrong things:
```kotlin
// ❌ Horizontal alignment - distracting
val customerId     = request.customerId
val customerName   = request.customerName  
val customerEmail  = request.customerEmail
val orderTotal     = calculateTotal(request.items)

// ✅ Natural alignment
val customerId = request.customerId
val customerName = request.customerName
val customerEmail = request.customerEmail  
val orderTotal = calculateTotal(request.items)
```

### Indentation
Indentation should clearly show the structure and hierarchy:
```kotlin
// ✅ Clear indentation showing structure
class OrderValidator {
    fun validate(order: Order): Either<ValidationError, ValidatedOrder> {
        return when {
            order.items.isEmpty() -> {
                Either.Left(ValidationError.EmptyOrder)
            }
            order.customer == null -> {
                Either.Left(ValidationError.MissingCustomer)
            }
            order.total <= Money.ZERO -> {
                Either.Left(ValidationError.InvalidTotal)
            }
            else -> {
                Either.Right(ValidatedOrder(order))
            }
        }
    }
    
    private fun validateItems(items: List<Item>): Boolean {
        return items.all { item ->
            item.quantity > 0 && 
            item.price > Money.ZERO &&
            item.name.isNotBlank()
        }
    }
}
```

### Team Rules
The most important rule: **The team decides on formatting rules, and everyone follows them.**
```kotlin
// Team decides on these rules and everyone follows:
// - 4 spaces for indentation
// - 120 character line limit  
// - Blank line between functions
// - No blank line between property and getter
// - Space around operators
// - No trailing whitespace

class ExampleClass(
    private val dependency1: Dependency1,
    private val dependency2: Dependency2
) {
    val calculatedValue: Int
        get() = dependency1.value + dependency2.value
        
    fun processRequest(request: Request): Response {
        val validatedRequest = validate(request)
        return process(validatedRequest)
    }
    
    private fun validate(request: Request): ValidatedRequest {
        // Validation logic
    }
    
    private fun process(request: ValidatedRequest): Response {
        // Processing logic
    }
}
```

**Remember**: Bad code is often well-formatted. Good formatting doesn't make bad code good, but it makes good code much easier to read and maintain.

---

*Related files: 01-principles.md, 02-code-rules.md, 03-anti-patterns.md, 04-testing-patterns.md*     