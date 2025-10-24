#!/usr/bin/env bash
set -euo pipefail

REPOS=(
  "1.1|https://github.com/Netcracker/qubership-core-lib-go-error-handling"
  "1.2|https://github.com/Netcracker/qubership-core-lib-go"
  "2.1|https://github.com/Netcracker/qubership-core-lib-go-actuator-common"
  "2.2|https://github.com/Netcracker/qubership-core-lib-go-dbaas-base-client"
  "2.3|https://github.com/Netcracker/qubership-core-lib-go-rest-utils"
  "2.4|https://github.com/Netcracker/qubership-core-lib-go-bg-state-monitor"
  "2.5|https://github.com/Netcracker/qubership-core-lib-go-stomp-websocket"
  "3.1|https://github.com/Netcracker/qubership-core-lib-go-bg-kafka"
  "3.2|https://github.com/Netcracker/qubership-core-lib-go-dbaas-clickhouse-client"
  "3.3|https://github.com/Netcracker/qubership-core-lib-go-dbaas-postgres-client"
  "3.4|https://github.com/Netcracker/qubership-core-lib-go-dbaas-mongo-client"
  "3.5|https://github.com/Netcracker/qubership-core-lib-go-dbaas-cassandra-client"
  "3.6|https://github.com/Netcracker/qubership-core-lib-go-maas-client"
  "3.7|https://github.com/Netcracker/qubership-core-lib-go-dbaas-arangodb-client"
  "3.8|https://github.com/Netcracker/qubership-core-lib-go-fiber-server-utils"
  "3.9|https://github.com/Netcracker/qubership-core-lib-go-paas-mediation-client"
  "3.10|https://github.com/Netcracker/qubership-core-lib-go-dbaas-opensearch-client"
  "4.1|https://github.com/Netcracker/qubership-core-lib-go-maas-core"
  "4.2|https://github.com/Netcracker/qubership-core-lib-go-maas-segmentio"
  "5.1|https://github.com/Netcracker/qubership-core-lib-go-maas-bg-segmentio"
)

LIMIT=200

for ENTRY in "${REPOS[@]}"; do
  IFS='|' read -r NUM REPO <<< "$ENTRY"
  echo "#### [$NUM] $REPO"
  if ! JSON=$(gh pr list --repo "$REPO" --state open --limit "$LIMIT" --search "-is:draft" --json number,title,url 2>/dev/null); then
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
