# Micro-Frontend Canvas Architecture Pattern

Version: 1.0.0

Status: Optional Architectural Pattern  
Scope: UI-based systems  
Enforcement Level: Advisory (Not globally enforced)

---

## Intent

Define a compositional UI architecture where:

- The system serves a single structural shell
- Navigation activates capabilities rather than loading pages
- UI responsibilities are explicitly separated
- State flows forward in alignment with functional programming principles
- Browser history is centralized
- Micro-frontends remain isolated and self-contained

This pattern applies only when building graphical user interfaces.  
It is not required for API-only or non-visual systems.

---

# 1. Core Principle

## Canvas-Based Shell, Not Pages

The system does not serve multiple document-centric pages.

It serves one structural shell that contains render targets ("canvases").

Navigation is the act of activating a capability inside a canvas.

Conceptually:

- Shell = Layout + Canvas orchestration
- Micro-Frontend = Self-contained capability rendered inside a canvas

Example conceptual canvases:

- NAV
- MAIN
- FOOTER
- MODAL
- TOAST

These are render targets, not routing destinations.

---

# 2. Ownership Model

Clear ownership boundaries are mandatory.

## 2.1 Shell Owns

- Structural layout
- Canvas definitions
- Initial canvas state
- Capability registration manifest
- URL to canvas-state resolution
- Browser history integration
- Back button handling

The shell does not:

- Implement domain logic
- Own widget state
- Perform business decisions

The shell is orchestration only.

---

## 2.2 Micro-Frontend Owns

Each micro-frontend owns:

- Its trigger UI (button, menu item, link)
- Its rendered content
- All internal UI state transitions
- Internal multi-step flows
- Real-time domain connections (e.g., WebSocket)
- Validation and submission state handling

A micro-frontend owns both its activation trigger and its content.

The shell does not create trigger UI on behalf of widgets.

---

# 3. Menu Composition Pattern

The menu is a composition point.

It is not owned by a single component.

Each micro-frontend contributes its own trigger.

The shell composes contributions.

Implications:

- Inversion of control
- Capability registration model
- No centralized menu logic

This aligns with strategic plugin composition patterns.

---

# 4. Navigation Model

Navigation means:

"Activate micro-frontend X in canvas Y"

It does not mean:

"Load page X"

Example:

User activates capability  
→ Shell activates target micro-frontend in MAIN canvas  
→ Shell pushes serialized canvas state to history

Navigation is canvas state mutation.

---

# 5. URL as Canvas State Serialization

URLs exist for:

- Bookmarkability
- Deep linking
- State restoration

URLs do not represent documents.

They represent canvas activation state.

Example mapping conceptually:

- `/` → MAIN = Landing
- `/account` → MAIN = Persona widget
- `/listings` → MAIN = Listings widget

A routing component maps path → canvas activation instructions.

---

# 6. Browser History Ownership

History belongs to the shell.

Widgets do not manipulate browser history.

When the user presses back:

- Shell receives popstate
- Shell restores previous canvas state
- Appropriate micro-frontend is activated

Widgets never "go back".

They only move forward internally.

---

# 7. Forward-Only State Principle

Widget state transitions must be forward-only.

No implicit backtracking.
No try-catch as control flow.
No hidden jumps.

State transitions are explicit.

Errors are values.
Transitions are deterministic.

This aligns with functional Either / Result modeling.

Example structure:

```
Initial
→ ShowingForm
→ Submitting
→ Failed
→ Success
```

Retry is a forward transition.
Cancel is a forward transition.
Undo is modeled explicitly.

---

# 8. Separation from Backend Links

Backend-generated links (verification, reset-password, etc.) are independent concerns.

They may:

- Trigger backend actions
- Result in new canvas activation

They are not coupled to canvas design.

Canvas architecture does not constrain backend action endpoints.

---

# 9. Architectural Constraints (Advisory)

If adopting this pattern:

- Shell must remain thin
- Widgets must remain isolated
- No widget may control another widget’s canvas
- No cross-widget internal state mutation
- No direct domain leakage through shell
- No page-based routing fallback

---

# 10. When To Use This Pattern

Use when:

- You have multiple independently deployable UI capabilities
- Teams own separate bounded contexts
- You want frontend boundaries aligned with backend bounded contexts
- You need runtime composition

Do not use when:

- The system is simple
- UI complexity does not justify separation
- Teams are not independent
- Deployment separation is unnecessary

---

# 11. Relationship to Backend Bounded Contexts

This pattern works best when:

- Each micro-frontend maps to a backend bounded context
- Ownership boundaries mirror domain boundaries
- Widget isolation matches aggregate ownership philosophy

It extends DDD boundaries into the UI layer.

---

# 12. Non-Goals

This pattern does not prescribe:

- Specific UI framework
- Specific transport layer (HTMX, React, etc.)
- Specific bundling strategy
- Specific SSR/CSR approach

It defines responsibility boundaries only.

---

# 13. Enforcement Level

This pattern is advisory.

It should be referenced in:

- architecture-enforcement-spec.md (as optional pattern)
- strategic design discussions
- frontend system design sessions

It is not globally mandatory.

---

# End of File