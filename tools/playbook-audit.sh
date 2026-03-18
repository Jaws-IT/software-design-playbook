#!/usr/bin/env bash
# Version: 1.0.0

set -euo pipefail

ROOT_DIR="$(git rev-parse --show-toplevel)"
cd "$ROOT_DIR"

AUDIT_TARGETS=(
  agents
  architecture
  examples
  patterns
  principles
  standards
  structure
  tools/WORKFLOW.md
)

echo "Playbook audit"
echo "Repository: $ROOT_DIR"
echo

echo "Git state"
git status --short --branch
echo

echo "Markdown inventory"
find . -type f -name '*.md' | sort | while read -r file; do
  lines="$(wc -l < "$file" | tr -d ' ')"
  printf '%5s  %s\n' "$lines" "$file"
done
echo

echo "Empty markdown files"
find . -type f -name '*.md' -empty | sort || true
echo

echo "Placeholder markers"
rg -n '\[Previous|TODO|TBD|remain the same|placeholder|coming soon' "${AUDIT_TARGETS[@]}" || true
echo

echo "Stale file references"
rg -n '01-principles|02-code-rules|03-anti-patterns|04-testing-patterns|05-clean-code-formatting|06-error-handling-patterns|07-competency-by-level|08-architectural-decision-patterns|09-strategic-design-patterns|standards/repair-governance-spec\.md' "${AUDIT_TARGETS[@]}" || true
