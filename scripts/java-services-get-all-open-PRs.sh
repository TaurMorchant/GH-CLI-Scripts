#!/usr/bin/env bash
set -euo pipefail

REPOS=(
  "1|https://github.com/Netcracker/qubership-core-config-server"
  "2|https://github.com/Netcracker/qubership-core-core-operator"
)

LIMIT=200

for ENTRY in "${REPOS[@]}"; do
  IFS='|' read -r NUM REPO <<< "$ENTRY"
  echo "#### [$NUM] $REPO"
  if ! JSON=$(gh pr list --repo "$REPO" --state open --limit "$LIMIT" --json number,title,url 2>/dev/null); then
    echo "  (Error: Failed to get PR via gh)"
    echo
    continue
  fi

  COUNT=$(printf "%s" "$JSON" | jq 'length')
  if [ "$COUNT" -eq 0 ]; then
    echo "  (no open PRs)"
    echo
    continue
  fi

  printf "%s" "$JSON" | jq -r 'sort_by(.number)[] | "- PR \(.number): \(.title) — \(.url)"'
  echo
done
