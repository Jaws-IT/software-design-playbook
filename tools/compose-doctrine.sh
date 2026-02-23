#!/usr/bin/env bash

set -e

ROOT_DIR="$(git rev-parse --show-toplevel)"

DOCTRINE_FILE="$ROOT_DIR/tools/.doctrine-bundle.tmp"

cat \
  "$ROOT_DIR/structure/bounded-context-module-structure.md" \
  "$ROOT_DIR/standards/architecture-enforcement-spec.md" \
  "$ROOT_DIR/principles/code-rules.md" \
  "$ROOT_DIR/standards/repair-governance-spec.md" \
  > "$DOCTRINE_FILE"

echo "$DOCTRINE_FILE"
