# Playbook State Audit

Date: February 28, 2026
Repository commit audited: `635dcdb`
Branch: `main`

## Purpose

This file records the current, observable state of the playbook so future work starts from evidence instead of assumptions.

## Current Baseline

- The repository is currently clean in git.
- The playbook contains 34 Markdown files.
- The current tracked Markdown corpus is 7,851 lines.
- The repository has meaningful git history, so reconstruction should happen from diffs and prior revisions, not from memory.

## High-Confidence Findings

### 1. Incomplete file

- [standards/micro-frontend-ownership-standard.md](/Users/jespersorensen/IdeaProjects/jaws-it/software-design-playbook/standards/micro-frontend-ownership-standard.md) is tracked but empty.

### 2. Placeholder content replaced prior material instead of preserving it

- [principles/software-principles.md](/Users/jespersorensen/IdeaProjects/jaws-it/software-design-playbook/principles/software-principles.md) contains the marker `[Previous content remains the same]`.
- [principles/code-anti-patterns.md](/Users/jespersorensen/IdeaProjects/jaws-it/software-design-playbook/principles/code-anti-patterns.md) contains the marker `[Previous anti-patterns remain the same...]`.

These files cannot currently be treated as complete because the documents explicitly reference missing earlier content.

### 3. Stale internal references exist

- [patterns/testing-patterns.md](/Users/jespersorensen/IdeaProjects/jaws-it/software-design-playbook/patterns/testing-patterns.md) references non-existent numbered files such as `01-principles.md`.
- [patterns/architectural-decision-patterns.md](/Users/jespersorensen/IdeaProjects/jaws-it/software-design-playbook/patterns/architectural-decision-patterns.md) references non-existent numbered files.
- [patterns/strategic-design-patterns.md](/Users/jespersorensen/IdeaProjects/jaws-it/software-design-playbook/patterns/strategic-design-patterns.md) references non-existent numbered files.

This indicates some content was imported or rewritten from a different file layout without fully reconciling links and references.

### 4. Repository workflow and repository structure were out of sync

- [tools/compose-doctrine.sh](/Users/jespersorensen/IdeaProjects/jaws-it/software-design-playbook/tools/compose-doctrine.sh) previously referenced `standards/repair-governance-spec.md`.
- The actual file is [structure/repair-governance-spec.md](/Users/jespersorensen/IdeaProjects/jaws-it/software-design-playbook/structure/repair-governance-spec.md).

This has now been corrected so the local workflow matches the repository layout.

### 5. Several files show rewrite-level churn and need continuity review

These files changed substantially and should be reviewed against prior revisions before being treated as authoritative:

- [patterns/testing-patterns.md](/Users/jespersorensen/IdeaProjects/jaws-it/software-design-playbook/patterns/testing-patterns.md)
- [standards/clean-code-formatting.md](/Users/jespersorensen/IdeaProjects/jaws-it/software-design-playbook/standards/clean-code-formatting.md)
- [principles/software-principles.md](/Users/jespersorensen/IdeaProjects/jaws-it/software-design-playbook/principles/software-principles.md)
- [principles/code-anti-patterns.md](/Users/jespersorensen/IdeaProjects/jaws-it/software-design-playbook/principles/code-anti-patterns.md)

Two of these contain explicit placeholders, which makes them the highest priority.

## Current Confidence By Area

### High confidence

- [standards/architecture-enforcement-spec.md](/Users/jespersorensen/IdeaProjects/jaws-it/software-design-playbook/standards/architecture-enforcement-spec.md)
- [principles/code-rules.md](/Users/jespersorensen/IdeaProjects/jaws-it/software-design-playbook/principles/code-rules.md)
- [structure/project-structure-specification.md](/Users/jespersorensen/IdeaProjects/jaws-it/software-design-playbook/structure/project-structure-specification.md)
- [tools/WORKFLOW.md](/Users/jespersorensen/IdeaProjects/jaws-it/software-design-playbook/tools/WORKFLOW.md)

These documents appear materially present and do not contain obvious placeholder markers.

### Medium confidence

- Most `agents/` prompts and roles
- [architecture/error-handling-model.md](/Users/jespersorensen/IdeaProjects/jaws-it/software-design-playbook/architecture/error-handling-model.md)
- [architecture/frontend/micro-frontend-canvas-architecture.md](/Users/jespersorensen/IdeaProjects/jaws-it/software-design-playbook/architecture/frontend/micro-frontend-canvas-architecture.md)
- [patterns/error-handling-patterns.md](/Users/jespersorensen/IdeaProjects/jaws-it/software-design-playbook/patterns/error-handling-patterns.md)
- [patterns/strategic-design-patterns.md](/Users/jespersorensen/IdeaProjects/jaws-it/software-design-playbook/patterns/strategic-design-patterns.md)

These look substantial, but some should still have link and consistency checks.

### Low confidence

- [standards/micro-frontend-ownership-standard.md](/Users/jespersorensen/IdeaProjects/jaws-it/software-design-playbook/standards/micro-frontend-ownership-standard.md)
- [principles/software-principles.md](/Users/jespersorensen/IdeaProjects/jaws-it/software-design-playbook/principles/software-principles.md)
- [principles/code-anti-patterns.md](/Users/jespersorensen/IdeaProjects/jaws-it/software-design-playbook/principles/code-anti-patterns.md)

These should be considered incomplete until reconstructed from history.

## Reconstruction Order

1. Rebuild the incomplete or placeholder-based files from git history before adding new doctrine.
2. Fix stale references so the playbook points at the files that actually exist.
3. Review reduced or heavily rewritten documents against earlier revisions and decide whether missing sections should be restored.
4. Only after the baseline is stable, continue with new enhancements.

## Operating Rule From This Point

Enhancement work must be additive by default.

If a file is being reorganized or replaced, the diff must show one of these explicitly:

- content preserved and restructured
- content intentionally deleted with a reason
- content intentionally superseded by a new file

Anything else counts as drift until reviewed.
