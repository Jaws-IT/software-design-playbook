# Railway State Transition Pattern

Status: Pattern  
Category: Functional Modeling  
Scope: Domain, Application, UI, Workflow

This pattern describes forward-only state transitions using explicit result types.

It is not UI-specific.  
It applies to any forward-moving state machine.

---

# 1. Core Principle

State transitions must move forward.

There is no implicit rollback.
There is no hidden control flow.
There is no exception-driven branching.

Each transition produces a new state.

---

# 2. Forward-Only Modeling

A system state should be represented explicitly.

Example structure:

- Initial
- InProgress
- Failed
- Completed
- Cancelled
- Reverted

Transitions must be explicit.

---

# 3. No Backward Movement

There is no “go back”.

Undo and Cancel are forward transitions:

State.Submitting → State.Cancelled  
State.Success → State.Reverted(previousValue)

Backward mutation of internal state is forbidden.

---

# 4. Railway Error Handling

Errors are values.

Not control flow jumps.

Use Either / Result types:

- Either<Failure, Success>
- Result<T>
- Validated<T>

Error flows forward until resolved.

---

# 5. Transition Function Model

State transitions should be modeled as a pure function:

    nextState = transition(currentState, action)

Properties:

- Deterministic
- Side-effect-free
- Explicit mapping
- Exhaustive when possible

Prefer sealed interfaces / algebraic data types.

---

# 6. No Try/Catch for Business Flow

Forbidden:

- Using exceptions to model validation
- Using exceptions to redirect flow
- Using throw for domain failure

Allowed:

- Exceptions for technical failure only
- Explicit domain failure modeling

---

# 7. Domain Alignment

This pattern is especially suitable for:

- Aggregate command handling
- Workflow orchestration
- Saga coordination
- UI interaction state
- Validation pipelines
- Planning engines

It enforces:

- Predictability
- Testability
- Referential transparency (where possible)
- Explicit business modeling

---

# 8. Interaction with DDD

When used inside an Aggregate:

- Command returns Either<Failure, DomainEvent>
- State evolves only via valid transitions
- Invalid transitions produce Failure, not exception

When used inside Application layer:

- Orchestrate steps using flatMap
- Fold at boundary
- Translate failure into integration contract

---

# 9. Benefits

- Eliminates hidden jumps
- Improves reasoning
- Makes state machines explicit
- Enables exhaustive handling
- Aligns with functional style

---

# 10. When Not to Use

Avoid if:

- State is trivial
- Flow is purely technical
- Modeling overhead outweighs clarity

Use where correctness and clarity matter.

---

End of Railway State Transition Pattern