# Old Playbook Source Coverage Report

Date: February 28, 2026  
Source folder reviewed: `/Users/jespersorensen/Documents/software-design-playbook-old/software-development`

## Purpose

This report checks whether doctrine-level material from the old source folder is represented in the current playbook repository.

Per instruction, files that are project-specific or mixed with project-specific implementation guidance are flagged and ignored for doctrine coverage purposes.

## Source File Classification

### Doctrine-level files checked

- `01-principles.md`
- `02-code-rules.md`
- `03-anti-patterns.md`
- `05-clean-code-formatting.md`
- `error-handling-model_v2.md`

### Project-specific or mixed files flagged and ignored

- `guidelines.md`
- `guidelines 15.28.51.md`
- `modular-monolith-structure.md`

Reason:

These files contain marketplace/BFF/application-specific guidance, source-tree examples, and local implementation framing rather than pure playbook doctrine.

## Coverage Summary

| Source file | Current playbook target(s) | Coverage | Notes |
|---|---|---|---|
| `01-principles.md` | [principles/software-principles.md](/Users/jespersorensen/IdeaProjects/jaws-it/software-design-playbook/principles/software-principles.md) | Represented | Current playbook version is structurally sound and more complete than the placeholder-based old source. |
| `02-code-rules.md` | [principles/code-rules.md](/Users/jespersorensen/IdeaProjects/jaws-it/software-design-playbook/principles/code-rules.md) plus related files | Mostly represented | Four previously missing rules were restored on `playbook-recovery`; one old rule remains intentionally excluded. |
| `03-anti-patterns.md` | [principles/code-anti-patterns.md](/Users/jespersorensen/IdeaProjects/jaws-it/software-design-playbook/principles/code-anti-patterns.md) | Represented | Current playbook covers the doctrine and expands it. |
| `05-clean-code-formatting.md` | [standards/clean-code-formatting.md](/Users/jespersorensen/IdeaProjects/jaws-it/software-design-playbook/standards/clean-code-formatting.md) | Represented | Current playbook preserves and extends the formatting guidance. |
| `error-handling-model_v2.md` | [architecture/error-handling-model.md](/Users/jespersorensen/IdeaProjects/jaws-it/software-design-playbook/architecture/error-handling-model.md) | Represented | Current playbook preserves the three-tier model and shared-domain-error approach. |

## What Is Represented

The following doctrine areas are present in the current playbook:

- software principles
- anti-patterns
- clean code formatting
- three-tier error classification
- shared `DomainError` / no-redundant-mapping error flow model

## What Appears Left Out

The main omissions originally came from `02-code-rules.md`.

After review, these items have now been restored in the current playbook:

### 1. Single Log Point

- restored in [principles/code-rules.md](/Users/jespersorensen/IdeaProjects/jaws-it/software-design-playbook/principles/code-rules.md)

### 2. WET over DRY

- restored as `WET Before Premature DRY` in [principles/code-rules.md](/Users/jespersorensen/IdeaProjects/jaws-it/software-design-playbook/principles/code-rules.md)

### 3. 100% Test Coverage

This rule was reviewed and intentionally not restored as authoritative doctrine.

Reason:

- a numeric coverage target is weaker than behavior-focused testing doctrine
- high coverage can coexist with poor test quality
- the current playbook emphasizes meaningful behavior, repeatability, and structural test quality instead of a universal percentage mandate

### 4. Command Query Separation

- restored in [principles/code-rules.md](/Users/jespersorensen/IdeaProjects/jaws-it/software-design-playbook/principles/code-rules.md)

### 5. Function Arguments

- restored as `Function Arity Discipline` in [principles/code-rules.md](/Users/jespersorensen/IdeaProjects/jaws-it/software-design-playbook/principles/code-rules.md)

## Interpretation

The old source folder is mostly represented at doctrine level in the current playbook.

The only meaningful doctrine gap identified in this review was a subset of the older `02-code-rules.md` guidance.

That gap has now been closed except for the `100% Test Coverage` rule, which was intentionally left out.

## Recommendation

If your goal is doctrine preservation, the current playbook is broadly intact relative to the old source folder.

Everything else checked here is already represented at an acceptable doctrine/playbook level.
