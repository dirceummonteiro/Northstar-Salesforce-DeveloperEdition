# R02 — Deployment Result

## Etapa 1 — Validação (Deploy ID `0Affj00000NhxUDCAZ`)

```
sf project deploy validate --source-dir force-app/main/default/permissionsets --test-level RunLocalTests --target-org helix-dev
```

Diferente de R01, esta validação foi produzida pelo próprio Probe, não reaproveitada de outro
agente: a fatia (a) do M1 (permission sets) chegou pronta no working tree, sem um job do Kernel
antecedendo-a. Status: **Succeeded**. `checkOnly: true`, `runTestsEnabled: true`
(`RunLocalTests`). 8/8 componentes, 0 erros. 3/3 testes (`HttpCalloutServiceTest`), 0 falhas.

## Etapa 2 — Quick deploy (Deploy ID `0Affj00000NhwRiCAJ`)

```
sf project deploy quick --job-id 0Affj00000NhxUDCAZ --target-org helix-dev
```

Status: **Succeeded**. `checkOnly: false`, `runTestsEnabled: false` (testes reaproveitados da
validação da etapa 1, dentro da janela de reaproveitamento do Salesforce).

```
Deployed Source
┌─────────┬────────────────────────────────┬────────────────┬─────────────────────────────────────────────────────────────────────────────────────────┐
│ State   │ Name                           │ Type           │ Path                                                                                       │
├─────────┼────────────────────────────────┼────────────────┼─────────────────────────────────────────────────────────────────────────────────────────┤
│ Created │ NDG_Deal_Desk                  │ PermissionSet  │ permissionsets/NDG_Deal_Desk.permissionset                                                │
│ Created │ NDG_Executive_ReadOnly         │ PermissionSet  │ permissionsets/NDG_Executive_ReadOnly.permissionset                                       │
│ Created │ NDG_Integration_Admin          │ PermissionSet  │ permissionsets/NDG_Integration_Admin.permissionset                                        │
│ Created │ NDG_Regional_Director          │ PermissionSet  │ permissionsets/NDG_Regional_Director.permissionset                                        │
│ Created │ NDG_RevOps                     │ PermissionSet  │ permissionsets/NDG_RevOps.permissionset                                                   │
│ Created │ NDG_Sales_Manager              │ PermissionSet  │ permissionsets/NDG_Sales_Manager.permissionset                                            │
│ Created │ NDG_Sales_Rep                  │ PermissionSet  │ permissionsets/NDG_Sales_Rep.permissionset                                                │
│ Created │ NDG_Salesforce_Admin_Extended  │ PermissionSet  │ permissionsets/NDG_Salesforce_Admin_Extended.permissionset                                │
└─────────┴────────────────────────────────┴────────────────┴─────────────────────────────────────────────────────────────────────────────────────────┘
```

`numberComponentErrors: 0`, `numberComponentsDeployed: 8`, `numberComponentsTotal: 8`,
`status: Succeeded`, `success: true`.

## Medição de limites — antes vs. depois

| Recurso | Antes (R01, medido 2026-08-18) | Depois (`sf org list limits`, pós-R02, 2026-08-19) | Variação |
|---|---|---|---|
| `DataStorageMB` | Remaining 5 / Max 5 (0% em uso) | Remaining 5 / Max 5 (0% em uso) | Nenhuma |
| `DailyApiRequests` | Remaining 14.643 / Max 15.000 | Remaining 14.954 / Max 15.000 | Contador diário resetou (novo dia, 2026-08-19); não é comparável ponto a ponto com R01 |

`DataStorageMB` não se move: permission set é metadata declarativa, não registro de dado — a org
ainda não tem seed data (escopo do M2). `DailyApiRequests` é um limite de janela de 24 horas;
entre o fim de R01 (2026-08-18) e o início desta fatia (2026-08-19) o contador reiniciou, então a
comparação direta com o número de R01 não representa o consumo real desta fatia — não há uma
medição de `DailyApiRequests` feita por este agente antes do primeiro comando desta tarefa para
servir de baseline própria. A única leitura confiável é a final: 14.954 de 15.000 restantes
(0,3% em uso no dia), bem abaixo do limiar de 70% de `AMBIENTE.md` §2, mesmo somando validação,
quick deploy, dois `deploy report`/consultas de status, as queries de confirmação de
`PermissionSet` e `FieldPermissions`, o smoke test Apex e o próprio `org list limits`.

## Rollback / recuperação

Não aplicável — deploy bem-sucedido, sem erro de componente, sem falha de teste. Nenhuma ação de
rollback foi necessária.
