# Software Design Playbook - Repository Structure

This is a Domain-Driven Design and software architecture documentation repository establishing principles, patterns, and governance for building scalable systems.

---

## `/agents/` — AI Agent Roles and Prompts

AI prompt definitions and role specifications for architecture governance and code generation. Contains three specialized agent roles that form the project workflow pipeline.

### `/agents/domain-analyst/`

| File | Description |
|------|-------------|
| `role.md` | Domain Analyst agent: first agent in workflow, discovers ubiquitous language, identifies bounded contexts, surfaces aggregates and invariants, detects premature abstraction. Produces ubiquitous language documents and context maps |

### `/agents/architect/`

| File | Description |
|------|-------------|
| `role.md` | Architect agent: translates domain understanding into architectural decisions, enforces boundaries, manages coupling, defines module structures. Uses mandatory reasoning sequence (ownership → coupling → intention → boundaries → process) |

### `/agents/implementation/`

| File | Description |
|------|-------------|
| `role.md` | Implementation agent: final agent in workflow, produces domain code using functional patterns, enforces domain purity, implements aggregates with behavior, uses Either/Result for error handling |

### `/agents/prompts/`

| File | Description |
|------|-------------|
| `architectural-integrity-constraints.md` | Non-negotiable rules for onion architecture, domain purity, cross-BC communication |
| `bounded-context-structure-constraints.md` | Mandatory constraints for module boundaries, layer dependencies, domain isolation |
| `detect-anemic-domain-model.md` | Prompt for identifying domain models lacking behavior |
| `detect-ask-based-design-and-hidden-coupling.md` | Detection for "get"-based APIs creating hidden coupling |
| `detect-generic-modeling.md` | Identifies overly generic domain concepts |
| `detect-hidden-coupling.md` | Identifies 6 forms of hidden coupling |
| `domain-discovery-facilitator.md` | Facilitates domain understanding before design |
| `functional-domain-constraints.md` | Constraints for functional domain code: immutability, no getters, intention-based APIs |
| `process-modeling-facilitator.md` | Helps reason about business processes and orchestration vs choreography |
| `review-bounded-context-design.md` | Evaluates whether BCs reflect real domain differences |

### `/agents/roles/`

| File | Description |
|------|-------------|
| `ddd-architect.md` | Role definition focusing on ubiquitous language, aggregates, intent-driven APIs |
| `system-governance.md` | "Architectural Prime Directive" - mandatory reasoning constraints for system integrity |

---

## `/architecture/` — System Architecture Patterns

Strategic architectural documentation defining high-level system design patterns.

| File | Description |
|------|-------------|
| `error-handling-model.md` | Three-tier failure classification with shared DomainError abstraction |

### `/architecture/frontend/`

| File | Description |
|------|-------------|
| `micro-frontend-canvas-architecture.md` | Canvas-based shell composition, forward-only state transitions, menu composition |

---

## `/examples/` — Reference Implementations

| File | Description |
|------|-------------|
| `PostgresSQLIdentityRegistryDAO.md` | Complete persistence adapter example with optimistic concurrency, Either-based error handling |

---

## `/patterns/` — Design and Implementation Patterns

Reusable patterns for tactical and strategic design decisions.

| File | Description |
|------|-------------|
| `architectural-decision-patterns.md` | Testing strategy hierarchy, architectural economics, coupling vs compute cost |
| `strategic-design-patterns.md` | Mental models: Extremefy, Complexity Must Earn Its Keep, Aggregate Transaction Boundary |
| `error-handling-patterns.md` | Functional error handling using Either for business validations |
| `testing-patterns.md` | F.I.R.S.T principles, behavior-focused testing, scale-aware testing |

### `/patterns/java/`

| File | Description |
|------|-------------|
| `java-vavr-either-orchestration-pattern.md` | Clean functional Java using Vavr Either, Tuple, flatMap chains |

### `/patterns/functional/`

| File | Description |
|------|-------------|
| `railway-state-transition-pattern.md` | Forward-only state machines with Either/Result types |

---

## `/principles/` — Foundational Software Principles

Core principles governing code quality, design, and architecture.

| File | Description |
|------|-------------|
| `foundational-principles.md` | Foundational philosophy and design principles: KISS, YAGNI, Dependency Inversion, Open/Closed, Single Responsibility, Fail Fast |
| `software-principles.md` | 11 core principles: Tell Don't Ask, Intention-Revealing Names, Explicit Over Implicit, etc. |
| `code-rules.md` | 16 coding rules: Domain Purity, Functional Error Handling, No Anemic Models, etc. |
| `code-anti-patterns.md` | 32 anti-patterns: god objects, primitive obsession, anemic models, train wreck code |
| `structural-anti-patterns.md` | 9 structural violations: illegal layer dependency, framework leakage, collapsed layers |

---

## `/standards/` — Enforcement Standards

Authoritative standards defining how playbook principles are enforced.

| File | Description |
|------|-------------|
| `architecture-enforcement-spec.md` | 17 rules: CI-failing (layer structure, domain purity) and advisory (naming, modeling) |
| `bounded-context-independence-doctrine.md` | Every BC must be independently implementable and testable |
| `clean-code-formatting.md` | Formatting principles: newspaper metaphor, vertical/horizontal formatting, pipeline rules |
| `coding-standards.md` | Kotlin 2.1 standards: functional-first, hexagonal layers, CQRS, event-driven design |
| `micro-frontend-ownership-standard.md` | Shell vs micro-frontend ownership, trigger ownership, history management |

---

## `/structure/` — Project Structure Specifications

Mandatory project organization patterns.

| File | Description |
|------|-------------|
| `bounded-context-module-structure.md` | Single Maven project per BC with domain/application/integration/infrastructure layers |
| `project-structure-specification.md` | Four required peer directories, no collapsing, outbound abstraction ownership |
| `repair-governance-spec.md` | AI repair boundaries: PLAN vs REPAIR phase, mutation thresholds (8 files, 500 lines) |

---

## `/tools/` — Automation and Operational Tools

Scripts and workflows for repository management and code generation.

| File | Description |
|------|-------------|
| `WORKFLOW.md` | Code generation flow: initialization, context building, generation, validation, repair |
| `PLAYBOOK-MAINTENANCE-WORKFLOW.md` | Governance for updates: prevents doctrine loss, mandatory pre-edit steps |

### `/tools/adapters/`

| File | Description |
|------|-------------|
| `claude.sh` | Shell adapter for Claude API integration |
| `openai.sh` | Shell adapter for OpenAI API integration |

### Scripts

| File | Description |
|------|-------------|
| `ai-pipeline.sh` | AI pipeline orchestration |
| `compose-doctrine.sh` | Doctrine composition script |
| `playbook-audit.sh` | Playbook audit and validation |

---

## Key Architectural Concepts

### Core Design Principles

1. **Tell Don't Ask** - Domain objects express intent; callers tell them what to do rather than querying state
2. **Intention-Revealing Names** - Method names must pass "the intention is..." test
3. **Onion Architecture** - Strict dependency direction: infrastructure → integration → application → domain
4. **Domain Purity** - Domain layer contains only business logic, never framework dependencies
5. **Functional Error Handling** - Business failures expressed via Either<Error, Success>, never thrown exceptions
6. **Explicit Boundaries** - Bounded contexts communicate through integration contracts only
7. **Forward-Only State** - All state transitions move forward; no implicit rollback or hidden control flow
8. **Intention-Driven APIs** - Public methods express business intent, not technical implementation

### Architectural Layers

| Layer | Responsibility |
|-------|----------------|
| **Domain** | Core business models, aggregates, value objects, domain events, repository interfaces; framework-independent |
| **Application** | Command/query handlers, use-case orchestration, application services |
| **Integration** | External contracts, integration events, commands, translation logic; technology-agnostic |
| **Infrastructure** | Controllers, messaging adapters, persistence implementations, framework configuration |

### Strategic Design Concepts

| Concept | Description |
|---------|-------------|
| **Bounded Contexts** | Isolated domain models with clear ownership and explicit collaboration |
| **Aggregates** | Transactional consistency boundaries; own invariants and state transitions |
| **Domain Events** | Internal facts representing state changes; colocated with aggregates |
| **Integration Events** | External contracts using business language; cross-context communication |
| **Railway Pattern** | Forward-moving state machines using Either/Result types for error handling |
| **Process Modeling** | Choreography (event reaction) vs Orchestration (stateful coordination) |
