# Micro-Frontend Ownership Standard

Version: 1.0.0

Status: Authoritative for UI systems using micro-frontends  
Scope: Graphical and interactive frontend systems  
Applies to: Shell, micro-frontends, menu composition, navigation ownership

This standard defines who owns what in a micro-frontend system.

It exists to prevent shell takeover, widget leakage, and boundary collapse.

---

## 1. Core Rule

UI ownership must mirror domain ownership.

A micro-frontend is not a visual fragment first.
It is a capability boundary first.

Do not create micro-frontends around layout convenience.

---

## 2. Shell Responsibilities

The shell owns structural concerns only.

When a vertical slice uses a BFF-backed shell,
the BFF is the owner of those shell concerns.

The shell is responsible for:

- canvas layout
- canvas registration
- activation routing
- URL-to-canvas resolution
- browser history handling
- manifest registration
- composition of shared trigger locations such as menus

For vertical slices, this ownership split becomes:

- BFF owns page routes
- BFF owns page shells/layouts
- BFF owns navigation
- BFF owns container composition
- BFF owns widget inclusion rules

The shell must not own business behavior that belongs to a domain capability.

Forbidden shell behavior:

- implementing domain workflows
- deciding domain transitions inside shell code
- storing business state that belongs to a micro-frontend
- rendering capability-specific internals directly

---

## 3. Micro-Frontend Responsibilities

A micro-frontend owns its capability end to end inside its boundary.

Each micro-frontend owns:

- its trigger UI
- its content UI
- its internal state
- its internal navigation
- its forward state transitions
- its local error states
- its real-time updates and subscriptions

If a capability renders something and reacts to it,
that capability should usually own both the trigger and the resulting content.

---

## 4. Ownership Boundary Rule

The shell may activate a micro-frontend.
It may not orchestrate the micro-frontend's internal business behavior.

The shell can say:

    activate "persona" in MAIN

The shell must not say:

    if persona is in state X, then show step Y and submit action Z

Once activated, the micro-frontend owns its own behavior.

---

## 5. Trigger Ownership Rule

Triggers belong to the same owning capability as the content they activate.

Examples:

- an Account entry in the menu belongs to the Account micro-frontend
- a Notifications trigger belongs to the Notifications micro-frontend
- a Claim Details shortcut belongs to the Claims micro-frontend

The shell may compose trigger placement,
but it must not semantically own another capability's trigger behavior.

---

## 6. Menu Composition Rule

Menus are composition points, not ownership centers.

Allowed:

- micro-frontends register menu contributions
- shell composes the visible menu
- shell controls placement and activation mapping

Forbidden:

- a central menu component hardcoding every business capability
- one micro-frontend owning the full menu for all others
- menu definitions that require direct imports between micro-frontends

---

## 7. URL and History Ownership

The shell owns URLs and browser history because these are cross-cutting structural concerns.

Micro-frontends must not implement browser back handling independently.

Micro-frontends may expose state that can be serialized or restored,
but the shell owns history coordination.

---

## 8. Shared State Rule

Shared state is allowed only when it is truly structural or cross-cutting.

Examples of acceptable shell-level shared state:

- active canvas composition
- authenticated session presence
- theme selection
- locale

Examples of forbidden shell-level shared state:

- in-progress business forms
- domain workflow step state
- capability-specific filters that belong to one micro-frontend
- business decisions cached for reuse across capabilities

Do not centralize domain state merely for convenience.

---

## 9. Cross-Micro-Frontend Interaction

One micro-frontend must not reach directly into another micro-frontend's internal state or components.

Interaction should occur through one of these:

- shell activation
- explicit published contracts
- events
- backend-mediated coordination

Direct component imports across micro-frontend boundaries are a coupling smell.

---

## 10. Boundary Alignment Rule

Micro-frontend boundaries should align with bounded contexts or clearly owned capabilities.

Avoid:

- splitting one bounded context across many arbitrary micro-frontends
- combining unrelated capabilities into one micro-frontend
- organizing UI ownership around page regions instead of domain meaning

Ownership is semantic before it is visual.

---

## 11. Decision Test

When ownership is unclear, ask:

1. Which capability owns the invariant?
2. Which capability owns the user intent?
3. Which capability changes state when the action succeeds?

The same boundary should usually own the UI.

---

## 12. Anti-Patterns

The following are violations of this standard:

- shell-owned business widgets
- central orchestrator menus with hardcoded domain logic
- direct imports between unrelated micro-frontends
- shell-managed capability internals
- shared stores containing multiple capability-specific business states
- visual decomposition without domain ownership

---

## 13. Relationship to Other Documents

This standard complements:

- [architecture/frontend/micro-frontend-canvas-architecture.md](architecture/frontend/micro-frontend-canvas-architecture.md)
- [standards/architecture-enforcement-spec.md](standards/architecture-enforcement-spec.md)
- [standards/bounded-context-independence-doctrine.md](standards/bounded-context-independence-doctrine.md)

Use this file when the question is ownership.
Use the architecture pattern when the question is shell and canvas structure.
