# Ubiquitous Language — [Project Name]

**Version:** 0.1  
**Last Updated:** [Date]  
**Bounded Context:** [Context Name]  
**Domain Owner:** [Business stakeholder or team responsible for this domain]

---

## Core Domain Concepts

<!-- 
Instructions for Domain Analyst Agent:
Discover these through stakeholder conversations. Each concept must use business language,
not technical language. If stakeholders use different words for the same thing, resolve it here.
-->

### [Concept Name]

**Definition:** [One or two sentences in business terms]

**Synonyms:** [Other words the business uses, if any]

**Anti-examples:** [What this is NOT — clarify common confusions]

**Lifecycle:** [State transitions if applicable, e.g. Created → Active → Closed]

**Ownership:** [Which business role or team owns this concept]

**Examples:** [Real-world scenarios where this concept appears]

---

## Aggregates and Invariants

<!--
Instructions for Domain Analyst Agent:
Identify transactional consistency boundaries. Each aggregate protects business rules
that must always be true. Commands express business intent. Events are past-tense facts.
-->

### [Aggregate Root Name]

**Members:** [Entities and value objects belonging to this aggregate]

**Invariants:**
- [Business rule that must always hold]
- [Business rule that must always hold]

**Commands:**
- [BusinessIntent — expressed as what the caller tells the aggregate to do]

**Events:**
- [PastTenseFact — what happened as a result]

**Consistency Boundary:** [What this aggregate owns exclusively]

**Repository:** [How this aggregate is loaded and saved]

---

## Cross-Context Terminology Mapping

<!--
Instructions for Architect Agent:
Validate that every cross-context relationship has an explicit translation.
Flag any concept that appears in two contexts without a documented mapping.
-->

### [Upstream Context Name] → [This Context Name]

| Upstream Concept | This Context Concept | Relationship | Translation |
|------------------|----------------------|--------------|-------------|
| [Term A] | [Term B] | [How they relate] | [How data/events are translated] |

### [This Context Name] → [Downstream Context Name]

| This Context Concept | Downstream Concept | Relationship | Translation |
|----------------------|-------------------|--------------|-------------|
| [Term A] | [Term B] | [How they relate] | [How data/events are translated] |

---

## Business Policies

<!--
Instructions for Domain Analyst Agent:
Capture rules that govern behavior. These often become domain services or policy objects in code.
Every policy must have a clear trigger and owner.
-->

### [Policy Name]

**Rule:** [The actual business rule in plain language]

**Trigger:** [What event or command activates this policy]

**Owner:** [Which business role enforces this]

**Exceptions:** [When the rule does not apply, if ever]

---

## What This Context Does NOT Own

<!--
Instructions for Domain Analyst Agent:
Explicitly list concepts that might seem like they belong here but don't.
This prevents scope creep and clarifies boundaries for the Architect and Implementation agents.
-->

- [Concept] (owned by [Other Context])
- [Concept] (owned by [Other Context])

---

## Agent Validation Checklist

<!--
Each agent validates this document against their concerns before proceeding.
-->

### Domain Analyst Agent
- [ ] Every concept uses business language, not technical language
- [ ] No two concepts share the same name with different meanings
- [ ] Lifecycles are complete — no missing or ambiguous states
- [ ] Anti-examples clarify the most common confusions
- [ ] Excluded concepts list is complete

### Architect Agent
- [ ] Every cross-context relationship has an explicit mapping
- [ ] No concept appears in two contexts without a documented translation
- [ ] Aggregate boundaries align with transactional consistency needs
- [ ] Integration points are identified for every cross-context mapping

### Kotlin Implementation Agent
- [ ] Aggregate names match code class names exactly
- [ ] Command names match public method signatures
- [ ] Event names are past-tense and match domain event classes
- [ ] No generic terms (User, Manager, Handler, Processor) in domain code
- [ ] Value objects are identified and will be implemented as immutable types

---

## Changelog

<!--
Document every change to the ubiquitous language. Never silently rename a concept.
-->

### v0.1 ([Date])
- Initial discovery — [brief summary of what was captured and from whom]
