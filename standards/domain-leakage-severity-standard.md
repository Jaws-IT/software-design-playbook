# Domain Leakage Severity Standard

Version: 1.0.0

Status: Authoritative  
Scope: Severity assignment for domain leakage findings  
Applies to: Agent findings, architecture reviews, remediation planning

---

## 1. Purpose

This standard defines a consistent severity model for leakage findings.

It does not define leakage patterns.
Pattern definitions are in:

- `principles/domain-leakage-taxonomy.md`

---

## 2. Classification Axes

Every finding must be classified on two axes before final severity assignment.

### Axis A — Structural vs Incidental

| Type | Definition |
|---|---|
| `STRUCTURAL` | Leakage is embedded in boundaries, ownership model, or architecture shape. Fix usually requires design change. |
| `INCIDENTAL` | Leakage is a localized deviation inside otherwise valid architecture. Fix usually requires refactoring. |

### Axis B — Strategic vs Tactical

| Type | Definition |
|---|---|
| `STRATEGIC` | Affects bounded-context autonomy, cross-context coupling, or system coordination risk. |
| `TACTICAL` | Affects correctness/clarity inside a single context's model and behavior. |

---

## 3. Severity Matrix

| Impact \ Structure | `STRUCTURAL` | `INCIDENTAL` |
|---|---|---|
| `STRATEGIC` | `CRITICAL` | `HIGH` |
| `TACTICAL` | `HIGH` | `MEDIUM` |

Use `LOW` only when issue is documentation-only or ambiguous with no clear model impact.

---

## 4. Escalation Rules

Always assign `CRITICAL` when either condition applies:

- context boundary is missing/implicit (`BOUNDARY-00`)
- integration boundary translation is absent with direct model coupling (`CROSS_CONTEXT-06`) and structural evidence confirms dependency fragility

Default minimum severity by pattern family:

- `BOUNDARY-*`: `HIGH`, often `CRITICAL`
- `CROSS_CONTEXT-*`: `HIGH`, may escalate to `CRITICAL`
- `RESPONSIBILITY-*`: `HIGH` in most cases
- `MODEL_INTEGRITY-*`: `MEDIUM` to `HIGH` depending on impact

---

## 5. Required Evidence Threshold

A severity claim must include:

1. concrete detection signal
2. ownership/coupling explanation
3. plausible failure mode or change-risk consequence

If evidence is weak, lower confidence and avoid over-severity.

---

## 6. Output Contract

Each finding must include:

- `id` (taxonomy ID)
- `structure_class`: `STRUCTURAL` or `INCIDENTAL`
- `impact_class`: `STRATEGIC` or `TACTICAL`
- `severity`: `CRITICAL` | `HIGH` | `MEDIUM` | `LOW`
- `confidence`: `HIGH` | `MEDIUM` | `LOW`
- `evidence`

---

End of Domain Leakage Severity Standard.
