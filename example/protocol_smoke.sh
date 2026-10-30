#!/bin/sh
set -eu

SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
ENV_FILE=${ENV_FILE:-"$SCRIPT_DIR/.env"}
if [ ! -f "$ENV_FILE" ]; then
  echo "Missing $ENV_FILE. Copy example/.env.example to example/.env and edit it." >&2
  exit 1
fi

set -a
. "$ENV_FILE"
set +a

: "${GATEWAY_URL:?Set GATEWAY_URL in .env}"
: "${API_KEY:?Set API_KEY in .env}"
: "${MODEL:?Set MODEL in .env}"
: "${ADAPTER:?Set ADAPTER in .env}"

GATEWAY_URL=${GATEWAY_URL%/}
BASE_URL=${BASE_URL:-}
CHAT_ENDPOINT=${CHAT_ENDPOINT:-}
RESPONSES_ENDPOINT=${RESPONSES_ENDPOINT:-}
MESSAGES_ENDPOINT=${MESSAGES_ENDPOINT:-}
PROTOCOL=${PROTOCOL:-all}
MAX_TOKENS=${MAX_TOKENS:-128}

request_chat() {
  echo "POST $GATEWAY_URL/v1/chat/completions (model=$MODEL, adapter=$ADAPTER)"
  curl --fail-with-body --silent --show-error \
    "$GATEWAY_URL/v1/chat/completions" \
    --header "Authorization: Bearer $API_KEY" \
    --header 'Content-Type: application/json' \
    --data-binary @- <<EOF_CHAT
{
  "model": "$MODEL",
  "adapter": "$ADAPTER",
  "base_url": "$BASE_URL",
  "endpoint": "$CHAT_ENDPOINT",
  "messages": [{"role": "user", "content": "Reply with OK."}],
  "stream": false
}
EOF_CHAT
  echo
}

request_responses() {
  echo "POST $GATEWAY_URL/v1/responses (model=$MODEL, adapter=$ADAPTER)"
  curl --fail-with-body --silent --show-error \
    "$GATEWAY_URL/v1/responses" \
    --header "Authorization: Bearer $API_KEY" \
    --header 'Content-Type: application/json' \
    --data-binary @- <<EOF_RESPONSES
{
  "model": "$MODEL",
  "adapter": "$ADAPTER",
  "base_url": "$BASE_URL",
  "endpoint": "$RESPONSES_ENDPOINT",
  "input": "Reply with OK.",
  "stream": false
}
EOF_RESPONSES
  echo
}

request_messages() {
  echo "POST $GATEWAY_URL/v1/messages (model=$MODEL, adapter=$ADAPTER)"
  curl --fail-with-body --silent --show-error \
    "$GATEWAY_URL/v1/messages" \
    --header "x-api-key: $API_KEY" \
    --header 'anthropic-version: 2023-06-01' \
    --header 'Content-Type: application/json' \
    --data-binary @- <<EOF_MESSAGES
{
  "model": "$MODEL",
  "adapter": "$ADAPTER",
  "base_url": "$BASE_URL",
  "endpoint": "$MESSAGES_ENDPOINT",
  "max_tokens": $MAX_TOKENS,
  "messages": [{"role": "user", "content": "Reply with OK."}],
  "stream": false
}
EOF_MESSAGES
  echo
}

case "$PROTOCOL" in
  chat|chat_completions) request_chat ;;
  responses) request_responses ;;
  messages) request_messages ;;
  all)
    request_chat
    request_responses
    request_messages
    ;;
  *)
    echo "PROTOCOL must be chat, responses, messages, or all." >&2
    exit 2
    ;;
esac
