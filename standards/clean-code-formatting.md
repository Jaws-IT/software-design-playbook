# CLEAN CODE FORMATTING

*Version: 1.1.0 | Last Updated: February 27, 2026 | Based on Clean Code Chapter 5*

## Summary

- **Newspaper Metaphor** - Code should read like a well-written newspaper article
- **Vertical Formatting** - Use blank lines to separate concepts
- **Vertical Density** - Keep related code close together
- **Horizontal Formatting** - Keep lines short, use white space meaningfully
- **Indentation** - Show structure and hierarchy clearly
- **Team Rules** - The team's formatting style trumps individual preference
- **Functional Pipeline Formatting** - Break chains clearly and consistently
- **Either Chain Formatting** - One operation per line

---

## Detailed Formatting Rules

### The Purpose of Formatting
Code formatting is about **communication**. Code is read far more than it's written, so it must communicate clearly.

> "Code formatting is important. It is too important to ignore and it is too important to treat religiously. Code formatting is about communication, and communication is the professional developer's first order of business."
>
> — Robert C. Martin

---

### Newspaper Metaphor

Code should read like a well-written newspaper article:

- **Headline** (class/file name) tells you what the story is about
- **First paragraph** (top methods) give you the synopsis
- **Details** follow as you read down
- **Paragraphs** (functions) are separated by blank lines

  class OrderProcessor {

        fun processOrder(request: OrderRequest): Either<OrderError, Order> {
            return validateRequest(request)
                .flatMap { createOrderFromRequest(it) }
                .flatMap { applyBusinessRules(it) }
                .flatMap { persistOrder(it) }
        }

        fun cancelOrder(orderId: OrderId): Either<OrderError, CancelledOrder> {
            // High-level cancellation logic
        }

        private fun validateRequest(request: OrderRequest): Either<OrderError, ValidatedRequest> {
            // Detailed validation logic
        }

        private fun createOrderFromRequest(request: ValidatedRequest): Either<OrderError, Order> {
            // Detailed creation logic
        }
  }

---

### Vertical Formatting

#### Vertical Openness Between Concepts

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
    }

---

### Vertical Density

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

---

### Horizontal Formatting

#### Line Length

    val result = someService.processComplexOperation(
        parameter1, parameter2, parameter3,
        parameter4, parameter5, parameter6
    )

#### Horizontal White Space

    val discriminant = b * b - 4 * a * c
    val root1 = (-b + sqrt(discriminant)) / (2 * a)

#### Horizontal Alignment

    val customerId = request.customerId
    val customerName = request.customerName
    val customerEmail = request.customerEmail
    val orderTotal = calculateTotal(request.items)

---

### Indentation

    class OrderValidator {

        fun validate(order: Order): Either<ValidationError, ValidatedOrder> {
            return when {
                order.items.isEmpty() ->
                    Either.Left(ValidationError.EmptyOrder)

                order.customer == null ->
                    Either.Left(ValidationError.MissingCustomer)

                order.total <= Money.ZERO ->
                    Either.Left(ValidationError.InvalidTotal)

                else ->
                    Either.Right(ValidatedOrder(order))
            }
        }
    }

---

### Functional Pipeline Formatting

When chaining operations (Streams, Sequences, functional transformations):

- One transformation per line
- Dot starts the new line
- Indent one level from return
- Never compress chain into one long line
- Avoid inline lambdas spanning multiple lines inside the chain

Bad:

    val result = users.filter { it.active }.map { transform(it) }.firstOrNull()

Good:

    val result = users
        .filter { it.active }
        .map { transform(it) }
        .firstOrNull()

If a lambda grows beyond one expression, extract it.

---

### Either Chain Formatting

Either pipelines should follow the same rule:

- One flatMap/map per line
- Avoid nested lambdas when possible
- Prefer named private functions over large inline lambdas

Good:

    fun process(request: Request): Either<Error, Result> {
        return validate(request)
            .flatMap { create(it) }
            .flatMap { applyRules(it) }
            .flatMap { persist(it) }
    }

If lambda logic becomes large:

    private fun applyRules(order: Order): Either<Error, Order> {
        ...
    }

Formatting must reveal the flow of intent.

---

### Team Rules

The most important rule: **The team decides on formatting rules, and everyone follows them.**

Formatting consistency outweighs personal preference.

---

**Remember**:  
Bad code can be beautifully formatted.  
Good formatting does not fix bad design.  
But good formatting makes good design readable.