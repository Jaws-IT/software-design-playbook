# Prompt: Detect Aggregate State Exposure Violations

Version: 1.0.0

## Goal

Detect aggregate APIs and surrounding code patterns that widen the public surface for persistence, read-model convenience, or external decision-making.

This prompt is intended to run after code generation and during code review.

It focuses on a specific doctrine failure:

- aggregates exposing internal state through field-style public methods
- comments that justify state exposure instead of preserving aggregate boundaries
- query convenience APIs that encourage callers to ask, branch, and coordinate externally

## When to Use

Use this prompt when reviewing:

- newly generated aggregate code
- pull requests that add or expand aggregate APIs
- repair passes after implementation
- domain-layer refactors

Run it before accepting generated code as compliant.

## Doctrine Basis

Apply this prompt against the following rules:

- aggregates must contain behavior
- aggregates must not expose public accessor surfaces for persistence support, read-model support, repository convenience, or query convenience
- public aggregate methods must be intention-revealing and traceable to explicit domain language

## What to Look For

### Direct Violation Signals

Flag these as violations:

- public zero-argument methods on aggregates that return fields or collections with no business behavior
- `get*` or field-style method names added to aggregates for external inspection
- sections named `Query Accessors`, `Read Model Accessors`, or equivalent
- comments such as `used for read models`, `used for repository lookups`, or `do not use for decision-making`
- aggregate methods whose only purpose is exporting raw status, flags, timestamps, or collections to let callers decide what happens next

### Structural Smell Signals

Escalate for review when you see:

- aggregates with a growing surface of read-only methods unrelated to domain commands
- application code branching on raw aggregate state instead of invoking intention methods
- repositories or mappers requiring public aggregate accessors instead of snapshots or dedicated mapping approaches
- domain objects returning mutable or raw collections that callers can inspect for decisions

## Review Procedure

### Step 1 - Confirm the Type Is an Aggregate

Before flagging, verify that the reviewed type is acting as an aggregate or aggregate root in the domain model.

Do not apply this detector to:

- explicit read models
- DTOs
- projection types
- dedicated snapshot types

### Step 2 - Test Each Public Method for Behavioral Meaning

For each public aggregate method, ask:

- Does this method express business intent?
- Does it enforce or protect an invariant?
- Is it directly traceable to ubiquitous language or a requested behavior?
- Would external callers use it primarily to make decisions outside the aggregate?

If the answer is "external callers use it to inspect and branch", treat it as a violation.

### Step 3 - Check for Comment-Based Doctrine Evasion

Treat comments that justify state exposure as a smell, not an exception.

Examples:

- "for read-model use only"
- "repository lookup helper"
- "do not use for business logic"

These comments do not make the API compliant.

### Step 4 - Distinguish Allowed Alternatives

Do not flag these by default:

- explicit snapshot methods returning a dedicated snapshot or projection type
- query-side read models built outside the aggregate
- infrastructure-only reconstruction or mapping that does not widen the aggregate's public API
- intention-revealing predicates that are true domain behavior rather than field exposure

If unsure, ask whether the method exists because of domain language or because another layer wants easier access to state.

## Output Format

For each violation, report:

- file
- aggregate
- method or comment marker
- violated rule
- why it is a violation
- compliant replacement direction

## Suggested Fix Directions

Prefer one of these fixes:

- replace field-style public methods with an intention-revealing domain behavior
- introduce an explicit snapshot or projection type if state must cross a boundary
- move query needs to a read-side model
- keep infrastructure mapping outside the aggregate's public API
- remove comments that attempt to justify doctrine violations

## Constraints

- do not invent new aggregate behavior during detection
- do not approve a violation because a warning comment was added
- do not treat persistence convenience as a valid reason to widen aggregate APIs
- do not flag legitimate read-side models as aggregate violations
