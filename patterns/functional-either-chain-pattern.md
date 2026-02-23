Status: Advisory Pattern
Scope: Application layer orchestration using Either
Applies to: Functional-style domain/application services
# Functional Either Chain Pattern

A practical workflow for writing clean, functional Java code using vavr's `Either`, `Tuple`, and `flatMap`.

## Overview

This pattern creates readable, maintainable code by:
- Using `Either` as the primary monad for all operations
- Chaining operations with `flatMap` at a single outer level
- Carrying context forward with `Tuple`
- Keeping one method as the orchestrator

## The Workflow

### 1. Split to Understand

Start by extracting each logical step into its own function that returns `Either`:

```java
// Before: mixed concerns, hard to follow
public Either<Error, Result> process(Request request) {
    var resource = extractResource(request);
    var times = computeTimes(request.steps(), request.startTime());
    var questions = createQuestions(resource, times);
    if (request.filter().isDefined()) {
        questions = filter(questions, request.filter().get());
    }
    return Either.right(questions);
}

// After: split into separate functions
public Either<Error, Result> process(Request request) {
    return extractResource(request)
            .flatMap(resource -> computeTimes(request, resource))
            .flatMap(tuple -> createQuestions(tuple))
            .flatMap(questions -> applyFilter(questions, request));
}
```

### 2. Use Tuples to Carry Context Forward

When a later step needs data from an earlier step, use `Tuple` to carry it forward:

```java
return extractResource(request)
        .flatMap(resource -> computeTimes(request)
                .map(times -> Tuple.of(resource, times)))  // carry resource forward
        .flatMap(tuple -> createQuestions(tuple._1(), tuple._2()))
```

### 3. Convert Option to Either with fold

When dealing with `Option`, use `fold` to convert directly to `Either`:

```java
// Option.fold produces Either directly - both branches return Either
.flatMap(questions -> request.planningWindow().fold(
        () -> right(questions),                                    // None case
        window -> right(filterQuestionsByWindow(questions, window)) // Some case
))
```

### 4. Simplify - Inline Trivial Wrappers

Once the structure is clear, inline functions that just wrap values in `Either.right()`:

```java
// Before: separate function
private Either<Error, List<Time>> computeTimes(Request request) {
    return Either.right(computeSequentialTimes(request));
}

// After: inlined
.flatMap(resource -> Either.right(computeSequentialTimes(request))
        .map(times -> of(resource, times)))
```

### 5. Add Static Imports

Reduce noise with static imports:

```java
import static io.vavr.Tuple.of;
import static io.vavr.control.Either.right;

// Now reads cleaner
.flatMap(resource -> right(computeTimes(request)).map(times -> of(resource, times)))
.flatMap(tuple -> right(createQuestions(tuple._1(), tuple._2())))
```

### 6. Remove Explicit Types

Java needs explicit types initially to understand the chain. Once solid, remove them:

```java
// Before: explicit types needed during development
.flatMap((Tuple2<ResourceId, List<LocalDateTime>> tuple) -> right(...))

// After: Java can infer
.flatMap(tuple -> right(...))
```

**Note:** The first `Either.right()` in a chain often needs explicit type parameters:
```java
Either.<MappingError, List<LocalDateTime>>right(computeTimes(request))
```

## Final Pattern

The `generate` method becomes a clean, flat chain:

```java
@Override
public Either<MappingError, List<AvailabilityQuestion>> generate(PlanningRequest request) {
    return extractRequiredResource(request)
            .flatMap(resource -> Either.<MappingError, List<LocalDateTime>>right(computeStartTimes(request)).map(startTimes -> of(resource, startTimes)))
            .flatMap(tuple -> right(request.steps().zipWith(tuple._2(), (step, time) -> createQuestion(step, tuple._1(), time))))
            .flatMap(questions -> request.planningWindow().fold(
                    () -> right(questions),
                    window -> right(filterQuestionsByWindow(questions, window))
            ));
}
```

## Key Principles

| Principle | Description |
|-----------|-------------|
| **One Orchestrator** | The main method is just a flat chain of `flatMap` calls |
| **Single Responsibility** | Each step in the chain does one thing |
| **Tuples for Context** | Carry forward data needed by later steps |
| **Option → Either via fold** | Convert `Option` to `Either` using `fold`, not nested `map`/`getOrElse` |
| **Static Imports** | Use `of` and `right` to reduce noise |
| **Scaffolding Types** | Add explicit types while building, remove once structure is solid |

## Support Functions

Keep utility functions that take `PlanningRequest` (or your domain's request type) for cleaner call sites:

```java
// Clean call site
computeStartTimes(request)

// Instead of
computeSequentialStartTimes(request.steps(), request.requestedStartTime())
```

## Common Mistakes

### Nesting instead of chaining
```java
// Bad: nested
.flatMap(resource -> {
    var times = computeTimes(request);
    return Either.right(times).map(t -> createQuestions(resource, t));
})

// Good: flat chain with tuple
.flatMap(resource -> right(computeTimes(request)).map(times -> of(resource, times)))
.flatMap(tuple -> right(createQuestions(tuple._1(), tuple._2())))
```

### Mixing map and flatMap incorrectly
```java
// Use flatMap when the function returns Either
.flatMap(x -> functionReturningEither(x))

// Use map when transforming the value inside Either
.map(x -> transformValue(x))
```

### Forgetting to carry context forward
```java
// Bad: lost access to 'resource' in later step
.flatMap(resource -> computeTimes(request))
.flatMap(times -> createQuestions(resource, times))  // Error: resource not in scope

// Good: tuple carries resource forward
.flatMap(resource -> right(computeTimes(request)).map(times -> of(resource, times)))
.flatMap(tuple -> right(createQuestions(tuple._1(), tuple._2())))
```
