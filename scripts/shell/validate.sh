#!/usr/bin/env bash
# validate.sh — valida o deploy do force-app contra a org alvo, sem escrever nada nela.
# Uso: ./scripts/shell/validate.sh
# Alias da org configurável via variável de ambiente ORG_ALIAS (default: helix-dev).
set -euo pipefail

ORG_ALIAS="${ORG_ALIAS:-helix-dev}"

sf project deploy validate \
  --source-dir force-app \
  --test-level RunLocalTests \
  --target-org "$ORG_ALIAS"
