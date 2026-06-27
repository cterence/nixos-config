#!/usr/bin/env bash
set -euo pipefail

token=$(curl -sf -H "Authorization: bearer $ACTIONS_ID_TOKEN_REQUEST_TOKEN" \
  "$ACTIONS_ID_TOKEN_REQUEST_URL&audience=https://niks3.terence.cloud" | jq -r '.value')

if [ -z "$token" ] || [ "$token" = "null" ]; then
  echo "failed to obtain OIDC token" >&2
  exit 1
fi

exp=$(date -u -d '+4 minutes' +%Y-%m-%dT%H:%M:%SZ 2>/dev/null || date -u -v+4M +%Y-%m-%dT%H:%M:%SZ)

jq -nc --arg t "$token" --arg e "$exp" '{token:$t, expires_at:$e}'
