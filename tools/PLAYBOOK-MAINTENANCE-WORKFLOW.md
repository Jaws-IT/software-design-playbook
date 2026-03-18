# Playbook Maintenance Workflow

Version: 1.0.0

Date: February 28, 2026

## Goal

Prevent silent doctrine loss.

Every change to the playbook must make it clear whether content was:

- preserved
- expanded
- moved
- intentionally removed

## Default Rule

Enhance existing files. Do not replace them wholesale unless the replacement is explicitly approved and the removed content is accounted for in the diff.

## Mandatory Pre-Edit Steps

1. Run `tools/playbook-audit.sh`.
2. Read the current file before editing it.
3. Check the previous committed version with `git diff` or `git show`.
4. Write down the intended change type: `append`, `clarify`, `restructure`, or `replace`.

If the change type is `replace`, stop and justify what content is being removed or superseded.

## Allowed Change Types

### Append

Add new sections without deleting existing doctrine.

Use when the file is fundamentally sound and only needs more detail.

### Clarify

Rewrite local wording while preserving meaning and coverage.

Use when the document is correct but unclear.

### Restructure

Move material into a better order while preserving coverage.

Use when the content is present but badly organized.

### Replace

Use only when the current file is known-bad, incomplete, or superseded.

Replacement requires:

- a reason
- a prior-version review
- an explicit note about what content is intentionally dropped

## Per-File Edit Protocol

For each file being touched:

1. Capture the current purpose of the file in one sentence.
2. Identify whether any sections are placeholders, missing, or stale.
3. Make the edit.
4. Review the diff for unintentional deletion.
5. Record unresolved gaps if any remain.

## Review Checklist

Before considering the change complete, verify:

- the file is not shorter because of accidental deletion
- placeholders such as `previous content remains the same` are gone
- related-file references point to real files
- new sections align with the repository's current taxonomy
- the git diff is readable and defensible

## Forbidden Moves

- Replacing an entire file from an AI response without reading the previous file
- Accepting placeholder text as if the old content still exists
- Leaving references to files that are not in the repository
- Mixing reconstruction work with unrelated new doctrine in the same pass

## Recommended Working Sequence

1. Stabilize incomplete files.
2. Repair references and structure.
3. Expand content area by area.
4. Commit small, reviewable changes.

## Definition of Done

A playbook update is complete only when:

- the target file is internally coherent
- the diff shows what changed and why
- no earlier doctrine was silently dropped
- the repository audit remains clean or the remaining gaps are explicitly documented
