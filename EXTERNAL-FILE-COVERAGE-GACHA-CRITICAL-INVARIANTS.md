# External File Coverage: GaCha `critical-invariants.md`

Date: February 28, 2026  
Source file reviewed: `/Users/jespersorensen/IdeaProjects/Testbed/(to-be-merged)GaCha platform/docs/architecture/critical-invariants.md`

## Verdict

This file is **not fully preserved** in the playbook.

Some related ideas exist in the playbook, but the file's invariant set, enforcement structure, test obligations, and production-monitoring guidance are largely missing.

## Overall Coverage

| External section | Source lines | Coverage | Notes |
|---|---:|---|---|
| Invariant 1: No Double Booking | 5-64 | Partial | The playbook contains related ideas about aggregate boundaries and protecting consistency, but not this invariant as an explicit, tested, top-level rule. |
| Invariant 2: Single Source of Truth (Events) | 66-108 | Low | The playbook discusses domain events and layering, but does not preserve the explicit invariant that all state changes must occur through events. |
| Invariant 3: Atomic State Transitions | 109-154 | Low | CAS / AtomicReference / all-or-nothing transition guidance is not preserved in the playbook. |
| Invariant 4: Resource Availability Consistency | 156-203 | Low | The exact invariant and its cross-context event model are not preserved. |
| Invariant Verification Checklist | 205-214 | Missing | No equivalent PR checklist found. |
| Monitoring and Alerting | 215-226 | Missing | No equivalent production invariant monitoring guidance found. |

## Detailed Findings

### 1. No Double Booking

The idea is partially present in spirit, but not preserved as a formal invariant document.

What exists in the playbook:

- [patterns/strategic-design-patterns.md](/Users/jespersorensen/IdeaProjects/jaws-it/software-design-playbook/patterns/strategic-design-patterns.md) preserves aggregate-boundary reasoning and multi-aggregate coordination concerns.
- General doctrine in the repository favors explicit invariants inside aggregates.

What is missing:

- the explicit statement that no double booking is a top-level system correctness invariant
- the formal definition
- the enforcement model across domain, aggregate, and persistence layers
- the concrete test requirements for single-threaded, concurrent, and boundary-condition cases
- the explicit P0 severity statement

### 2. Single Source of Truth (Events)

The playbook contains event-related doctrine, but not this invariant in a preserved form.

What exists:

- [standards/coding-standards.md](/Users/jespersorensen/IdeaProjects/jaws-it/software-design-playbook/standards/coding-standards.md) distinguishes domain events and integration events.
- Structural documents require domain events to exist in the domain layer.

What is missing:

- the invariant that all state changes must occur through events
- the explicit prohibition on direct state modification in the CQRS/read-model sense
- the example historical bug of double updates
- the invariant-specific test requirement for event-only state change

### 3. Atomic State Transitions

This content is effectively missing from the playbook.

What is missing:

- atomic all-or-nothing transition doctrine
- CAS / `AtomicReference` compare-and-set guidance
- the “never expose partial state” rule
- the concurrency retry model
- the associated tests

This is the clearest omission relative to the external file.

### 4. Resource Availability Consistency

This content is only weakly represented.

What is missing:

- the explicit invariant that read-model availability must reflect the resource's actual state
- the cross-context event table
- the distinction between strong consistency for double-booking prevention and eventual consistency for external availability inputs
- the test requirements for stale-data handling and external event reflection

### 5. Verification Checklist

The external file includes a concrete invariant checklist for pull requests.

No equivalent checklist was found in the playbook.

### 6. Monitoring and Alerting

The external file includes production-oriented invariant verification:

- duplicate resource checks
- event/state drift detection
- CAS retry rate monitoring
- severity thresholds

This is absent from the playbook.

## What Has Been Left Out

If the question is specifically “what from `critical-invariants.md` is not preserved in this repository?”, the missing material is:

1. A dedicated invariant document.
2. Formal articulation of `No Double Booking` as a system-critical invariant.
3. Event-sourced/single-source-of-truth invariant language.
4. Atomic state transition guidance using CAS semantics.
5. Resource availability consistency as an explicit cross-context invariant.
6. Invariant-specific test obligations.
7. Invariant verification checklist for PRs.
8. Production monitoring and alerting for invariant drift.

## Conclusion

Compared to `software-principles.md`, this file is materially underrepresented in the playbook.

If preserving doctrine is the goal, `critical-invariants.md` should be treated as **not safely covered** by the current repository.
