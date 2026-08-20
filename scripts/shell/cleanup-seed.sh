#!/usr/bin/env bash
# cleanup-seed.sh — DESTRUTIVO. Apaga a massa de demonstração do M2 e esvazia a
# lixeira.
#
# Apaga somente registros com Seed_Key__c começando em "NS-". Não toca nos 139
# registros de amostra que já vinham na Developer Edition (D-016) nem em
# qualquer registro sem a marca.
#
# Uso: ./scripts/shell/cleanup-seed.sh
# Alias da org configurável via variável de ambiente ORG_ALIAS (default: helix-dev).
set -euo pipefail

ORG_ALIAS="${ORG_ALIAS:-helix-dev}"

sf apex run --target-org "$ORG_ALIAS" --file scripts/apex/cleanup_seed.apex
sf apex run --target-org "$ORG_ALIAS" --file scripts/apex/seed_99_report.apex
