# Doctrine Candidates: GaCha Docs

Date: February 28, 2026  
Source tree: `/Users/jespersorensen/IdeaProjects/Testbed/(to-be-merged)GaCha platform/docs`

## Purpose

This file resets the evaluation method.

Only files that express doctrine-level guidance should be compared against this playbook.

Files that are specific to the GaCha project, its domain model, its bounded contexts, its migration path, or its local decision history are not valid comparison targets for doctrine-preservation checks.

## Classification Rule

### Doctrine-level

A file is doctrine-level if it primarily defines:

- general software design principles
- architecture governance rules
- cross-project reasoning constraints
- reusable patterns or invariants stated above any single project model

### Project-level

A file is project-level if it primarily defines:

- GaCha-specific bounded contexts
- GaCha-specific glossary or terminology
- GaCha-specific strategies, algorithms, or workflows
- local ADRs
- migration history
- stories, rollout plans, or implementation maps
- generated context bundles or indexes

## Doctrine-Level Candidates

These are the only files in the GaCha docs tree that currently look valid for comparison against this playbook:

### Strong candidate

- `architecture/software-principles.md`

Reason:
This is clearly doctrine-level and has already been checked successfully against the playbook.

### Possible candidates that need case-by-case review

- `active-architecture-context.md`
- `architecture/README.md`
- `architecture/critical-invariants.md`

Reason:
These contain some high-level architectural guidance, but they are mixed with GaCha-specific concerns and may not be pure doctrine documents.

They should be reviewed carefully before being treated as doctrine targets.

## Not Doctrine-Level

These should not be judged by whether they are preserved in the playbook.

### Project language and structure

- `architecture/glossary.md`
- `archive/domain-glossary.md`
- `architecture/bounded-contexts.md`
- `archive/context-map.md`

### Project architecture and design

- `architecture/booking-process-consistency.md`
- `architecture/capacity-target-architecture.md`
- `architecture/execution-planning-design.md`
- `architecture/execution-planning-strategy-hierarchy.md`
- `architecture/ep-strategy-no-gap-all-required.md`
- `architecture/ep-strategy-no-gap-any-remaining.md`
- `architecture/ep-strategy-with-gap-all-required.md`
- `architecture/ep-strategy-with-gap-any-remaining.md`
- `architecture/ep-strategy-remaining-DRAFT.md`

### Local decision history

- `decisions/architectural-decisions.md`

### Analysis and rationale

- all files under `analysis/`
- `case-studies/multi-aggregate-coordination-learning-journey.md`

### Generated or assembled context

- all files under `orchestrator/context/`
- `INDEX.md`

### Delivery history

- all files under `stories/`

## Immediate Conclusion

For the original deletion question, the only clearly valid doctrine-level comparison target found so far was:

- `architecture/software-principles.md`

That file has already been verified as preserved at doctrine level in this playbook.

Everything else should be treated as outside the scope of that specific doctrine-preservation check unless explicitly reclassified after review.
