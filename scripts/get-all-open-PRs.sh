#!/usr/bin/env bash
set -euo pipefail

SHOW_ALL=false
if [[ "${1:-}" == "-a" ]]; then
  SHOW_ALL=true
fi

REPOS=(
  "base-images|https://github.com/Netcracker/qubership-core-base-images"
  "infra|https://github.com/Netcracker/qubership-core-infra"
  "java-lib-1.2|https://github.com/Netcracker/qubership-core-utils"
  "java-lib-1.3|https://github.com/Netcracker/qubership-core-error-handling"
  "java-lib-1.4|https://github.com/Netcracker/qubership-core-process-orchestrator"
  "java-lib-1.5|https://github.com/Netcracker/qubership-core-context-propagation"
  "java-lib-1.6|https://github.com/Netcracker/qubership-core-microservice-framework-extensions"
  "java-lib-1.7|https://github.com/Netcracker/qubership-core-mongo-evolution"
  "java-lib-1.8|https://github.com/Netcracker/qubership-core-junit-k8s-extension"
  "java-lib-2.1|https://github.com/Netcracker/qubership-core-restclient"
  "java-lib-2.2|https://github.com/Netcracker/qubership-core-context-propagation-quarkus"
  "java-lib-3.1|https://github.com/Netcracker/qubership-core-rest-libraries"
  "java-lib-4.1|https://github.com/Netcracker/qubership-core-blue-green-state-monitor"
  "java-lib-4.2|https://github.com/Netcracker/qubership-dbaas-client"
  "java-lib-5.1|https://github.com/Netcracker/qubership-maas-client"
  "java-lib-6.1|https://github.com/Netcracker/qubership-maas-client-spring"
  "java-lib-6.2|https://github.com/Netcracker/qubership-maas-declarative-client-commons"
  "java-lib-6.3|https://github.com/Netcracker/qubership-core-microservice-dependencies"
  "java-lib-6.4|https://github.com/Netcracker/qubership-core-quarkus-extensions"
  "java-lib-7.1|https://github.com/Netcracker/qubership-maas-declarative-client-spring"
  "java-lib-7.2|https://github.com/Netcracker/qubership-core-microservice-framework"
  "java-lib-7.3|https://github.com/Netcracker/qubership-core-blue-green-state-monitor-quarkus"
  "java-lib-7.4|https://github.com/Netcracker/qubership-maas-client-quarkus"
  "java-lib-8.1|https://github.com/Netcracker/qubership-core-springboot-starter"
  "java-lib-8.2|https://github.com/Netcracker/qubership-maas-declarative-client-quarkus"
  "go-lib-1.1|https://github.com/Netcracker/qubership-core-lib-go-error-handling"
  "go-lib-1.2|https://github.com/Netcracker/qubership-core-lib-go"
  "go-lib-2.1|https://github.com/Netcracker/qubership-core-lib-go-actuator-common"
  "go-lib-2.2|https://github.com/Netcracker/qubership-core-lib-go-dbaas-base-client"
  "go-lib-2.3|https://github.com/Netcracker/qubership-core-lib-go-rest-utils"
  "go-lib-2.4|https://github.com/Netcracker/qubership-core-lib-go-bg-state-monitor"
  "go-lib-2.5|https://github.com/Netcracker/qubership-core-lib-go-stomp-websocket"
  "go-lib-3.1|https://github.com/Netcracker/qubership-core-lib-go-bg-kafka"
  "go-lib-3.2|https://github.com/Netcracker/qubership-core-lib-go-dbaas-clickhouse-client"
  "go-lib-3.3|https://github.com/Netcracker/qubership-core-lib-go-dbaas-postgres-client"
  "go-lib-3.4|https://github.com/Netcracker/qubership-core-lib-go-dbaas-mongo-client"
  "go-lib-3.5|https://github.com/Netcracker/qubership-core-lib-go-dbaas-cassandra-client"
  "go-lib-3.6|https://github.com/Netcracker/qubership-core-lib-go-maas-client"
  "go-lib-3.7|https://github.com/Netcracker/qubership-core-lib-go-dbaas-arangodb-client"
  "go-lib-3.8|https://github.com/Netcracker/qubership-core-lib-go-fiber-server-utils"
  "go-lib-3.9|https://github.com/Netcracker/qubership-core-lib-go-paas-mediation-client"
  "go-lib-3.10|https://github.com/Netcracker/qubership-core-lib-go-dbaas-opensearch-client"
  "go-lib-4.1|https://github.com/Netcracker/qubership-core-lib-go-maas-core"
  "go-lib-4.2|https://github.com/Netcracker/qubership-core-lib-go-maas-segmentio"
  "go-lib-5.1|https://github.com/Netcracker/qubership-core-lib-go-maas-bg-segmentio"
  "java-service-1|https://github.com/Netcracker/qubership-core-config-server"
  "java-service-2|https://github.com/Netcracker/qubership-core-core-operator"
  "go-service-1|https://github.com/Netcracker/qubership-core-control-plane"
  "go-service-2|https://github.com/Netcracker/qubership-core-dbaas-agent"
  "go-service-3|https://github.com/Netcracker/qubership-core-facade-operator"
  "go-service-4|https://github.com/Netcracker/qubership-core-maas-agent"
  "go-service-5|https://github.com/Netcracker/qubership-core-paas-mediation"
  "go-service-6|https://github.com/Netcracker/qubership-core-site-management"
  "other-1|https://github.com/Netcracker/qubership-core-ingress-gateway"
  "other-2|https://github.com/Netcracker/qubership-core-bootstrap"
)

LIMIT=200

for ENTRY in "${REPOS[@]}"; do
  IFS='|' read -r NUM REPO <<< "$ENTRY"

  if ! JSON=$(gh pr list --repo "$REPO" --state open --limit "$LIMIT" --search "-is:draft" --json number,title,url,createdAt 2>/dev/null); then
    if [[ "$SHOW_ALL" == true ]]; then
      echo "#### [$NUM] $REPO"
      echo "  (Error: Failed to get PR via gh)"
      echo
    fi
    continue
  fi

  COUNT=$(jq -r 'length' <<<"${JSON:-[]}" 2>/dev/null || echo 0)

  if [[ "$COUNT" -eq 0 && "$SHOW_ALL" == false ]]; then
    continue
  fi

  echo "#### [$NUM] $REPO"
  if [[ "$COUNT" -eq 0 ]]; then
    echo "  (no open PRs)"
    echo
    continue
  fi

  jq -r '
    sort_by(.number)[]
    | "- [\(.createdAt | fromdateiso8601 | strftime("%d.%m.%Y %H:%M"))] PR \(.number): \(.title) — \(.url)"
  ' <<<"$JSON"

  echo
done
