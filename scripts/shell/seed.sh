#!/usr/bin/env bash
# seed.sh — carrega a massa de demonstração do M2 na org e mostra as contagens.
# Uso: ./scripts/shell/seed.sh
# Alias da org configurável via variável de ambiente ORG_ALIAS (default: helix-dev).
#
# Idempotente: rodar duas vezes seguidas não duplica nada. As três etapas rodam
# em ordem porque a etapa 3 lê contas e preços que as etapas 1 e 2 criam.
#
# Pré-requisito: o usuário conectado precisa enxergar Seed_Key__c. Ver
# scripts/apex/README.md.
set -euo pipefail

ORG_ALIAS="${ORG_ALIAS:-helix-dev}"

for stage in seed_01_catalog seed_02_customers seed_03_pipeline seed_99_report; do
  echo "--- ${stage}"
  sf apex run --target-org "$ORG_ALIAS" --file "scripts/apex/${stage}.apex"
done
