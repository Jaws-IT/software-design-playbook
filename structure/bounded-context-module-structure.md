# Bounded Context Module Structure

## Default Structural Doctrine

Every bounded context SHOULD follow a four-layer structure:

domain  
application  
integration  
infrastructure  

This structure encodes authority, ownership, and separation of concerns.  
It is the default model for all production-grade systems.

---

## 1. domain

Represents internal semantic truth.

Contains:
- Aggregates  
- Value Objects  
- Domain Commands  
- Domain Events  
- Domain Errors  
- Domain Services  
- Repository interfaces (ports)

Rules:
- Must not depend on application  
- Must not depend on integration  
- Must not depend on infrastructure  
- Must not contain framework annotations  
- Must not contain transport concerns  
- Must not contain versioning logic  

Domain is pure business logic.

---

## 2. application

Represents use-case orchestration.

Contains:
- Command Handlers  
- Query Handlers  
- Application Services  
- Coordination logic across domain services  
- Transaction boundaries  

Rules:
- May depend on domain  
- Must not depend on infrastructure  
- Must not contain transport annotations  
- Must not contain framework-specific constructs  

Application orchestrates domain logic.  
It does not contain infrastructure logic.

---

## 3. integration

Represents the bounded context’s published language.

Contains:
- Integration Events (explicitly versioned)  
- Integration Commands (if modeled)  
- External contract DTOs  
- Contract version definitions  

Characteristics:
- Transport-agnostic  
- Technology-agnostic  
- Explicitly versioned  
- Stable across time  

Rules:
- May reference domain types  
- Must not depend on infrastructure  
- Must not contain transport annotations  
- Must not contain Kafka, REST, Avro, or serialization framework bindings  

Integration represents semantic contracts, not technical delivery.

---

## 4. infrastructure

Represents technical mechanisms.

Contains:
- REST controllers  
- Message broker adapters  
- File adapters  
- Database implementations  
- ORM mappings  
- Outbox implementations  
- Framework configuration  

Rules:
- May depend on integration  
- May depend on application  
- May depend on domain  
- Nothing may depend on infrastructure  

Infrastructure handles delivery and persistence.  
It does not define business meaning.

---

## Layer Direction Rule (Onion Principle)

Dependencies must always point inward:

infrastructure → integration → application → domain

Never the reverse.

Domain must remain unaware of outer layers.

---

## Enforcement Mode

For:
- Enterprise systems  
- Long-lived systems  
- Multi-team systems  
- Distributed systems  

This structure is mandatory.

---

## Exception Mode

For:
- Prototypes  
- Disposable tools  
- Experimental spikes  

The structure may be simplified.

However:

The simplification must be conscious.

The architect must explicitly answer:

“Why is separation of domain, contract, and infrastructure unnecessary here?”

Convenience is not sufficient justification.

---

## Architectural Rationale

Collapsing semantic contracts and infrastructure into a single “boundary” concept creates cognitive ambiguity between:

- Business meaning  
- Published language  
- Versioning responsibility  
- Transport mechanism  

The four-layer structure prevents this ambiguity and preserves architectural clarity.
