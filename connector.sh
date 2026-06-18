#!/bin/bash
# JSONPlaceholder connector adapter
# Governed tool for runx jsonplaceholder-connector skill
# Usage: connector.sh <method> <resource> [id] [payload]

METHOD="${1:-GET}"
RESOURCE="${2:-posts}"
ID="${3:-}"
PAYLOAD="${4:-}"

BASE="https://jsonplaceholder.typicode.com"
URL="$BASE/$RESOURCE"
[ -n "$ID" ] && URL="$URL/$ID"

case "$METHOD" in
  GET)
    curl -s "$URL" 2>/dev/null
    ;;
  POST)
    curl -s -X POST "$URL" -H "Content-Type: application/json" -d "${PAYLOAD:-{}}" 2>/dev/null
    ;;
  PUT)
    curl -s -X PUT "$URL" -H "Content-Type: application/json" -d "${PAYLOAD:-{}}" 2>/dev/null
    ;;
  DELETE)
    curl -s -X DELETE "$URL" 2>/dev/null
    ;;
  PREFLIGHT)
    HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" "$URL" 2>/dev/null)
    if [ "$HTTP_CODE" -ge 200 ] && [ "$HTTP_CODE" -lt 500 ]; then
      echo "{\"status\":\"reachable\",\"http_code\":$HTTP_CODE}"
    else
      echo "{\"status\":\"unreachable\",\"http_code\":$HTTP_CODE}"
      exit 1
    fi
    ;;
  *)
    echo "Unknown method: $METHOD" >&2
    exit 1
    ;;
esac
