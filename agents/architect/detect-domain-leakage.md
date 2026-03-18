# Prompt: Detect Domain Leakage

Version: 1.0.0

## Goal

Systematically detect strategic and tactical domain leakage in brownfield bounded-context designs using explicit taxonomy IDs.

Use taxonomy IDs from:

- `principles/domain-leakage-taxonomy.md`

Use severity assignment from:

- `standards/domain-leakage-severity-standard.md`

## Scope

Focus on:

- concept ownership
- language contamination
- responsibility/authority misplacement
- integration-boundary translation gaps
- local model integrity degradation

Out of scope:

- pure formatting/style concerns
- low-level syntax-only feedback

## Operating Rules

Before pattern detection:

1. Identify all bounded contexts in review scope.
2. Map ownership for each key concept (single owning context).
3. Treat implicit boundaries as first-class findings.
4. Record uncertainty explicitly where evidence is incomplete.

## Detection Protocol

### Step 1 — Boundary Check

- Is boundary explicit and named?
  - If no: flag `BOUNDARY-00`
- Are concepts jointly owned by multiple contexts?
  - If yes: flag `BOUNDARY-01`
- Does one context span multiple subdomains?
  - If yes: flag `BOUNDARY-02`

### Step 2 — Language Audit

- Extract domain terms used by the context.
- For each term: can local domain experts define and own it independently?
  - If no due to borrowed semantics: flag `CROSS_CONTEXT-02`
  - If no due to foreign concept adoption: flag `CROSS_CONTEXT-01`

### Step 3 — Concept Ownership Audit

- Who controls lifecycle for each concept?
  - External owner controlling lifecycle: `RESPONSIBILITY-05`
- Who governs each invariant/rule?
  - Foreign rule authority: `RESPONSIBILITY-01` or `RESPONSIBILITY-03`
- Is inbound integration translated locally?
  - No translation: `CROSS_CONTEXT-06`

### Step 4 — Responsibility Audit

- Does this context decide for non-owned concepts?
  - `RESPONSIBILITY-03`
- Is this context becoming a decision sink?
  - `RESPONSIBILITY-02`
- Do invariants require cross-context synchronous coordination?
  - `RESPONSIBILITY-04`

### Step 5 — Process Audit

- Is multi-context process ownership centralized in one participating context?
  - `CROSS_CONTEXT-04`
- Is core domain conforming to external model without adaptation?
  - `CROSS_CONTEXT-05`
- Are foreign triggers modeled as internal rules?
  - `CROSS_CONTEXT-03`

### Step 6 — Model Integrity Audit

- Distinct concepts merged into one?
  - `MODEL_INTEGRITY-01`
- Generic/shared model compromising local precision?
  - `MODEL_INTEGRITY-02`
- Aggregate root/invariant boundary undefined?
  - `MODEL_INTEGRITY-03`
- Model diverges from current domain reality?
  - `MODEL_INTEGRITY-04`

### Step 7 — Classification and Severity

For each finding:

1. Assign exactly one taxonomy ID.
2. Classify structure as `STRUCTURAL` or `INCIDENTAL`.
3. Classify impact as `STRATEGIC` or `TACTICAL`.
4. Assign severity per `standards/domain-leakage-severity-standard.md`.

## Output Format

For each finding provide:

- `id`: taxonomy ID (for example `CROSS_CONTEXT-06`)
- `title`: concise pattern label
- `evidence`: concrete signal(s) observed
- `why_it_matters`: coupling/authority/model risk
- `severity`: `CRITICAL` | `HIGH` | `MEDIUM` | `LOW`
- `classification`: `STRUCTURAL|INCIDENTAL`, `STRATEGIC|TACTICAL`
- `remediation_direction`: pragmatic next step

## Constraints

- Do not assume all coupling is wrong.
- Ask who owns meaning before asserting leakage.
- Distinguish intentional integration from unowned authority transfer.
- Prefer evidence-backed findings over speculative purity.

