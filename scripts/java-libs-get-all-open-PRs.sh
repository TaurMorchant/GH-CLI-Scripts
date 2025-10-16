#!/usr/bin/env bash
set -euo pipefail

REPOS=(
  "1.2|https://github.com/Netcracker/qubership-core-utils"
  "1.3|https://github.com/Netcracker/qubership-core-error-handling"
  "1.4|https://github.com/Netcracker/qubership-core-process-orchestrator"
  "1.5|https://github.com/Netcracker/qubership-core-context-propagation"
  "1.6|https://github.com/Netcracker/qubership-core-microservice-framework-extensions"
  "1.7|https://github.com/Netcracker/qubership-core-mongo-evolution"
  "1.8|https://github.com/Netcracker/qubership-core-junit-k8s-extension"
  "2.1|https://github.com/Netcracker/qubership-core-restclient"
  "2.2|https://github.com/Netcracker/qubership-core-context-propagation-quarkus"
  "3.1|https://github.com/Netcracker/qubership-core-rest-libraries"
  "4.1|https://github.com/Netcracker/qubership-core-blue-green-state-monitor"
  "4.2|https://github.com/Netcracker/qubership-dbaas-client"
  "5.1|https://github.com/Netcracker/qubership-maas-client"
  "6.1|https://github.com/Netcracker/qubership-maas-client-spring"
  "6.2|https://github.com/Netcracker/qubership-maas-declarative-client-commons"
  "6.3|https://github.com/Netcracker/qubership-core-microservice-dependencies"
  "6.4|https://github.com/Netcracker/qubership-core-quarkus-extensions"
  "7.1|https://github.com/Netcracker/qubership-maas-declarative-client-spring"
  "7.2|https://github.com/Netcracker/qubership-core-microservice-framework"
  "7.3|https://github.com/Netcracker/qubership-core-blue-green-state-monitor-quarkus"
  "7.4|https://github.com/Netcracker/qubership-maas-client-quarkus"
  "8.1|https://github.com/Netcracker/qubership-core-springboot-starter"
  "8.2|https://github.com/Netcracker/qubership-maas-declarative-client-quarkus"
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