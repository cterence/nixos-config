#!/usr/bin/env bash

set -euo pipefail
b64url_decode() {
  local d="${1//-/+}"; d="${d//_//}"
  local pad=$(( (4 - ${#d} % 4) % 4 ))
  printf '%s' "$d$(printf '=%.0s' $(seq 1 "$pad"))" | base64 -d 2>/dev/null
}
token=$(curl -s -H "Authorization: bearer $ACTIONS_ID_TOKEN_REQUEST_TOKEN" \
  "$ACTIONS_ID_TOKEN_REQUEST_URL&audience=https://niks3.terence.cloud" | jq -r '.value')
exp=$(b64url_decode "$(cut -d. -f2 <<<"$token")" | jq -r '.exp')
jq -nc --arg t "$token" --argjson e "$exp" '{token:$t, expires_at:($e|todate)}'
