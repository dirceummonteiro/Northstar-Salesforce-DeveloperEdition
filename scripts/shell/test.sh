#!/usr/bin/env bash
# test.sh — roda a suíte de testes Apex local com cobertura, em formato legível.
# Uso: ./scripts/shell/test.sh
# Alias da org configurável via variável de ambiente ORG_ALIAS (default: helix-dev).
set -euo pipefail

ORG_ALIAS="${ORG_ALIAS:-helix-dev}"

sf apex run test \
  --result-format human \
  --code-coverage \
  --wait 20 \
  --target-org "$ORG_ALIAS"
