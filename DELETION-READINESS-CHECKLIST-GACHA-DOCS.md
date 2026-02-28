# Deletion Readiness Checklist: GaCha Docs

Date: February 28, 2026  
Source tree: `/Users/jespersorensen/IdeaProjects/Testbed/(to-be-merged)GaCha platform/docs`

## Purpose

This checklist is for deciding whether a GaCha docs file can be safely deleted after migration into the playbook.

Safe deletion means:

- its doctrine or decision content exists elsewhere
- any project-local-only value is understood
- deleting it will not silently remove useful navigation or context

## Current Inventory

- Markdown files: 56
- Approximate markdown corpus: 12,771 lines

Largest files worth prioritizing carefully:

- `archive/context-map.md`
- `analysis/smartplanner-gacha-gap-analysis.md`
- `analysis/execution-planning-deep-dive.md`
- `analysis/product-execution-optimization-analysis.md`
- `archive/domain-glossary.md`
- `analysis/execution-planning-algorithm-spec.md`
- `architecture/README.md`
- `architecture/bounded-contexts.md`
- `decisions/architectural-decisions.md`
- `case-studies/multi-aggregate-coordination-learning-journey.md`

## Deletion Decision States

Use one of these states for each file:

- `Delete`: fully covered elsewhere or obsolete
- `Delete After Porting`: mostly covered, but one or more valuable parts must be imported first
- `Keep as Project-Local`: useful in GaCha even if doctrine exists in the playbook
- `Keep for History`: superseded, but worth retaining as archive/reference
- `Undecided`: needs detailed comparison

## Per-File Checklist

For each file, answer these in order:

1. What kind of file is it?
2. Is it doctrine, architecture, glossary, case study, analysis, story, or generated context?
3. Does the same substance already exist in the playbook?
4. If yes, where exactly?
5. Does this file contain project-specific examples, links, or rationale not in the playbook?
6. Is it acting as an index or navigation surface for the GaCha repo?
7. Is it generated or derivative rather than authored source material?
8. Would deleting it break local links or make the remaining docs harder to navigate?
9. Is there any unique historical reasoning worth preserving?
10. Final state: `Delete`, `Delete After Porting`, `Keep as Project-Local`, `Keep for History`, or `Undecided`

## Fast Rules

### Usually safe to delete

- generated context snapshots
- duplicate doctrine already mapped to the playbook
- stale drafts that are fully superseded
- derivative indexes once their targets are removed or migrated

### Usually not safe to delete without review

- glossaries
- context maps
- case studies
- architectural decision logs
- deep-dive analyses with rationale not present elsewhere
- story sets that still explain why changes happened

## Priority Order

Work in this order so risk drops quickly and later files become easier to judge.

### Priority 1: Core architecture navigation and reference files

These files shape interpretation of many others:

- `INDEX.md`
- `architecture/README.md`
- `architecture/bounded-contexts.md`
- `architecture/glossary.md`
- `archive/context-map.md`
- `archive/domain-glossary.md`
- `decisions/architectural-decisions.md`
- `active-architecture-context.md`

### Priority 2: Doctrine and architecture principle files

These are likely candidates for port-or-delete decisions:

- `architecture/software-principles.md`
- `architecture/critical-invariants.md`
- `architecture/booking-process-consistency.md`
- `architecture/capacity-target-architecture.md`
- `architecture/execution-planning-design.md`
- `architecture/execution-planning-strategy-hierarchy.md`
- `architecture/ep-strategy-no-gap-all-required.md`
- `architecture/ep-strategy-no-gap-any-remaining.md`
- `architecture/ep-strategy-with-gap-all-required.md`
- `architecture/ep-strategy-with-gap-any-remaining.md`
- `architecture/ep-strategy-remaining-DRAFT.md`

### Priority 3: Case studies and analysis

These often contain unique rationale even when doctrine exists elsewhere:

- `case-studies/multi-aggregate-coordination-learning-journey.md`
- `analysis/execution-planning-algorithm-spec.md`
- `analysis/execution-planning-deep-dive.md`
- `analysis/execution-planning-gap-analysis-v2.md`
- `analysis/execution_planning_vs_appointment_creation_ddd_design_rationale.md`
- `analysis/product-execution-optimization-analysis.md`
- `analysis/smartplanner-gacha-gap-analysis.md`

### Priority 4: Story and epic documentation

These may be redundant if they are already implemented, but they may also be the best history of design intent:

- all `stories/*.md`
- all `stories/epic-1.6-async-availability-integration/*.md`

### Priority 5: Orchestrator context artifacts

These are likely generated or assembled documents and usually lower risk:

- `orchestrator/context/ArchitectureContext.md`
- `orchestrator/context/CodeStructureContext.md`
- `orchestrator/context/DoctrineContext.md`
- `orchestrator/context/RepositoryIngestion.md`
- `orchestrator/context/StoryBacklogContext.md`
- `orchestrator/context/FileTreeContext.txt`
- `orchestrator/context/StoryStatusIndex.txt`

### Priority 6: Non-markdown assets

These should be assessed only after the markdown structure is understood:

- `smartplanner/*.png`
- `.DS_Store`

## Category-Specific Guidance

### Doctrine files

Delete only when the doctrine is explicitly mapped to playbook files.

If the doctrine is present but the GaCha file provides a much better compact summary, consider `Keep as Project-Local` instead of deleting immediately.

### Glossary files

Delete only if terminology is preserved elsewhere.

Glossary loss is high-risk because terms often disappear silently when concepts are split across files.

### Context maps and bounded context files

Delete only if the bounded context relationships are preserved in equal or better form.

These are structural documents, not just narrative docs.

### Analysis and deep dives

Default to `Keep for History` or `Delete After Porting` unless you confirm they contain no unique rationale.

These files often hold the reason behind current design, not just the result.

### Stories

Stories can often be deleted later, not first.

If a story explains a still-relevant design move or migration sequence, keep it until that reasoning is captured elsewhere.

### Generated orchestrator context

These are usually the best deletion candidates after verification.

If they are snapshots assembled from source docs, they are derivative, not primary source material.

## Recommended Workflow

For each reviewed file, record:

- source path
- classification
- playbook coverage path(s)
- unique content still missing
- deletion decision
- notes

Use this flat template:

```md
Source: <path>
Type: <doctrine|architecture|glossary|analysis|case-study|story|generated>
Coverage: <full|partial|none>
Playbook target(s): <path list>
Unique GaCha-only value: <yes/no + note>
Decision: <Delete|Delete After Porting|Keep as Project-Local|Keep for History|Undecided>
```

## First Recommended Batch

The next best files to audit are:

1. `architecture/glossary.md`
2. `archive/domain-glossary.md`
3. `architecture/bounded-contexts.md`
4. `archive/context-map.md`
5. `decisions/architectural-decisions.md`

Reason:

These files determine whether the playbook still lacks core language, boundaries, or historical decision rationale. If these are incomplete, deleting downstream files becomes much riskier.

## Current Recommendation

Do not mass-delete the GaCha docs tree.

Proceed file by file using this checklist.

For now:

- `architecture/software-principles.md` is deletion-ready from a doctrine perspective
- glossary, context-map, decisions, and case-study files are not deletion-ready without audit
