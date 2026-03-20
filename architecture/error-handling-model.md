# Error Handling as a Cross-Layer Architectural Model

Version: 1.1.0

*A system-level approach to classifying failures and allowing errors to flow through layers using domain abstractions.*

---

## Intent

This model defines how failures are understood, modeled, and propagated across a system built with Functional Programming, Domain-Driven Design, and Onion Architecture.

The goal is to:

- Treat errors as part of the domain language when appropriate  
- Make recoverability an explicit design concern  
- Avoid redundant mapping and duplication between layers  
- Allow errors to flow through the system using shared abstractions  

Errors are not only technical events. In many cases, they are domain concepts that deserve explicit modeling.

---

## Core Principle

Classify all potential failures into three tiers based on recoverability and business relevance, and allow errors to flow across layers using a shared `DomainError` abstraction without redundant mapping.

Decision ownership rule:

- Callee reports outcome explicitly (success or typed failure)
- Caller decides handling policy (retry, compensate, surface, abort, alert)
- Inner layers must not silently swallow command intent failures

---

## Part 1: Failure Classification Model

### The Three Tiers

#### Tier 1: Business Errors (Explicit Domain Handling)

Errors that represent business rule violations or domain constraints.

Handling:
- Modeled as explicit domain error types
- Returned via `Either<BusinessError, T>` or `Result<T, BusinessError>`

Test:
Would a business person recognize and understand this error?

---

#### Tier 2: Business-Relevant Technical Errors (Recoverable)

Technical failures where application logic can take meaningful recovery action.

Handling:
- Modeled as explicit error types
- Allow retries, reloads, or compensation

Test:
Can the application logic meaningfully respond?

---

#### Tier 3: Pure Technical Failures (Non-Recoverable)

Infrastructure failures, programming errors, or operational issues.

Handling:
- Surface as runtime exceptions
- Managed by infrastructure/operations

Test:
Is this a bug or infrastructure failure?

---

### Decision Criteria

When encountering an error, ask:

1. Business Language Test  
Would a business person ever talk about this?

2. Recoverability Test  
Can the application take meaningful action?

3. Domain Relevance Test  
Does this concept belong in the domain model?

Memory aid:

- Recoverable → explicit error type  
- Non-recoverable → runtime exception  

---

## Part 2: Error Propagation Model (No Redundant Mapping)

### Problem

Layered systems often introduce duplicate error hierarchies and repetitive mapping logic:

- Domain errors redefined in application layer  
- Application errors redefined in API layer  
- Boilerplate conversions between layers  

This leads to:

- Loss of type information  
- Increased maintenance burden  
- Accidental complexity  

---

### Solution: Shared DomainError Abstraction

Introduce a shared interface:

```kotlin
interface DomainError {
    val message: String
}
