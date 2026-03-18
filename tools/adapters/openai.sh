#!/usr/bin/env bash
# Version: 1.0.0

MODEL="$1"
PROMPT_FILE="$2"

curl https://api.openai.com/v1/responses \
  -s \
  -H "Authorization: Bearer $OPENAI_API_KEY" \
  -H "Content-Type: application/json" \
  -d "{
    \"model\": \"$MODEL\",
    \"input\": $(jq -Rs . < "$PROMPT_FILE")
  }" \
| jq -r '.output[0].content[0].text'
