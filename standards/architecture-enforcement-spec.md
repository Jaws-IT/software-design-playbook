---

# Infrastructure Naming Doctrine

Status: Authoritative  
Scope: Integration and Infrastructure layers  
Applies to: Class naming and semantic boundaries  

---

1. Principle

Business semantics must not leak into infrastructure implementation class names.

Infrastructure represents technical mechanisms, not domain meaning.

Semantic naming belongs exclusively to:

- Application layer ports
- Integration layer contracts
- Domain types

Infrastructure implementations must remain mechanism-only.

---

2. Layered Naming Split

A strict separation is required:

A. Semantic Layer (Application / Integration)

Examples:

- AvailabilityRequestPublisherPort
- AvailabilityResultConsumerPort
- BookingCommandGateway
- ExecutionSuggestionEventContract

These names may contain domain/business nouns.

They define intent and meaning.

---

B. Infrastructure Layer (Mechanism Only)

Examples:

- InMemoryMessagePublisher
- KafkaMessagePublisher
- HttpMessageSender
- BrokerConnectionHealthProbe
- PostgresEventStore
- JdbcRepositoryAdapter

Infrastructure names must:

- Describe technical mechanism
- Describe protocol or technology
- Describe storage or transport
- Avoid business nouns

Forbidden in infrastructure names:

- Availability
- Booking
- Capacity
- Suggestion
- Customer
- Any bounded-context semantic term

---

3. Wiring Responsibility

Semantic ports are bound to infrastructure implementations in configuration.

Example mapping:

    AvailabilityRequestPublisherPort
        -> KafkaMessagePublisher

The wiring layer performs the binding.

Infrastructure must not encode business intent in its name.

---

4. Rationale

This doctrine enforces: 

- Clean onion boundaries
- Replaceable infrastructure
- Business/mechanism separation
- Clear semantic ownership
- Reduced conceptual leakage

If infrastructure contains business nouns,
semantic responsibility has collapsed outward.

---

5. Enforcement Strategy

This rule may be validated by:

- Static naming scans
- ArchUnit rules checking package + class name patterns
- CI checks disallowing domain nouns in infrastructure packages

Violation of this doctrine indicates layer responsibility breach.

End of Infrastructure Naming Doctrine.