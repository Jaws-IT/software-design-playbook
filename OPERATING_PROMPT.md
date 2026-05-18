# Operating Prompt (Global AI Projects)

## Purpose

This file is the session-level execution wrapper for the software design playbook.
It does not replace doctrine files. It enforces how every programming task is executed.

## Scope

Applies by default to all AI-assisted software engineering work unless an explicit documented exception is active.

## Mandatory Sources To Load

Load and apply these playbook files before starting implementation:

1. `principles/software-principles.md`
2. `principles/code-rules.md`
3. `principles/code-anti-patterns.md`
4. `standards/coding-standards.md`
5. `standards/violation-detection-spec.md`
6. `tools/WORKFLOW.md`
7. `agents/index.md`

When relevant, also load:

- `principles/domain-leakage-taxonomy.md`
- `standards/domain-leakage-severity-standard.md`
- `standards/architecture-enforcement-spec.md`
- `standards/micro-frontend-ownership-standard.md`

## Default Execution Loop

Always run this loop:

1. Implement
2. Detect violations (playbook + architecture + anti-pattern checks)
3. Repair
4. Detect again
5. Repeat until clean or explicitly blocked

Do not stop after first implementation pass if violations remain.

## Agent Use Policy

Use playbook agents by default:

- Domain analysis concerns: `agents/domain-analyst-agent.md`
- Architectural concerns: `agents/architect-agent.md`
- Design concerns: `agents/design-agent.md`
- Implementation concerns: `agents/implementation-agent.md`

Run required implementation detection prompts:

- `agents/implementation/detect-anemic-domain-model.md`
- `agents/implementation/detect-ask-based-design-and-hidden-coupling.md`
- `agents/implementation/detect-aggregate-state-exposure-violations.md`

## Completion Criteria

A task is complete only when:

- implementation exists,
- required detection passes (or known violations are documented),
- repairs have been applied for findings within scope,
- remaining risks/constraints are explicitly reported.

## Exception Policy (Proportionate Governance)

This playbook is a strong default recommendation, not universal mandate for every context.

Allowed exceptions include:

- small prototype,
- short exploration spike,
- throwaway demo,
- low-risk internal utility.

Any exception must document:

1. reason,
2. scope and timebox,
3. exit criteria if moving toward production.

## Output Contract For Sessions

At start:

- confirm loaded sources,
- state assumptions,
- state current loop phase.

During work:

- report findings and repairs per iteration.

At end:

- summarize what was implemented,
- summarize what was detected and repaired,
- list any unresolved findings and why.
