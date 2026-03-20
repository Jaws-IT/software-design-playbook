# Functional Either Chain Pattern

Version: 1.1.0

Status: Advisory Pattern  
Scope: Application layer orchestration  
Applies to: Functional-style Java using Vavr Either, Tuple, and flatMap

This pattern defines a disciplined way of composing application logic using Either as the primary control structure.

It reinforces:
- Functional error handling (no exceptions for business rules)
- Single-orchestrator methods
- Flat, readable chains
- Explicit context propagation
- Callee reports outcome, caller decides handling policy

This is a tactical implementation pattern.
It is not a structural enforcement rule.

---

1. Intent

Application-layer orchestration should:
- Use Either as the primary monadic container
- Compose steps using a single outer flatMap chain
- Avoid nested blocks
- Avoid exception-based control flow
- Preserve explicit data flow

The orchestrator method should read as a linear sequence of transformations.

---

2. One Orchestrator Rule

The main method must be a flat chain of flatMap calls.

Example:

    public Either<MappingError, List<AvailabilityQuestion>> generate(PlanningRequest request) {
        return extractRequiredResource(request)
                .flatMap(resource -> computeStartTimes(request, resource))
                .flatMap(tuple -> createQuestions(tuple))
                .flatMap(questions -> applyPlanningWindow(questions, request));
    }

The orchestrator must not:
- Contain business logic
- Contain nested blocks
- Contain temporary mutable variables
- Throw exceptions for business failures

It coordinates only.

---

3. Split to Understand

Each logical step must be extracted into its own function returning Either.

Before (mixed concerns):

    public Either<Error, Result> process(Request request) {
        var resource = extractResource(request);
        var times = computeTimes(request.steps(), request.startTime());
        var questions = createQuestions(resource, times);
        return Either.right(questions);
    }

After (separated responsibilities):

    public Either<Error, Result> process(Request request) {
        return extractResource(request)
                .flatMap(resource -> computeTimes(request, resource))
                .flatMap(tuple -> createQuestions(tuple));
    }

Each step performs exactly one transformation.

---

4. Context Propagation via Tuple

When later steps require earlier data, use Tuple to carry context forward.

    return extractResource(request)
            .flatMap(resource ->
                    right(computeStartTimes(request))
                            .map(times -> of(resource, times)))
            .flatMap(tuple ->
                    right(createQuestions(tuple._1(), tuple._2())));

Rules:
- Do not re-fetch context.
- Do not introduce mutable holders.
- Do not nest lambdas to preserve scope.
- Use Tuple explicitly.

---

5. Option to Either Conversion

Convert Option directly using fold.

    .flatMap(questions ->
            request.planningWindow().fold(
                    () -> right(questions),
                    window -> right(filterQuestionsByWindow(questions, window))
            ));

Do not:
- Use getOrElse
- Call get
- Introduce nested map plus conditional logic

fold must produce Either directly.

---

6. flatMap vs map Discipline

Use flatMap when the function returns Either.
Use map when transforming the inner value.

Correct:

    .flatMap(x -> functionReturningEither(x))
    .map(x -> transformValue(x))

Incorrect:

    .map(x -> functionReturningEither(x))   // produces Either<Either<...>>

---

7. Inline Trivial Either Wrappers

If a function only wraps a value in Either.right, inline it.

Before:

    private Either<Error, List<Time>> computeTimes(Request request) {
        return Either.right(computeSequentialTimes(request));
    }

After:

    .flatMap(resource ->
            right(computeSequentialTimes(request))
                    .map(times -> of(resource, times)));

Avoid unnecessary wrapper functions.

---

8. Static Imports for Readability

Use static imports to reduce syntactic noise.

    import static io.vavr.Tuple.of;
    import static io.vavr.control.Either.right;

Result:

    .flatMap(resource ->
            right(computeTimes(request)).map(times -> of(resource, times)))

The chain should read as a linear transformation pipeline.

---

9. Explicit Type Scaffolding

During development, Java may require explicit generics.

    Either.<MappingError, List<LocalDateTime>>right(computeTimes(request))

Once structure is stable, remove redundant explicit types where inference succeeds.

Type scaffolding is temporary, not permanent verbosity.

---

10. Final Shape

A compliant orchestrator method has the following properties:
- Single return statement
- No local mutable variables
- No nested control blocks
- No throw statements
- No exception-based validation
- Flat flatMap chain
- Clear data flow
- Explicit context propagation

Example:

    @Override
    public Either<MappingError, List<AvailabilityQuestion>> generate(PlanningRequest request) {
        return extractRequiredResource(request)
                .flatMap(resource ->
                        Either.<MappingError, List<LocalDateTime>>right(computeStartTimes(request))
                                .map(startTimes -> of(resource, startTimes)))
                .flatMap(tuple ->
                        right(request.steps()
                                .zipWith(tuple._2(), (step, time) -> createQuestion(step, tuple._1(), time))))
                .flatMap(questions ->
                        request.planningWindow().fold(
                                () -> right(questions),
                                window -> right(filterQuestionsByWindow(questions, window))
                        ));
    }

---

11. Prefer Fold Over Manual Recursion

When processing a collection sequentially to build an accumulated result with possible failure, prefer `foldLeft` (or `foldRight`) with an `Either` accumulator.

Avoid manual recursion with explicit `isEmpty` / `head` / `tail` control flow.

Anti-pattern:

    private Either<Error, Result> processAll(List<Item> remaining, List<Output> accumulated) {
        if (remaining.isEmpty()) {
            return Either.right(new Result(accumulated));
        }

        Item current = remaining.head();
        return processOne(current)
                .flatMap(_ -> processAll(remaining.tail(), accumulated.append(current.id())));
    }

Problems:
- Imperative control flow disguised as functional code
- Manual base-case logic that fold already provides
- Explicit `head()` / `tail()` decomposition is error-prone
- Termination reasoning is harder than necessary

Preferred pattern:

    private Either<Error, Result> processAll(List<Item> items) {
        return items.foldLeft(
                Either.<Error, List<Output>>right(List.empty()),
                (acc, item) -> acc.flatMap(outputs ->
                        processOne(item).map(_ -> outputs.append(item.id()))
                )
        ).map(Result::new);
    }

Benefits:
- Empty collection handled naturally by the initial accumulator
- `flatMap` short-circuits on the first `Left`
- The code describes accumulation, not iteration mechanics
- No manual recursion or explicit termination logic

Rule:
- Use `foldLeft` or `foldRight` as the iteration mechanism
- Use `Either` as the accumulator type when each step can fail
- Use `flatMap` to chain failure-aware steps
- Use `map` for the final success-only transformation

This applies when:
- Each step can fail
- Failure should stop processing
- Successful steps accumulate into a final result

12. Common Violations

- Nested blocks instead of flat chain
- Mutable local variables
- Losing context due to scope errors
- Mixing map and flatMap incorrectly
- Throwing exceptions instead of returning Either
- Silent `Option` drops (`forEach`/no-op) for failed command intent
- Manual recursive `head` / `tail` loops where `foldLeft` would express the flow directly
- Performing orchestration inside the domain layer

---

13. Architectural Alignment

This pattern supports:
- Functional error handling doctrine
- No-throw business validation
- Application-layer orchestration discipline
- Clear separation of concerns
- Deterministic repair enforcement

This pattern is advisory but strongly recommended for all application-layer orchestration logic.

End of Functional Either Chain Pattern.
