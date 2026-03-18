#!/usr/bin/env bash
# Version: 1.0.0

set -e

BC="$1"
STORY="$2"

MAX_REPAIRS=5
PLANNER_MODEL="claude-3-opus-20240229"
GENERATOR_MODEL="gpt-4.1"
REPAIR_MODEL="gpt-5"

PROVIDER="openai"

ROOT_DIR="$(git rev-parse --show-toplevel)"
MODULE_DIR="$ROOT_DIR/modules/$BC"

TMP_PROMPT="$ROOT_DIR/tools/.prompt.tmp"
TMP_OUTPUT="$ROOT_DIR/tools/.output.tmp"
TMP_FILES_DIR="$ROOT_DIR/tools/.generated-files"

mkdir -p "$TMP_FILES_DIR"

############################################
# Safety Check
############################################

if [ -z "$BC" ] || [ -z "$STORY" ]; then
  echo "Usage: ai-pipeline <bounded-context> \"<story>\""
  exit 1
fi

if ! git diff --quiet; then
  echo "Uncommitted changes detected. Abort."
  exit 1
fi

############################################
# Compose Doctrine
############################################

DOCTRINE_FILE=$(bash "$ROOT_DIR/tools/compose-doctrine.sh")

############################################
# Helper: Write Files From Model Output
############################################

write_files_from_output() {
  rm -rf "$TMP_FILES_DIR"
  mkdir -p "$TMP_FILES_DIR"

  awk '
    /^=== FILE:/ {
      file=$3
      gsub("===", "", file)
      gsub(":", "", file)
      close(out)
      out=file
      next
    }
    { print > out }
  ' "$TMP_OUTPUT"

  # Move files into project
  while IFS= read -r file; do
    TARGET="$ROOT_DIR/$file"
    mkdir -p "$(dirname "$TARGET")"
    mv "$file" "$TARGET"
  done < <(grep -o '^=== FILE: .* ===' "$TMP_OUTPUT" | awk '{print $3}')
}

############################################
# STEP 1 — PLAN
############################################

cat > "$TMP_PROMPT" <<EOF
$STORY

Create a structural plan only.
Define aggregates, methods, Either return types, and layer placement.
Do NOT generate implementation code.

Doctrine:
$(cat "$DOCTRINE_FILE")
EOF

bash "$ROOT_DIR/tools/adapters/$PROVIDER.sh" \
  "$PLANNER_MODEL" "$TMP_PROMPT" > "$TMP_OUTPUT"

PLAN_CONTENT=$(cat "$TMP_OUTPUT")

############################################
# STEP 2 — GENERATE
############################################

cat > "$TMP_PROMPT" <<EOF
Implement the following plan.

Output MUST use this exact format:

=== FILE: relative/path/from/project/root ===
<full file content>

Plan:
$PLAN_CONTENT

Constraints:
- No throw
- Use Either
- Respect folder structure
- Respect doctrine

Doctrine:
$(cat "$DOCTRINE_FILE")
EOF

bash "$ROOT_DIR/tools/adapters/$PROVIDER.sh" \
  "$GENERATOR_MODEL" "$TMP_PROMPT" > "$TMP_OUTPUT"

write_files_from_output

############################################
# STEP 3 — ENFORCE + REPAIR LOOP
############################################

attempt=0

while true; do
  if mvn -q test; then
    echo "SUCCESS"
    exit 0
  fi

  if [ "$attempt" -ge "$MAX_REPAIRS" ]; then
    echo "Max repair attempts reached."
    exit 1
  fi

  FAILURE_OUTPUT=$(mvn test 2>&1)

  cat > "$TMP_PROMPT" <<EOF
The following architectural violations occurred:

$FAILURE_OUTPUT

Fix violations.
Do NOT redesign architecture.
Do NOT introduce throw.
Preserve public API unless story requires.

Output MUST use:

=== FILE: relative/path/from/project/root ===
<full file content>

Doctrine:
$(cat "$DOCTRINE_FILE")
EOF

  bash "$ROOT_DIR/tools/adapters/$PROVIDER.sh" \
    "$REPAIR_MODEL" "$TMP_PROMPT" > "$TMP_OUTPUT"

  write_files_from_output

  attempt=$((attempt+1))
done
