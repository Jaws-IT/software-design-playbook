# Ubiquitous Language Doctrine

**Version:** 1.0  
**Last Updated:** March 4, 2026  
**Scope:** Doctrine-level template for all projects

---

## Purpose

This document defines how ubiquitous language is captured, maintained, and enforced across all projects.

Ubiquitous language is the shared vocabulary between business stakeholders and development teams. It is the single source of truth for domain terminology within a bounded context, and the bridge for mapping concepts across contexts.

Every project must instantiate this doctrine by creating a project-specific ubiquitous language document.

---

## Core Principles

### 1. Language Comes First

Before designing architecture, before writing code, teams must establish shared language.

Language reflects how the business actually thinks about the domain. If teams are using different words for the same concept, or the same word for different concepts, the model will be fragile.

### 2. One Language Per Bounded Context

Each bounded context owns a distinct vocabulary.

The same term may have different meanings across contexts. This is not a problem — it is expected. What matters is that within each context, the language is consistent and unambiguous.

Each bounded context should maintain exactly one authoritative ubiquitous language document.

Recommended convention:

- `modules/<bounded-context>/docs/UBIQUITOUS-LANGUAGE.md`

Do not split the authoritative vocabulary for one bounded context across multiple competing documents.

### 3. Business Language, Not Technical Language

Ubiquitous language comes from domain experts, not from developers.

Developers translate business language into code. But the code should never introduce new concepts that don't exist in the business vocabulary.

Examples of what NOT to do:
- Use "User" instead of the domain-specific actor (Customer, Employee, Broker, etc.)
- Use "Entity" or "Object" or "Record" instead of the actual domain concept
- Use "Manager" or "Service" to name domain concepts (these are implementation artifacts)

### 4. Explicit Across Boundaries

When concepts must be shared across bounded contexts, the mapping must be explicit.

If Order Context talks about "customer" and Billing Context talks about "account holder," the relationship must be documented. Teams must not rely on implicit understanding.

### 5. Language Evolves With Understanding

Ubiquitous language is not static. As teams learn more about the domain, terminology may shift.

Changes must be documented. If a term is replaced, the old term and the reason for change must be recorded.

---

## Structure of a Project Ubiquitous Language Document

Every project creates `project/ubiquitous-language.md` following this template.

### Section 1: Core Domain Concepts

List the primary concepts in this bounded context with precise definitions.

**Format:**

```
## Core Domain Concepts

### [Concept Name]

**Definition:** One or two sentences explaining what this is in business terms.

**Synonyms:** Other words the business uses for this (if any).

**Anti-examples:** What this is NOT. Important for clarity.

**Lifecycle:** Brief note on how this concept moves through states (if applicable).

**Ownership:** Which role or team owns this concept in the business?

**Examples:** Real-world instances or scenarios where this concept appears.
```

**Example:**

```
### Order

**Definition:** A request from a customer to fulfill a set of items, with associated pricing and delivery terms. Once placed, an order drives fulfillment, billing, and delivery workflows.

**Synonyms:** Purchase Order (in B2B contexts), Sales Order

**Anti-examples:** NOT the same as an Invoice (which is a billing document). NOT the same as a Shipment (which is the fulfillment artifact).

**Lifecycle:** Created → Confirmed → Picked → Packed → Shipped → Delivered → Archived

**Ownership:** Order Management team owns order rules and state transitions.

**Examples:** "The customer placed an order for 3 widgets and 2 sprockets."
```

### Section 2: Aggregates and Invariants

List the aggregates in this bounded context and the invariants they protect.

**Format:**

```
## Aggregates and Invariants

### [Aggregate Root Name]

**Members:** Which entities and value objects belong to this aggregate.

**Invariants:** Business rules that must always be true.

**Commands:** What operations can be performed on this aggregate (expressed as intent).

**Events:** What domain events does this aggregate emit?

**Consistency Boundary:** Is this aggregate alone, or does it own multiple entities?

**Repository:** How is this aggregate persisted and retrieved?
```

**Example:**

```
### Order Aggregate

**Members:** Order (root), LineItem (entity), Address (value object), Pricing (value object)

**Invariants:**
- An order must have at least one line item
- The total price must equal the sum of line item prices plus tax
- An order can only be confirmed if all items are in stock
- Confirmed orders cannot be modified, only cancelled

**Commands:**
- PlaceOrder
- ConfirmOrder
- AddLineItem (only before confirmation)
- CancelOrder

**Events:**
- OrderPlaced
- OrderConfirmed
- OrderCancelled
- LineItemAdded

**Consistency Boundary:** One Order aggregate owns all its LineItems. Price and Address are values belonging to Order.

**Repository:** OrderRepository provides load(orderId) and save(order)
```

### Section 3: Cross-Context Relationships

If this bounded context collaborates with others, map the terminology across boundaries.

**Format:**

```
## Cross-Context Terminology Mapping

### [Upstream Context] → This Context

| Upstream Concept | This Context Concept | Relationship | Translation |
|------------------|----------------------|--------------|-------------|
| Concept A | Concept B | How they relate | How data/events are translated |
```

**Example:**

```
## Cross-Context Terminology Mapping

### Inventory Context → Order Context

| Upstream Concept | This Context Concept | Relationship | Translation |
|------------------|----------------------|--------------|-------------|
| SKU | Product | Same concept, different names | OrderContext.Product wraps Inventory.SKU metadata |
| Stock Level | Availability | Related but different | Inventory publishes StockLevelChanged; Order checks availability before confirmation |
| Reservation | Allocation | Order allocates inventory when confirmed | Order.Confirmed triggers Inventory.ReserveItems |
```

### Section 4: Business Policies

Document policies that govern behavior in this context.

**Format:**

```
## Business Policies

### [Policy Name]

**Rule:** The actual business rule.

**Trigger:** What event or command triggers this policy?

**Owner:** Which role enforces this policy?

**Exceptions:** Are there cases where the rule doesn't apply?
```

**Example:**

```
## Business Policies

### Order Confirmation Policy

**Rule:** An order may only be confirmed if all items are available in inventory.

**Trigger:** Customer attempts to confirm order.

**Owner:** Order Management verifies; Inventory confirms availability.

**Exceptions:** Backorder items may be allowed with explicit customer approval.
```

### Section 5: Excluded Concepts

Document what is NOT in this context. This prevents confusion and clarifies boundaries.

**Format:**

```
## What This Context Does NOT Own

- Concept A (owned by Context X)
- Concept B (owned by Context Y)
- Technical concept that might sound domain-relevant but isn't
```

**Example:**

```
## What This Context Does NOT Own

- Inventory management (owned by Inventory Context)
- Billing and invoicing (owned by Billing Context)
- Shipping logistics (owned by Fulfillment Context)
- Payment processing (owned by Payment Context)
- User authentication (owned by Identity Context)
```

---

## Creation Workflow

When starting a new project:

1. **Domain Analyst Agent** runs the discovery process with stakeholders and produces the project ubiquitous language document, using this template.

2. **Architect Agent** loads the ubiquitous language document and uses it to validate bounded context boundaries and integration points.

3. **Kotlin Implementation Agent** loads the ubiquitous language document and uses it to ensure code reflects business terminology (aggregate names, command names, event names).

All three agents reference the same document during their work. This ensures semantic alignment.

---

## Maintenance

When ubiquitous language changes:

1. Update the project ubiquitous language document first.
2. Document the change reason in a "Changelog" section at the bottom.
3. Update all affected code, prompts, and architecture documentation.
4. Never silently rename a concept — always document the evolution.

If a bounded context keeps supplemental language notes, drafts, or workshop artifacts,
they must point back to the one authoritative ubiquitous language file rather than compete with it.

### Example Changelog

```
## Changelog

### v1.1 (2026-02-15)
- Renamed "Order" to "SalesOrder" to distinguish from PurchaseOrder in B2B flows
- Added "Invoice" as a separate concept owned by Billing Context
- Clarified that Order confirmation requires explicit inventory reservation
```

---

## Enforcement

The domain analyst agent must validate that code adheres to the ubiquitous language:

- Aggregate names match the core domain concepts
- Command names express business intent, not technical operations
- Event names are past-tense and reflect business facts, not technical details
- No generic terms (User, Manager, Handler, Processor) in business code

If code violates the ubiquitous language, it is a signal that either:
1. The code is wrong (refactor it)
2. The language is incomplete (update the document)

---

## Related Documents

- `principles/software-principles.md` — Tell Don't Ask, Intention-Revealing Names
- `patterns/strategic-design-patterns.md` — Domain discovery and design validation
- `agents/prompts/domain-discovery-facilitator.md` — Discovery conversation guide
- `agents/prompts/review-bounded-context-design.md` — Boundary validation using language
