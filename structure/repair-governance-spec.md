# Repair Governance Specification

Version: 1.0.0

Status: Authoritative  
Applies to: Automated AI repair stage only

This specification defines what the repair stage is allowed to modify.

---

# 1. Authority Boundaries

There are two mutation phases:

PLAN phase:
- May introduce new public APIs.
- May introduce new aggregates.
- May extend contracts.
- May rename methods if story requires.

REPAIR phase:
- May NOT introduce new public APIs.
- May NOT rename aggregates.
- May NOT delete domain behavior.
- May NOT redesign architecture.
- May NOT change bounded context boundaries.

---

# 2. Allowed Repair Operations

Repair stage may:

- Replace `throw` with `Either`
- Remove illegal imports
- Move classes to correct layer
- Add missing translators
- Adjust visibility modifiers
- Fix dependency direction violations
- Apply minor refactors

Repair must preserve architectural intent.

---

# 3. Public API Protection

Before repair begins:

- Snapshot all public classes and public method signatures.

During repair:

- If public API changes and change was NOT defined in PLAN phase → abort.
- If public API change exceeds story scope → abort.

---

# 4. Mutation Threshold Guard

Repair must abort if:

- More than 8 files modified
- OR more than 500 lines changed
- OR more than 40% of any single file replaced

These limits prevent structural rewrite.

---

# 5. Hard Stop Rule

If repair attempts exceed 5 iterations → abort.

No infinite loops.
No autonomous redesign.
