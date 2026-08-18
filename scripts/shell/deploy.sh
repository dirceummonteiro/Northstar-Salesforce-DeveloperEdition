#!/usr/bin/env bash
# deploy.sh — valida e, só se a validação passar, faz o deploy real do force-app.
# Uso: ./scripts/shell/deploy.sh
# Alias da org configurável via variável de ambiente ORG_ALIAS (default: helix-dev).
set -euo pipefail

ORG_ALIAS="${ORG_ALIAS:-helix-dev}"

sf project deploy validate \
  --source-dir force-app \
  --test-level RunLocalTests \
  --target-org "$ORG_ALIAS"

sf project deploy start \
  --source-dir force-app \
  --target-org "$ORG_ALIAS"
