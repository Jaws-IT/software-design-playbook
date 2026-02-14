# Prompt: Detect Generic Modeling

## Goal

Identify when domain concepts are modeled too generically, potentially hiding important differences in meaning, rules, and behavior.

This prompt is intended to be used with the DDD Architect role.

The purpose is not to reject abstraction, but to detect when abstraction is introduced too early and risks flattening the domain.

## When to Use

Use this prompt when reviewing:

- Early domain models
- Context maps
- Requirements
- Workshops notes
- API designs
- Concept discussions
- Architecture proposals

This prompt is most useful before or during strategic design, when language and concepts are still forming.

## What to Look For

### Generic Concept Signals

Watch for concepts such as:

- User
- Party
- Entity
- Profile
- Record
- Object
- Generic “core” models
- Canonical models intended to serve many domains

These may be valid, but they often hide real domain distinctions.

## Step 1 — Ask Clarifying Questions

Start by exploring meaning, not by rejecting the model.

Examples:

- What kinds of "users" exist in this domain?
- Do these actors behave differently?
- Do different rules apply to them?
- Would the business describe them using the same word?
- Does the term come from the domain, or from us?

Goal:
Surface whether multiple real concepts are being flattened into one.

## Step 2 — Suggest Possible Domain-Specific Alternatives

If the concept seems too generic, explore more concrete possibilities:

Examples:

- Instead of "User":
    - Employee?
    - Customer?
    - Accountant?
    - Broker?
    - Administrator?

- Instead of "Party":
    - Policy holder?
    - Supplier?
    - Partner?
    - Client?

Frame this as exploration, not correction.

## Step 3 — Explain the Risk

If generic modeling is likely masking domain differences, explain why this can become a problem later.

Examples of risks to surface:

- Different actors with different rules forced into one model
- Conditional logic spreading across the system
- Boundaries becoming unclear
- Language drifting between teams
- Hidden coupling through shared abstractions
- Difficulty evolving the model over time

Connect the abstraction to future design friction.

## Signals of Flattened Domains

Highlight when you notice:

- Multiple actors sharing one generic concept
- Different responsibilities represented by the same model
- Different lifecycle rules being forced into one structure
- Teams using the same term but meaning different things

## Desired Outcome

Help the team move toward:

- More concrete, domain-driven language
- Concepts rooted in how the business actually speaks
- Earlier discovery of where rules and behavior diverge
- Better foundations for identifying real boundaries

## Constraints

- Do not assume the generic concept is wrong
- Ask before challenging
- Suggest alternatives, do not impose them
- Recognize when a shared abstraction is intentionally valid
