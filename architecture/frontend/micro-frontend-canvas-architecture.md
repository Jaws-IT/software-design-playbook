# Micro-Frontend Canvas Architecture

Status: Pattern  
Category: Architectural Pattern  
Scope: Graphical / Interactive Frontend Systems

This document describes a canvas-based micro-frontend architecture.

It is optional.  
It should be applied only when domain boundaries justify UI separation.

---

# 1. Core Principle

A UI system should not be modeled as "pages".

It should be modeled as:

- One Shell
- Multiple Canvases (render targets)
- Micro-frontends activated inside canvases

Navigation is not page transition.

Navigation is activation of a capability inside a canvas.

---

# 2. Shell Model

The Shell is responsible for:

- Canvas layout
- Canvas registration
- Micro-frontend manifest
- Initial canvas state
- URL-to-canvas resolution
- Browser history management
- Activation routing

The Shell is structural.

The Shell contains no business behavior.

---

# 3. Canvas Concept

A Canvas is a named render target.

Examples:

- NAV
- MAIN
- FOOTER
- MODAL
- TOAST

A canvas defines where a micro-frontend renders.

A canvas does not define what renders.

---

# 4. Micro-Frontend Ownership Model

Each micro-frontend owns:

- Its trigger UI
- Its content UI
- Its internal state
- Its internal navigation
- Its real-time updates
- Its forward state transitions

A micro-frontend owns both its trigger and its content.

The Shell does not own widget internals.

---

# 5. Navigation Model

Navigation means:

    Activate micro-frontend Y in canvas Z

Not:

    Go to page X

Example flow:

User clicks "My Account"
→ Shell activates Persona MF in MAIN canvas
→ Shell pushes history state { main: "persona" }

---

# 6. URL as Canvas State Serialization

URLs exist for:

- Bookmarking
- Deep linking
- State restoration

They do not imply page existence.

Example:

    /my-account
        → Activate Persona MF in MAIN

The BFF or routing layer maps path → canvas activation instructions.

---

# 7. Browser History Discipline

The Shell owns browser history.

When browser back occurs:

- Shell receives popstate
- Shell restores previous canvas state
- Micro-frontend is reactivated

Widgets must not implement browser back logic.

Widgets move forward only.

---

# 8. Forward-Only State Transitions

Widgets should model state explicitly.

Recommended approach:

- Sealed state hierarchy
- Explicit transition function
- No implicit state mutation
- No try/catch control flow

Example (conceptual):

State A + Action X → State B  
State B + Action Y → State C

Cancel and Undo are forward transitions.

There is no backward state travel.

---

# 9. Railway-Style Error Handling

Widgets should:

- Avoid exceptions for control flow
- Use Either / Result types
- Propagate failure forward
- Resolve errors explicitly

Error is a state.

Error is not a jump.

---

# 10. Menu as Composition Point

Menus should not be owned by a single component.

Instead:

- Micro-frontends register their triggers
- Shell composes contributions
- Activation mapping remains centralized

This enables plugin-style extensibility.

---

# 11. Alignment with Domain Boundaries

Micro-frontend boundaries should mirror bounded context boundaries.

Do not split UI independently from domain ownership.

Each micro-frontend should correspond to a clear capability.

---

# 12. When to Apply

Use this pattern when:

- Multiple domain capabilities expose UI
- Independent deployment is required
- Teams own distinct domain areas
- UI complexity justifies isolation

Avoid when:

- One small UI
- Single team ownership
- Domain separation is artificial

---

# 13. Architectural Characteristics

This pattern provides:

- UI isolation
- Deployment flexibility
- Clear ownership boundaries
- Forward-only interaction modeling
- Clean separation of structure and behavior

It does not replace domain-driven design.

It must follow domain boundaries.

Never the reverse.

---

End of Micro-Frontend Canvas Architecture Pattern