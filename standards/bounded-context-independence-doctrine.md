# Bounded Context Independence Doctrine

Version: 1.0.0

Status: Authoritative  
Scope: All bounded contexts  
Applies to: Structural design, implementation, and testing  

---

1. Principle

Every bounded context must be independently implementable and independently testable.

A bounded context must not require another bounded context to:

- Compile
- Start
- Execute core use cases
- Run tests
- Validate business logic

Integration between bounded contexts must occur strictly through defined integration contracts.

---

2. Independence Definition

A bounded context is independent if:

- Its domain layer has no compile-time dependency on another bounded context’s domain.
- Its application layer does not invoke another bounded context directly.
- All cross-context communication occurs through integration ports.
- Tests can run without bootstrapping other bounded contexts.
- The context can be developed in isolation.

Independence is structural, not deployment-based.

---

3. Forbidden Patterns

The following violate independence:

- Domain → Domain imports across bounded contexts.
- Application layer calling another bounded context directly.
- Shared domain entities across bounded contexts.
- Cross-context repository access.
- Test suites requiring another bounded context to be running.
- Circular dependency chains between contexts.

---

4. Allowed Integration Model

Bounded contexts may communicate only through:

- Integration contracts (interfaces, DTOs, events).
- Translation layers at the integration boundary.
- Event-driven communication.
- Explicit anti-corruption layers.

No direct domain coupling is permitted.

---

5. Execution-Suggestion Example

The bounded context "execution-suggestion" must:

- Contain its own domain model.
- Contain its own application orchestration.
- Define its own integration contracts.
- Be testable without booting capacity, customer, sales, or any other context.
- Translate external inputs into its own internal model.

It must not depend on internal domain types of other bounded contexts.

---

6. Test Isolation Requirement

Each bounded context must support:

- Unit tests for domain logic.
- Application-layer tests without requiring external contexts.
- Integration-layer tests using stubs or mocks.
- Full Maven test execution in isolation.

Running:

    mvn -pl modules/execution-suggestion test

must succeed without requiring other modules to start.

---

7. Architectural Rationale

Bounded context independence ensures:

- Parallel development.
- Replaceability.
- Clear ownership.
- Reduced hidden coupling.
- Controlled integration complexity.
- Deterministic architectural enforcement.

Loss of independence leads to implicit monolith behavior.

---

8. Enforcement

Independence may be verified through:

- ArchUnit rules preventing cross-context domain imports.
- Maven module isolation.
- Dependency direction checks.
- CI enforcement policies.
- Structural validation scripts.

Independence is mandatory, not advisory.

End of Bounded Context Independence Doctrine.