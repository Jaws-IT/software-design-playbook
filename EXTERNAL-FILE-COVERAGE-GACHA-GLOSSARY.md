# External File Coverage: GaCha `architecture/glossary.md`

Date: February 28, 2026  
Source file reviewed: `/Users/jespersorensen/IdeaProjects/Testbed/(to-be-merged)GaCha platform/docs/architecture/glossary.md`

## Verdict

This file is **not deletion-ready**.

Unlike the GaCha `software-principles.md` file, this glossary is not substantially preserved in the playbook today.

The playbook contains scattered examples and some related concepts, but it does not contain an authoritative terminology document or enough equivalent coverage to safely delete this glossary.

## Recommended Decision

`Delete After Porting` or `Keep as Project-Local`

Do not delete it now.

## Why

This glossary contains four kinds of information that are currently weak or missing in the playbook:

- bounded-context-specific canonical terms
- cross-cutting term ownership
- strategy name semantics
- legacy-to-new term migration mapping

Those are not replaceable by general doctrine documents.

## Coverage Matrix

| Glossary area | Source lines | Playbook coverage | Coverage | Notes |
|---|---:|---|---|---|
| Capacity BC terms | 12-20 | Fragmentary mentions only | Low | `ClaimedSlot` and `ResourceId` appear only as examples, not as glossary definitions. |
| Execution Planning BC terms | 22-32 | Very limited | Low | `PlanningWindow` appears incidentally, most terms absent as authoritative definitions. |
| Sales BC terms | 34-41 | Very limited | Low | `AppointmentProcess`, `AppointmentIntent`, `AppointmentRequest`, `ServiceOffering` are not documented as canonical terms in the playbook. |
| Service Catalog BC terms | 43-48 | Very limited | Low | `WorkSpecification` and `QualificationType` are not preserved as glossary entries. |
| Cross-cutting terms | 52-58 | Partial | Low | `CorrelationId` and `TimeSlot` are not maintained in a glossary form. |
| Strategy terms | 62-73 | Missing as glossary | Low | Strategy names and their exact semantics are not documented in the playbook. |
| Legacy term mapping | 77-86 | Missing | None | No equivalent migration mapping found. |
| Filter vs Enforce distinction | 90-103 | Partially present as general doctrine | Partial | The idea exists, but not with this vocabulary or matrix. |
| Capacity internal vs external language | 107-117 | Partially present as doctrine | Partial | The boundary idea exists, but the exact language mapping is missing. |
| Anti-pattern term corrections | 121-130 | Partial | Partial | Some principles align, but the domain vocabulary corrections are not preserved. |

## Exact Findings

### 1. No real glossary artifact exists in the playbook

The playbook currently has no dedicated glossary file comparable to the GaCha glossary.

This alone makes deletion risky.

### 2. Domain vocabulary is mostly missing

These terms appear to be missing as canonical documented concepts in the playbook:

- `ResourceAllocation`
- `ResourceProfile`
- `ExecutionPlanCandidate`
- `StepRequirement`
- `StepSuggestion`
- `ExecutionTemplate`
- `ExecutionStep`
- `SelectedResource`
- `AppointmentProcess`
- `AppointmentIntent`
- `AppointmentRequest`
- `ServiceOffering`
- `WorkSpecification`
- `QualificationType`

Some of them may exist in application code elsewhere, but they are not preserved here as shared language.

### 3. Strategy semantics are missing

The strategy matrix at lines 62-73 is domain-specific knowledge, not generic architecture doctrine.

It is not represented in the playbook as of this review.

### 4. Legacy migration mapping is missing

The migration table at lines 77-86 is uniquely valuable because it explains how older terms map to the newer model.

That kind of knowledge is easy to lose and hard to reconstruct later.

### 5. The “Filter vs Enforce” distinction is only partially preserved

The playbook contains related architectural ideas about boundaries and responsibility, but not this exact domain distinction:

- filtering at execution-planning query time
- enforcement at appointment/company command time
- capacity protecting consistency

This should be preserved more explicitly if the glossary is deleted.

### 6. Internal vs external language mapping is only partially preserved

The glossary’s separation between:

- internal Capacity language such as `claim` and `confirm`
- external language such as `AllocateResourcesForAppointment`

is architecturally important and not adequately captured in the current playbook.

## Recommendation for Porting

If you want this file eventually deletable, the playbook should gain at least:

1. A glossary artifact for canonical domain terms.
2. A bounded-context terminology section or separate domain-language file.
3. The strategy naming matrix.
4. The legacy term migration mapping.
5. The filter-vs-enforce distinction in explicit domain language.
6. The internal-vs-external capacity language rule.

## Suggested Minimal Port

The minimum safe subset to port before deletion is:

- all bounded-context term tables
- cross-cutting term ownership table
- strategy terms table
- legacy term mapping table
- filter vs enforce table
- capacity internal vs external language section

## Final Recommendation

Do not delete `/Users/jespersorensen/IdeaProjects/Testbed/(to-be-merged)GaCha platform/docs/architecture/glossary.md`.

This is a knowledge-preservation file, not a duplicate doctrine file.
