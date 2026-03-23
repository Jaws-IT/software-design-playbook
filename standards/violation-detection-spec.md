# Violation Detection Specification

Version: 1.0.0

Status: Authoritative
Applies to: LLM generation flow, audit flow, repair flow, code review

This specification defines the required post-generation violation detection pass for doctrine and architecture compliance.

---

# 1. Purpose

Generated code must not be accepted solely because it compiles or appears plausible.

A dedicated detection pass is required after generation to catch:

- doctrine drift
- architecture regressions
- hidden coupling
- aggregate API widening
- comment-based attempts to justify violations

This pass exists because some violations are structurally repeatable and should be caught systematically rather than relying on discretionary review.

---

# 2. Required Execution Point

Violation detection MUST run:

- after code generation
- before repair mode
- before code is considered complete

It SHOULD also run during:

- repository audit mode
- pull request review
- targeted refactor passes

---

# 3. Minimum Detection Scope

The detection pass MUST check at least:

- doctrine rule violations
- architecture rule violations
- aggregate state exposure violations
- anemic domain model signals
- ask-based design and hidden coupling signals

At minimum, it must detect the following aggregate state exposure patterns:

- public zero-argument methods on aggregates that primarily expose fields
- public aggregate accessors added for persistence, repository, read-model, or query convenience
- comment markers such as `Query Accessors`, `Read Model Accessors`, `used for read models`, `used for repository lookups`, or `do not use for decision-making`
- aggregates returning raw collections or status values for external branching

---

# 4. Enforcement Interpretation

The following are violations, not exceptions:

- "Accessor methods for read models"
- "Accessor methods for repository lookups"
- comments that warn consumers not to misuse exposed state

Warning comments do not neutralize the violation.

If state must cross a boundary, compliant alternatives are:

- explicit snapshot or projection methods returning dedicated types
- read-side models built outside the aggregate
- infrastructure mapping approaches that do not widen the aggregate public API

---

# 5. Required Inputs

The detection pass MUST load:

- `principles/software-principles.md`
- `principles/code-rules.md`
- `principles/code-anti-patterns.md`
- `standards/architecture-enforcement-spec.md`
- `structure/repair-governance-spec.md`
- detection prompts relevant to the current task

For implementation-stage aggregate API review, this includes:

- `agents/implementation/detect-anemic-domain-model.md`
- `agents/implementation/detect-ask-based-design-and-hidden-coupling.md`
- `agents/implementation/detect-aggregate-state-exposure-violations.md`

---

# 6. Output Contract

If violations are found, produce a violation report containing:

- file
- violated rule
- evidence
- explanation
- suggested fix direction
- whether repair is allowed under repair governance

If no violations are found, the detector should state that explicitly.

---

# 7. Repair Boundary

Violation detection may trigger repair, but detection itself MUST NOT:

- invent new public behavior
- widen aggregate APIs
- redesign architecture
- reinterpret warning comments as approval

Repairs must remain inside `structure/repair-governance-spec.md`.

---

# 8. Acceptance Rule

Generated output is compliant only when:

- the violation detection pass has run
- the resulting violation report is empty
- any repair actions stayed within repair governance
