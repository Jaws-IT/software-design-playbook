# External File Coverage: GaCha `software-principles.md`

Date: February 28, 2026  
Source file reviewed: `/Users/jespersorensen/IdeaProjects/Testbed/(to-be-merged)GaCha platform/docs/architecture/software-principles.md`

## Purpose

This report checks whether the doctrine in the GaCha architecture file is still present in the playbook before that source file is deleted.

## Verdict

The principle content is covered in the playbook.

Deletion of the GaCha file would not remove unique principle doctrine from the playbook based on this review.

The only notable non-playbook item in the GaCha file is its project-local case study reference:

- `../case-studies/multi-aggregate-coordination-learning-journey.md`

That link exists in the GaCha docs tree but is not part of this playbook repository.

## Coverage Matrix

| External section | Source lines | Playbook location | Coverage | Notes |
|---|---:|---|---|---|
| `Extremefy` | 7-41 | [patterns/strategic-design-patterns.md](/Users/jespersorensen/IdeaProjects/jaws-it/software-design-playbook/patterns/strategic-design-patterns.md) | Full | The playbook version is broader and more detailed. |
| `Aggregate Transaction Boundary` | 45-76 | [patterns/strategic-design-patterns.md](/Users/jespersorensen/IdeaProjects/jaws-it/software-design-playbook/patterns/strategic-design-patterns.md) | Full | Same principle, expanded with smell/fix/decision guidance. |
| `Complexity Must Earn Its Keep` | 80-105 | [patterns/strategic-design-patterns.md](/Users/jespersorensen/IdeaProjects/jaws-it/software-design-playbook/patterns/strategic-design-patterns.md) | Full | Present as a strategic validation pattern. |
| `Validation Belongs in State-Changing Operations` | 109-130 | [patterns/strategic-design-patterns.md](/Users/jespersorensen/IdeaProjects/jaws-it/software-design-playbook/patterns/strategic-design-patterns.md) and [standards/coding-standards.md](/Users/jespersorensen/IdeaProjects/jaws-it/software-design-playbook/standards/coding-standards.md) | Full | Covered both conceptually and as a coding rule. |
| `Clock Abstraction for Time Dependencies` | 134-164 | [patterns/strategic-design-patterns.md](/Users/jespersorensen/IdeaProjects/jaws-it/software-design-playbook/patterns/strategic-design-patterns.md) and [standards/coding-standards.md](/Users/jespersorensen/IdeaProjects/jaws-it/software-design-playbook/standards/coding-standards.md) | Full | Present both as pattern and enforceable coding guidance. |
| `Infrastructure Naming Must Be Mechanism-Only` | 168-195 | [standards/architecture-enforcement-spec.md](/Users/jespersorensen/IdeaProjects/jaws-it/software-design-playbook/standards/architecture-enforcement-spec.md) | Full | The playbook version is more authoritative and operationalized. |

## Exact Mapping Notes

### Extremefy

- External source: lines 7-41
- Playbook heading: [patterns/strategic-design-patterns.md](/Users/jespersorensen/IdeaProjects/jaws-it/software-design-playbook/patterns/strategic-design-patterns.md) at line 19

The playbook contains the same definition, technique, scale-question framing, examples, and application guidance, plus additional decision support and worked examples.

### Aggregate Transaction Boundary

- External source: lines 45-76
- Playbook heading: [patterns/strategic-design-patterns.md](/Users/jespersorensen/IdeaProjects/jaws-it/software-design-playbook/patterns/strategic-design-patterns.md) at line 410

The playbook contains the same transactional-boundary doctrine and expands it with explicit saga guidance and decision tests.

### Complexity Must Earn Its Keep

- External source: lines 80-105
- Playbook heading: [patterns/strategic-design-patterns.md](/Users/jespersorensen/IdeaProjects/jaws-it/software-design-playbook/patterns/strategic-design-patterns.md) at line 260

The principle is present and more developed in the playbook.

### Validation Belongs in State-Changing Operations

- External source: lines 109-130
- Playbook headings:
  - [patterns/strategic-design-patterns.md](/Users/jespersorensen/IdeaProjects/jaws-it/software-design-playbook/patterns/strategic-design-patterns.md)
  - [standards/coding-standards.md](/Users/jespersorensen/IdeaProjects/jaws-it/software-design-playbook/standards/coding-standards.md) at line 29

The playbook preserves both the principle and the concrete coding consequence: no separate validation functions returning `Unit`.

### Clock Abstraction for Time Dependencies

- External source: lines 134-164
- Playbook headings:
  - [patterns/strategic-design-patterns.md](/Users/jespersorensen/IdeaProjects/jaws-it/software-design-playbook/patterns/strategic-design-patterns.md) at line 697
  - [standards/coding-standards.md](/Users/jespersorensen/IdeaProjects/jaws-it/software-design-playbook/standards/coding-standards.md) at line 41

The playbook covers the same doctrine and gives both architectural and coding-rule forms.

### Infrastructure Naming Must Be Mechanism-Only

- External source: lines 168-195
- Playbook headings:
  - [standards/architecture-enforcement-spec.md](/Users/jespersorensen/IdeaProjects/jaws-it/software-design-playbook/standards/architecture-enforcement-spec.md) at line 230
  - [standards/architecture-enforcement-spec.md](/Users/jespersorensen/IdeaProjects/jaws-it/software-design-playbook/standards/architecture-enforcement-spec.md) at line 238
  - [standards/architecture-enforcement-spec.md](/Users/jespersorensen/IdeaProjects/jaws-it/software-design-playbook/standards/architecture-enforcement-spec.md) at line 254
  - [standards/architecture-enforcement-spec.md](/Users/jespersorensen/IdeaProjects/jaws-it/software-design-playbook/standards/architecture-enforcement-spec.md) at line 302
  - [standards/architecture-enforcement-spec.md](/Users/jespersorensen/IdeaProjects/jaws-it/software-design-playbook/standards/architecture-enforcement-spec.md) at line 317
  - [standards/architecture-enforcement-spec.md](/Users/jespersorensen/IdeaProjects/jaws-it/software-design-playbook/standards/architecture-enforcement-spec.md) at line 332

This principle is not only present in the playbook; it is more formalized there.

## Missing or Not Directly Ported

- The GaCha file's opening sentence is not preserved as a standalone intro, but that is packaging rather than doctrine.
- The GaCha file's case study link is external to this playbook and is not represented here.

## Recommendation

From a doctrine-preservation perspective, the GaCha `software-principles.md` file can be deleted.

Keep it only if you still need one of these:

- a single project-local summary document for GaCha readers
- the project-local link to the GaCha case study
- a local architecture-doc navigation entry in that repository

## What To Do Next

Based on this result, the correct next move is to continue auditing the other external files.

Do not pause to backfill the playbook for this file unless you explicitly want to import the GaCha case study reference or preserve the single-document packaging style.
