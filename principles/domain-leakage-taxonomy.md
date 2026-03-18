# Domain Leakage Taxonomy

Version: 1.0.0

Status: Authoritative  
Scope: Domain leakage classification for bounded-context analysis  
Applies to: Agent reviews, architecture reviews, brownfield model audits

---

## 1. Purpose

This taxonomy defines a single, explicit classification language for domain leakage findings.

It standardizes:

- leakage category names
- stable finding identifiers
- detection signals
- remediation direction

The taxonomy is classification-only.
Detection workflow is defined in:

- `agents/architect/detect-domain-leakage.md`

Severity assignment is defined in:

- `standards/domain-leakage-severity-standard.md`

---

## 2. Naming and Identifier Rules

Identifiers must use explicit, readable prefixes.

Format:

`<CATEGORY>-<NN>`

Examples:

- `BOUNDARY-00`
- `CROSS_CONTEXT-06`
- `RESPONSIBILITY-03`
- `MODEL_INTEGRITY-02`

Rules:

- IDs are immutable once published.
- Pattern names may evolve; IDs may not.
- Every finding in agent output must include exactly one pattern ID.

---

## 3. Categories

### 3.1 `BOUNDARY-*` — Boundary Identity Failures

Boundary definition or ownership seams are missing or collapsed.

### 3.2 `CROSS_CONTEXT-*` — Cross-Context Coupling Leakage

Concepts, semantics, or process ownership leak across context boundaries.

### 3.3 `RESPONSIBILITY-*` — Domain Responsibility Misplacement

Authority, rules, or lifecycle decisions are made by non-owning contexts.

### 3.4 `MODEL_INTEGRITY-*` — Model Integrity Failures

The local domain model loses precision, clarity, or behavioral correctness.

---

## 4. Pattern Catalog

## 4.1 Boundary Identity Failures

### `BOUNDARY-00` — Missing or Implicit Bounded Context

Definition:
No explicit bounded context boundary exists.

Detection signals:

- a single model serves all business areas
- unqualified terms ("Customer", "Order") across divergent domains
- cross-area teams modifying the same concept without context ownership

Remediation direction:
Run boundary discovery (for example event storming), identify language seams, and declare explicit bounded contexts.

### `BOUNDARY-01` — Overlapping Context Ownership

Definition:
Two or more bounded contexts claim ownership of the same concept without explicit shared-kernel or translation strategy.

Detection signals:

- concept is "core" to multiple contexts
- parallel evolution causes semantic divergence
- stakeholders disagree on concept meaning by context

Remediation direction:
Choose explicit shared kernel with constrained contract, or split ownership with translation.

### `BOUNDARY-02` — God Context (No Subdomain Decomposition)

Definition:
One context spans multiple subdomains and hides internal leakage.

Detection signals:

- generic context naming ("Core", "Backend", "Platform")
- mixed concept set from separate business capabilities
- multiple domain-expert groups needed to explain one model

Remediation direction:
Extract subdomain seams and define candidate future contexts.

## 4.2 Cross-Context Coupling Leakage

### `CROSS_CONTEXT-01` — Foreign Concept Absorption

Definition:
A context adopts a foreign concept it does not own, without translation.

Detection signals:

- concept rules and lifecycle are governed externally
- local experts cannot justify concept presence
- concept changes are driven by another team/system

Remediation direction:
Replace with local representation and explicit boundary translation.

### `CROSS_CONTEXT-02` — Ubiquitous Language Contamination

Definition:
Terms from one context are reused in another with semantic drift or hidden coupling.

Detection signals:

- same term, different meaning, no disambiguation
- local experts rely on foreign terminology they do not own
- ambiguous cross-context language in core model artifacts

Remediation direction:
Rename locally and translate explicitly at boundaries.

### `CROSS_CONTEXT-03` — Causal Dependency Inversion

Definition:
Context behavior is driven by external context state/events, but modeled as internal rules.

Detection signals:

- rule encoded as if local but trigger is foreign
- trigger not represented as explicit integration event
- trigger changes force core-logic edits in dependent context

Remediation direction:
Model foreign trigger as integration input; react rather than internalize ownership.

### `CROSS_CONTEXT-04` — Cross-Context Process Ownership

Definition:
A workflow spanning multiple contexts is owned entirely by one participating context.

Detection signals:

- one context decides behavior of peers
- process state machine embeds other-context internals
- saga/workflow tightly coupled to multiple context internals

Remediation direction:
Move to explicit orchestration context, or decompose into event choreography.

### `CROSS_CONTEXT-05` — Conformist Trap in Core Domain

Definition:
Core domain mirrors a foreign or commodity model without adaptation.

Detection signals:

- 1:1 model mirroring from external/supporting context
- core experts operate with foreign language
- differentiation constrained by external model assumptions

Remediation direction:
Add anti-corruption translation and reassert core-domain language ownership.

### `CROSS_CONTEXT-06` — Missing Translation at Integration Boundary

Definition:
Receiver consumes sender model directly with no local mapping.

Detection signals:

- upstream contracts used verbatim in downstream business logic
- no local interpretation layer ("what this means to us")
- upstream refactors silently alter downstream behavior

Remediation direction:
Require explicit mapping/translation at every boundary.

## 4.3 Domain Responsibility Misplacement

### `RESPONSIBILITY-01` — Misowned Business Rule

Definition:
A context enforces a rule over a concept owned by another context.

Detection signals:

- rule depends on foreign-owned state
- local experts cannot justify ownership
- rule breaks when foreign semantics evolve

Remediation direction:
Move rule to owning context and publish outcomes across boundaries.

### `RESPONSIBILITY-02` — Responsibility Gravity (Implicit God Context)

Definition:
One context passively accumulates authority beyond assigned domain scope.

Detection signals:

- repeated cross-context query-before-decide behavior
- one context consulted for unrelated domain decisions
- model growth from multiple satellite concerns

Remediation direction:
Audit decision ownership and relocate decisions to authoritative contexts.

### `RESPONSIBILITY-03` — Decision Without Authority

Definition:
A context makes domain decisions for concepts it does not own.

Detection signals:

- status/validity/eligibility decided by non-owner context
- duplicate or conflicting decisions with owner context
- no explicit delegation from owner

Remediation direction:
Owner publishes decision fact/policy; non-owner consumes, does not author.

### `RESPONSIBILITY-04` — Shared Business Invariant Across Contexts

Definition:
Invariant requires synchronous coordination across contexts.

Detection signals:

- invariant enforcement needs multi-context state reads
- rollback assumptions across context boundaries
- teams cannot enforce independently

Remediation direction:
Prefer eventual consistency, reframe boundary, or use explicit saga with compensation.

### `RESPONSIBILITY-05` — Lifecycle Mismatch

Definition:
Lifecycle transitions are controlled by non-owning context.

Detection signals:

- foreign context creates/terminates concept instances
- state model owned in one context, transitions executed in another
- ownership disputes among domain experts

Remediation direction:
Unify lifecycle authority in owning context; others send requests.

## 4.4 Model Integrity Failures

### `MODEL_INTEGRITY-01` — Concept Conflation

Definition:
Distinct concepts merged into one model element.

Detection signals:

- conditional behavior branches by use-case mode
- incompatible semantic interpretations by stakeholder groups
- mutually exclusive states stuffed into one concept

Remediation direction:
Split into context-specific models with explicit ownership.

### `MODEL_INTEGRITY-02` — Premature Generalization

Definition:
Concept generalized for reuse across contexts at the cost of local precision.

Detection signals:

- "generic/shared" concept justification
- optional fields serving unrelated contexts
- cross-team contention over concept evolution

Remediation direction:
Prefer intentional duplication with translation over shared generic models.

### `MODEL_INTEGRITY-03` — Implicit Aggregate Boundary

Definition:
Aggregate consistency boundary is undefined.

Detection signals:

- unclear aggregate root ownership
- multiple parties mutate what should be one consistent unit
- invariants enforced across loosely coupled objects without root control

Remediation direction:
Define aggregate root and invariants explicitly; enforce root-only mutation.

### `MODEL_INTEGRITY-04` — Stale Context Model (Reality Drift)

Definition:
Model no longer reflects active business reality.

Detection signals:

- domain rules exist only in team memory/workarounds
- unexplained legacy fields/states persist
- logic moved into callers instead of model behavior

Remediation direction:
Run model/domain expert review and close concept/rule gaps.

---

## 5. Quick Reference

| ID | Pattern |
|---|---|
| `BOUNDARY-00` | Missing or Implicit Bounded Context |
| `BOUNDARY-01` | Overlapping Context Ownership |
| `BOUNDARY-02` | God Context |
| `CROSS_CONTEXT-01` | Foreign Concept Absorption |
| `CROSS_CONTEXT-02` | Ubiquitous Language Contamination |
| `CROSS_CONTEXT-03` | Causal Dependency Inversion |
| `CROSS_CONTEXT-04` | Cross-Context Process Ownership |
| `CROSS_CONTEXT-05` | Conformist Trap in Core Domain |
| `CROSS_CONTEXT-06` | Missing Translation at Integration Boundary |
| `RESPONSIBILITY-01` | Misowned Business Rule |
| `RESPONSIBILITY-02` | Responsibility Gravity |
| `RESPONSIBILITY-03` | Decision Without Authority |
| `RESPONSIBILITY-04` | Shared Business Invariant Across Contexts |
| `RESPONSIBILITY-05` | Lifecycle Mismatch |
| `MODEL_INTEGRITY-01` | Concept Conflation |
| `MODEL_INTEGRITY-02` | Premature Generalization |
| `MODEL_INTEGRITY-03` | Implicit Aggregate Boundary |
| `MODEL_INTEGRITY-04` | Stale Context Model |

---

End of Domain Leakage Taxonomy.
