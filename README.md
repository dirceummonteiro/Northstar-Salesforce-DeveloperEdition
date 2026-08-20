# Workspace Salesforce — Helix Squad

Repositório de trabalho do time Salesforce (Helix, Schema, Kernel, Pixel, Bridge, Pulse, Probe).

**Não há projeto ativo.** O time trabalha por tarefas diretas do Dirceu, uma de cada vez.

## O que tem aqui

| Caminho | O que é |
|---|---|
| `force-app/` | Metadata Salesforce versionado (formato source, SFDX) |
| `manifest/package.xml` | Manifesto de retrieve/deploy |
| `scripts/` | Scripts de validação, deploy e apoio |
| `docs/AMBIENTE.md` | Limites, licenças e restrições medidos da org `helix-dev` |
| `docs/adr/` | Decisões de arquitetura de registro |
| `docs/runbooks/` | Procedimentos operacionais |
| `docs/archive/` | Histórico do projeto Northstar, encerrado em 2026-08-20 |

## Org

Org de trabalho: alias `helix-dev` (Developer Edition). Autenticação já configurada via
refresh token — `sf org list` mostra o estado da conexão.

Limites que valem para qualquer coisa que for construída aqui: 5 MB de data storage
(≈ 2.500 registros somando todos os objetos) e 15 mil chamadas de API por dia.
Detalhes em [`docs/AMBIENTE.md`](docs/AMBIENTE.md).

## Como rodar

Pré-requisito: [Salesforce CLI](https://developer.salesforce.com/tools/salesforcecli) (`sf`).

```bash
# validar sem aplicar nada (roda deploy e testes no servidor, descarta o resultado)
./scripts/shell/validate.sh

# aplicar na org
./scripts/shell/deploy.sh
```

Só o Probe executa deploy e push. Os outros agentes rodam comandos de leitura.

## Histórico

O projeto **Northstar Revenue Cloud Prototype** foi encerrado em 2026-08-20. Escopo,
log de decisões, escada de marcos e pacotes de evidência estão em
[`docs/archive/`](docs/archive/) e num backup completo fora do repositório. O metadata
que já foi entregue continua aqui e na org.
