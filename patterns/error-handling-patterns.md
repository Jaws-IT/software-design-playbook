
with this:

```markdown
# Error Handling Patterns

Implementation patterns for applying the system-wide error handling model in code.

---

## Core Practices

- Use `Either`/`Result` for expected failures  
- Use exceptions for system failures  
- Fail fast for invariants  
- Make errors explicit and typed  
- Avoid translation layers  
- Preserve context as errors propagate  

---

## Error Type Design Patterns

### Sealed Classes for Error Hierarchies

Use sealed classes to represent explicit domain failures.

Benefits:
- Type safety
- Exhaustive handling
- Clear domain language

---

### Error Composition & Accumulation

Use validation accumulation for user input scenarios:

- Collect all validation errors
- Return them together
- Improve user experience

Use fail-fast validation for invariants.

---

## Error Propagation Patterns

### Railway-Oriented Programming

Chain operations using `flatMap`:

- Stops on first error
- Keeps logic linear
- Avoids nested try/catch

---

### Error Recovery Strategies

Recover when meaningful:

- Retry transient failures
- Reload on concurrency conflicts
- Provide fallbacks where safe

Do NOT retry blindly.

---

### Error Context Enrichment

As errors propagate:

- Add business context
- Add identifiers
- Add timestamps
- Preserve original cause

Never wrap and lose information.

---

## Validation Patterns

### Fail-Fast vs Collect-All

Use fail-fast:
- Invariants
- Constructors
- Domain consistency

Use collect-all:
- User input validation
- Form processing

---

### Smart Constructors

Use factory methods returning `Either` to prevent invalid state creation.

---

## Exception Usage Patterns

Use exceptions for:

- Programming errors
- Infrastructure failures
- System startup failures

Avoid exceptions for:

- Expected business logic
- Control flow

---

## Observability Patterns

### Logging Strategy

Log based on severity:

- System failures → ERROR  
- Recoverable technical → WARN  
- Expected business failures → INFO/DEBUG  

Always log with context.

---

### Structured Error Data

Include structured metadata:

- Identifiers
- Amounts
- Timestamps
- Correlation IDs

Useful for monitoring and metrics.

---

## Boundary Translation Patterns

### Bounded Context Boundaries

Translate errors when crossing contexts.

Do not leak internal error types outside their context.

---

### API Boundaries

Convert domain errors into:

- HTTP responses
- UI messages
- External contracts

Never expose internal implementation details.
