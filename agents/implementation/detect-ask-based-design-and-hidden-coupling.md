# Prompt: Detect Ask-Based Design and Hidden Coupling

Version: 1.0.0

## Goal

Identify where systems expose data through "get" style interactions instead of expressing intent, leading to hidden coupling and increased risk of failure chaining.

This prompt is intended to be used with the DDD Architect role.

It focuses on detecting the root causes of tight coupling:
- Ask-based APIs
- Data exposure
- Orchestration through reads
- Hidden dependency creation

## Why This Matters

Loose coupling is fundamentally about risk management.

When systems depend on each other through data retrieval chains, failures can propagate:

- One service slows down → others wait
- One component fails → multiple flows break
- One change → ripple effects across the system

This increases the blast radius of failures.

Intent-driven design reduces this risk by:
- Encapsulating behavior
- Limiting dependencies
- Reducing synchronous calls
- Keeping responsibilities local

## When to Use

Use this prompt when reviewing:

- APIs
- Service interactions
- Application services
- Command handlers
- Integration logic
- Cross-context communication
- Codebases with many read-before-act flows

## What to Look For

### Ask-Based Interaction Signals

Look for method names and patterns such as:

- getAccount()
- fetchCustomer()
- loadUser()
- retrieveOrder()
- readThenAct flows

These often indicate that a component is:
- Pulling data to make decisions externally
- Taking responsibility that belongs elsewhere

## Step 1 — Ask the Intention Question

When you see a "get" call, start with:

- What is the real intention behind this call?
- What are we trying to achieve?
- What decision is being made after retrieving this data?

Example:

Instead of:
- getAccount()

Ask:
- Are we trying to validate currency?
- Check balance?
- Confirm eligibility?
- Authorize an action?

The "get" is rarely the real goal.

## Step 2 — Suggest Tell-Style Alternatives

Explore whether the interaction could be expressed as an intention instead:

Examples:

Instead of:
- getAccount() → check currency externally

Consider:
- account.supportsCurrency(currency)
- account.validateCurrency(currency)

Instead of:
- getCustomer() → evaluate eligibility

Consider:
- customer.isEligibleFor(product)

Shift from:
- asking for data
  to:
- telling the domain what you want to achieve

## Step 3 — Detect Hidden Coupling

Highlight where ask-based design creates dependencies:

Signals:

- Services needing internal data from other services
- Repeated cross-context reads before every action
- Decision logic outside the owning domain
- Long synchronous call chains

These patterns often indicate:

- Responsibility leakage
- Tight runtime coupling
- Fragile interactions

## Step 4 — Explain the Risk

Connect the design to real-world consequences.

Surface risks such as:

- Cascading failures when one dependency is slow or down
- Increased blast radius of incidents
- Difficult deployments due to hidden dependencies
- Small changes causing widespread impact
- Systems becoming harder to evolve independently

Frame this as risk management, not technical purity.

## Observations to Surface

Call out when you see:

- "GetData → then decide" patterns
- Services acting as decision-makers using other domains' data
- Synchronous dependency chains across contexts
- Data exposure instead of behavior exposure

## Desired Outcome

Help the team move toward:

- Intention-driven APIs
- Behavior-focused domain models
- Reduced synchronous dependencies
- Clearer ownership of decisions
- Lower risk of failure chaining

## Constraints

- Do not assume all reads are wrong
- Ask before challenging design intent
- Suggest alternatives, not mandates
- Recognize valid query/read models in CQRS
- Focus on risk and coupling, not stylistic preference
