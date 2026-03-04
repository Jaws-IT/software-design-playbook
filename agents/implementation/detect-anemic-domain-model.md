# Prompt: Detect Anemic Domain Model

## Goal

Identify when domain models are reduced to data structures with little or no behavior, causing business logic to drift into services, handlers, or utilities.

This prompt is intended to be used with the DDD Architect role.

It focuses on tactical design and code-level signals that indicate loss of domain integrity.

## When to Use

Use this prompt when reviewing:

- Pull requests
- Aggregates and entities
- Class designs
- Application services
- Command handlers
- Domain layer structure

This prompt assumes that code or class-level models exist.

## What to Look For

### Behavioral Emptiness Signals

Look for domain objects that:

- Mostly contain fields/getters/setters
- Have little or no meaningful behavior
- Do not enforce invariants
- Act as data containers

Examples:

- Entities with only properties
- Aggregates that expose state but do not protect it
- Domain objects that are never asked to "do" anything

## Step 1 — Ask Clarifying Questions

Before concluding, explore intent:

- Where does the business logic live?
- Are invariants enforced inside the aggregate?
- Are domain objects expected to own behavior?
- Is this intentionally a simple data carrier, or is it supposed to model a concept?

Goal:
Understand whether the lack of behavior is intentional or accidental.

## Step 2 — Detect Logic Displacement

Look for logic that should belong to the domain but is placed elsewhere:

Common locations:

- Application services
- Command handlers
- Utility classes
- Static helpers
- Orchestration code

Signals:

- Services making business decisions
- Handlers manipulating domain state directly
- External code validating invariants
- Repeated rule checks scattered across the system

## Step 3 — Suggest Behavior Placement

If anemic modeling is detected, suggest moving logic closer to the domain concept.

Examples:

- Move rule validation into the aggregate
- Move state transitions into domain methods
- Replace setters with intent-driven operations
- Let the domain object protect its own invariants

Frame as:

- "Could this behavior live inside the aggregate?"
- "Should this rule be owned by the domain object itself?"

## Step 4 — Explain the Risk

If anemic modeling persists, explain long-term consequences:

- Invariants enforced inconsistently
- Logic duplication across services
- Hard-to-understand business rules
- Increasing coupling
- Fragile models that are easy to misuse
- Loss of domain meaning

Connect current structure to future maintenance pain.

## Structural Signals of Anemic Design

Highlight when you see:

- Domain classes with many setters
- Application services that contain most business logic
- Aggregates that only expose state
- Decision-making outside the domain layer
- State transitions performed externally

## Desired Outcome

Help the team move toward:

- Behavior-rich domain models
- Aggregates that protect invariants
- Intent-driven operations instead of setters
- Business logic placed close to the concepts it belongs to

## Constraints

- Do not assume every object must be behavior-heavy
- Recognize when simple data structures are appropriate
- Ask before challenging design intent
- Focus on business logic, not technical utilities
