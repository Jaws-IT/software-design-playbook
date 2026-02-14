# Prompt: Detect Hidden Coupling

## Goal

Identify hidden forms of coupling across bounded contexts, services, and teams, and explain how these create systemic risk through failure chaining and loss of autonomy.

This prompt is intended to be used with the DDD Architect role.

It focuses on coupling that is not immediately visible in code structure but emerges through:
- shared data
- shared semantics
- misplaced responsibilities
- synchronous dependency chains
- authority leakage

## Why This Matters

Loose coupling is fundamentally about risk management.

When systems become tightly coupled:

- Failures propagate across boundaries
- Small changes create widespread impact
- Teams lose autonomy
- Deployments become fragile
- System stability degrades

Hidden coupling increases the blast radius of incidents and makes systems harder to evolve safely.

## When to Use

Use this prompt when reviewing:

- Architecture designs
- Context maps
- Integration flows
- APIs and contracts
- Data sharing patterns
- Service dependencies
- UI ↔ backend responsibility splits
- Cross-context decision logic

## Step 1 — Identify Dependency Chains

Look for signs that one part of the system depends on another to function:

Signals:

- Multiple synchronous calls required to complete one action
- "Read from A → decide in B → act in C" flows
- Services waiting on each other to proceed
- Long call chains across contexts

Ask:

- What happens if this dependency is slow?
- What happens if it is temporarily unavailable?

## Step 2 — Detect Responsibility Leakage

Look for places where one context is solving problems that belong to another.

Signals:

- A service making decisions using another domain’s data
- Logic implemented outside the context that owns the rules
- Cross-context validation logic

Ask:

- Who actually owns this decision?
- Why is it being made here?

## Step 3 — Detect Authority Leakage Through Data Sharing

Surface cases where sharing data transfers control implicitly.

Examples:

- Exposing internal fields in APIs
- Publishing values without context or meaning
- Sharing raw domain data instead of facts or intentions

Explain the risk:

- Consumers interpret data differently
- Semantics drift over time
- Internal changes break external assumptions
- Control over meaning is lost

Ask:

- Are we sharing data, or sharing facts?
- Are we handing over authority unintentionally?

## Step 4 — Detect Semantic Coupling

Look for coupling through meaning, not just structure.

Signals:

- Multiple systems interpreting the same field differently
- Shared terms used with different meanings
- Teams relying on knowledge of another context’s internals

Ask:

- Do both sides mean the same thing when they use this term?
- Is this concept truly shared, or just reused?

## Step 5 — Detect Structural Coupling

Look for hard structural dependencies:

- Shared databases
- Shared entities or models
- Direct reuse of internal structures
- Tight UI ↔ backend knowledge of internal models

These create strong constraints on change.

## Step 6 — Connect to Risk

Explain the real-world impact:

Hidden coupling increases:

- Failure chaining risk
- Incident blast radius
- Change coordination cost
- Deployment friction
- System fragility

Frame findings in terms of:

- stability
- resilience
- operational risk
- long-term maintainability

## Observations to Surface

Call out when you see:

- One context needing another to function correctly
- Decision logic spread across multiple contexts
- Internal data exposed as external contracts
- Shared assumptions about meaning
- UI making domain decisions
- Data pulled across boundaries to solve local problems

## Suggested Directions

Offer possible improvement paths, for example:

- Move decisions to the owning context
- Replace data exposure with intent or facts
- Reduce synchronous dependencies
- Clarify ownership of concepts
- Introduce event-based collaboration where appropriate

## Constraints

- Do not assume all dependencies are wrong
- Ask before judging intent
- Suggest improvements, not mandates
- Recognize that some coupling is necessary and intentional
- Focus on risk, not purity
