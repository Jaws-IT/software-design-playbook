# AI Code Generation & Repair Orchestrator

Version: 1.0.0
## (Repository-Driven, Doctrine-Enforced, Story-First Workflow)

---

## PURPOSE

This file defines the exact operational flow for:

- Loading a Git repository (local or remote)
- Building a structured context window from doctrine + architecture + modules
- Selecting the next story
- Generating code
- Detecting violations
- Repairing code until compliant

No explanation. Only execution flow.

---

# STEP 0 — INITIALIZATION

## Ask User

1. Provide Git repository URL  
   OR
2. Confirm that the repository has been uploaded locally

Then ask:

- What is the primary language?
- What build system? (Maven / Gradle / npm / etc.)
- What is the story folder path?
- What is the doctrine folder path?

---

# STEP 1 — REPOSITORY INGESTION

## If Git URL

- Clone repository
- Build full file tree
- Index:
    - `/domain`
    - `/application`
    - `/infrastructure`
    - `/interfaces`
    - `/doctrine`
    - `/stories`
    - `/adr`
    - `/architecture`
    - `/modules`

## If Uploaded

- Extract archive
- Build full file tree
- Perform same indexing

---

# STEP 2 — STRUCTURED CONTEXT WINDOW BUILD

## Load Doctrine First

From `/doctrine`:

- Coding principles
- Architectural principles
- Naming rules
- Invariants vs policies
- Event rules
- Aggregate rules
- Module boundaries
- Context boundaries
- Functional style rules
- Testing rules
- Prohibited patterns

Store as:

```
DoctrineContext
```

---

## Load Architectural Structure

From `/architecture` and `/modules`:

- Bounded Context definitions
- Context map
- Upstream/Downstream definitions
- Module per BC rules
- Integration style (Events / REST / Messaging)

Store as:

```
ArchitectureContext
```

---

## Load Current Code Structure

For each Bounded Context:

- Aggregates
- Commands
- Domain Events
- Application Services
- Ports
- Adapters
- Integration Events
- Tests

Store as:

```
CodeStructureContext
```

---

## Load Stories

From `/stories`:

- Parse story titles
- Parse story status
- Detect completed vs in-progress
- Detect referenced aggregates or modules

Store as:

```
StoryBacklogContext
```

---

# STEP 3 — STORY SELECTION

Ask:

> Which story should we start with?

If not specified:

- Analyze last modified files
- Detect partial implementation
- Suggest most cohesive continuation

Then:

```
ActiveStoryContext = SelectedStory
```

---

# STEP 4 — STORY → DOMAIN MAPPING

For Active Story:

1. Identify:
    - Target Bounded Context
    - Target Aggregate
    - New Command?
    - New Event?
    - Policy?
    - Saga?

2. Validate:
    - Is this inside correct BC?
    - Does it violate authority rules?
    - Does it leak domain?
    - Is it cross-context?

If cross-context:
- Mark as Saga or Integration

---

# STEP 5 — GENERATION MODE

## Generate in this order:

1. Domain Model Changes
    - Aggregate
    - Entities
    - Value Objects
    - Domain Events

2. Application Layer
    - Command Handler
    - Use Case
    - Ports

3. Infrastructure
    - Adapter
    - Repository impl
    - Event Publisher

4. Tests
    - White-box unit tests
    - Functional-style return assertions
    - No server boot
    - No DB dependency

---

# STEP 6 — VALIDATION PASS

After generation, perform automated validation against:

## 1. Doctrine Rules

- No getters exposing state
- No public "verify"
- No generic managers
- No cross-BC direct calls
- No mutable state
- Domain events colocated with aggregate
- No integration event inside domain
- One BC per module

## 2. Architecture Rules

- No layer collapse
- Domain does not depend on infrastructure
- Ports defined in boundary
- Adapters only in infrastructure

## 3. Cohesion Check

- Does aggregate own invariants?
- Are policies separated?
- Are commands intention-revealing?
- Are events past-tense?

---

# STEP 7 — VIOLATION DETECTION

If violations found:

Create:

```
ViolationReport.md
```

Containing:

- File
- Rule violated
- Explanation
- Suggested fix

---

# STEP 8 — REPAIR MODE

For each violation:

1. Refactor file fully
2. Regenerate full file
3. Do NOT patch
4. Output full corrected file

Repeat validation.

Loop until:

```
ViolationReport == Empty
```

---

# STEP 9 — DIFF REVIEW

Generate:

```
ChangeSummary.md
```

Containing:

- Story implemented
- Files created
- Files modified
- Architectural impact
- Domain impact
- Events added
- Commands added

---

# STEP 10 — CONTINUATION

Ask:

- Next story?
- Refactor pass?
- Architecture analysis?
- Integration review?
- Cohesion scan?

---

# OPERATION MODES

## MODE 1 — Generate
Implements new story.

## MODE 2 — Audit
Scans entire repo for doctrine violations.

## MODE 3 — Refactor
Improves cohesion without adding features.

## MODE 4 — Architecture Review
Detect domain leaking or wrong authority.

---

# HARD RULES

- Never modify partial file
- Always output full file
- Never inject into existing code blindly
- Never expose aggregate internals
- Never collapse layers
- Never mix integration event into domain
- Never update multiple aggregates in same transaction
- Never use generic names
- Always return Either<Error, Event> or Result type
- All domain changes emit domain event
- Domain event applied internally to produce new state

---

# CONTEXT WINDOW PRIORITY ORDER

1. Doctrine
2. Architecture
3. Active Story
4. Code Structure
5. Supporting modules

---

# FILE STRUCTURE EXPECTATION

```
/bounded-context-name
    /domain
    /application
    /infrastructure
    /integration
    /interfaces
    /tests
```

---

# END OF FILE
