#!/usr/bin/env bash
# Version: 1.0.0

MODEL="$1"
PROMPT_FILE="$2"

curl https://api.anthropic.com/v1/messages \
  -s \
  -H "x-api-key: $ANTHROPIC_API_KEY" \
  -H "anthropic-version: 2023-06-01" \
  -H "Content-Type: application/json" \
  -d "{
    \"model\": \"$MODEL\",
    \"max_tokens\": 4096,
    \"messages\": [
      {\"role\":\"user\",\"content\": $(jq -Rs . < "$PROMPT_FILE")}
    ]
  }" \
| jq -r '.content[0].text'
