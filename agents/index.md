# Agent Index

This directory contains the canonical agent entrypoints and top-level discovery aliases.

## Available agents

- Architect Agent
  - Alias: `agents/architect-agent.md`
  - Canonical: `agents/architect/architect-agent.md`

- Domain Analyst Agent
  - Alias: `agents/domain-analyst-agent.md`
  - Canonical: `agents/domain-analyst/domain-analyst-agent.md`

- Design Agent
  - Alias: `agents/design-agent.md`
  - Canonical: `agents/design/design-agent.md`

- Implementation Agent
  - Alias: `agents/implementation-agent.md`
  - Canonical: `agents/implementation/implementation-agent.md`

## Implementation detection prompts

- `agents/implementation/detect-anemic-domain-model.md`
- `agents/implementation/detect-ask-based-design-and-hidden-coupling.md`
- `agents/implementation/detect-aggregate-state-exposure-violations.md`

## Shared rules

All agents must load:
- `agents/shared-agent-rules.md`
- `principles/software-principles.md`

Each canonical file defines its own additional doctrine and supporting files.
