# Prompt: Review Bounded Context Design

## Goal
Evaluate whether the proposed or existing bounded contexts reflect real differences in language, rules, and models, and identify risks related to coupling, leakage, or artificial boundaries.

This prompt is meant to be used with the DDD Architect role.

## Input

You may receive one or more of the following:

- A domain description
- A context map
- A list of services or modules
- API contracts
- Event flows
- Code structure
- Team descriptions
- Architecture diagrams

## Approach

Follow a question-first mindset:

1. Clarify understanding of the domain
2. Identify how concepts are used across areas
3. Detect where language, rules, or models diverge
4. Evaluate whether boundaries reflect real differences or technical structure
5. Highlight risks and suggest alternative boundary shapes

## Key Questions to Explore

### Language & Meaning
- Are the same terms used differently in different parts of the system?
- Do concepts change meaning depending on the context?
- Are teams implicitly sharing a model without realizing it?

### Rules & Logic
- Do different areas apply different business rules to the same concept?
- Are policies scattered across multiple services?
- Are invariants tied to a specific context, or leaking across boundaries?

### Model Shape
- Are data structures shared across contexts?
- Are multiple areas depending on the same internal representations?
- Does one context know too much about another?

### Coupling Signals
- Direct synchronous calls for core domain knowledge
- "GetData()" style dependencies between contexts
- Shared databases or shared entities
- Repeated mapping logic across multiple services

### Boundary Validity
- Are boundaries based on:
    - language differences?
    - rule differences?
    - model differences?

Or are they based on:
- technical layers?
- team ownership?
- legacy system structure?

## Findings

Produce a structured analysis:

### Observations
- What signals suggest real domain separation?
- What signals suggest artificial boundaries?

### Risks
- Where tight coupling is likely to emerge
- Where models may drift over time
- Where language confusion could lead to design issues

### Recommendations

Provide 2–3 possible directions, for example:

- Merge contexts that share the same language and rules
- Split areas where language and logic are diverging
- Introduce explicit collaboration instead of shared models
- Introduce a process/workflow layer for cross-context coordination

Explain trade-offs for each option.

### Questions for the Team

List key questions that must be answered to confirm or refine the boundaries, for example:

- Who owns the concept in business terms?
- Where do rules truly differ?
- Which team understands this concept best?
- Where does the meaning change?

## Constraints

- Do not assume the current boundaries are correct or incorrect
- Do not invent domain knowledge that is not provided
- Prefer exploration over prescription
- Highlight uncertainty when information is incomplete
