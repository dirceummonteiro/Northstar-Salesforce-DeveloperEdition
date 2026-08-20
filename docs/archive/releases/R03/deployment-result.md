# R03 — Deployment Result

## Etapa 1 — Validação (Deploy ID `0Affj00000NipBFCAZ`)

```
sf project deploy validate \
  --source-dir force-app/main/default/objects/Pricing_Rule__mdt \
  --source-dir force-app/main/default/objects/Margin_Policy__mdt \
  --source-dir force-app/main/default/objects/Freight_Rule__mdt \
  --source-dir force-app/main/default/customMetadata \
  --source-dir force-app/main/default/objects/Discount_Request__c \
  --source-dir force-app/main/default/permissionsets \
  --test-level RunLocalTests --target-org helix-dev --wait 33 --json
```

Rodou fora do turno interativo (background, saída redirecionada para arquivo, lida depois —
regra do `AGENTS.md` para tarefa longa). Status: **Succeeded**. `checkOnly: true`,
`runTestsEnabled: true` (`RunLocalTests`). 65/65 componentes, 0 erros. 3/3 testes
(`HttpCalloutServiceTest`), 0 falhas.

## Etapa 2 — Deploy real (Deploy ID `0Affj00000NipPlCAJ`)

```
sf project deploy start \
  --source-dir force-app/main/default/objects/Pricing_Rule__mdt \
  --source-dir force-app/main/default/objects/Margin_Policy__mdt \
  --source-dir force-app/main/default/objects/Freight_Rule__mdt \
  --source-dir force-app/main/default/customMetadata \
  --source-dir force-app/main/default/objects/Discount_Request__c \
  --source-dir force-app/main/default/permissionsets \
  --test-level RunLocalTests --target-org helix-dev --wait 33 --json
```

Também rodou fora do turno interativo (mesmo padrão de background + arquivo). Status:
**Succeeded**. `checkOnly: false`, `runTestsEnabled: true` — os testes rodaram de novo nesta
etapa (não foi um `deploy quick` sobre a validação; foi um deploy completo com
`RunLocalTests` próprio, por decisão do Probe de exercitar a esteira completa dado que esta
fatia introduz dois objetos custom novos e sete permission sets alterados).
`numberComponentsDeployed: 65`, `numberComponentErrors: 0`, `numberTestsCompleted: 3`,
`numberTestErrors: 0`, `completedDate: 2026-08-19T13:00:12.000Z`.

## Componentes entregues (66 sucessos, incluindo `package.xml`; 65 de metadata real)

| Tipo | Quantidade | Detalhe |
|---|---|---|
| `CustomObject` | 4 | `Discount_Request__c`, `Pricing_Rule__mdt`, `Margin_Policy__mdt`, `Freight_Rule__mdt` |
| `CustomField` | 41 | 13 em `Discount_Request__c`, 11 em `Pricing_Rule__mdt`, 9 em `Margin_Policy__mdt`, 9 em `Freight_Rule__mdt` — inclui `Opportunity__c` (master-detail) |
| `CustomMetadata` | 11 | 8 registros de `Pricing_Rule`, 1 de `Margin_Policy`, 2 de `Freight_Rule` |
| `PermissionSet` | 8 | 7 alterados (`NDG_Deal_Desk`, `NDG_Executive_ReadOnly`, `NDG_Regional_Director`, `NDG_RevOps`, `NDG_Sales_Manager`, `NDG_Sales_Rep`, `NDG_Salesforce_Admin_Extended`) + `NDG_Integration_Admin` reimplantado sem alteração de conteúdo (fazia parte do diretório) |

Lista completa por `fullName` em `manifest.md`.

## Medição de limites — antes vs. depois

| Recurso | Antes (R02, medido 2026-08-19) | Depois (`sf org list limits`, pós-R03, 2026-08-19) | Variação |
|---|---|---|---|
| `DataStorageMB` | Remaining 5 / Max 5 (0% em uso) | Remaining 5 / Max 5 (0% em uso) | Nenhuma |
| `DailyApiRequests` | Remaining 14.954 / Max 15.000 | Remaining 14.826 / Max 15.000 | -128, mesma janela diária (sem reset entre R02 e R03) |

`DataStorageMB` não se move: Custom Metadata Types não consomem data storage por design da
plataforma (D-010, §1.5), e `Discount_Request__c` — objeto operacional — está vazio nesta fatia
(sem seed; seed é escopo do M2). O consumo de `DailyApiRequests` desta fatia (validate + deploy
+ 4 queries de `COUNT()` + 2 queries de `ObjectPermissions`/`FieldPermissions` + smoke test Apex
+ `org list limits`) ficou em 128 chamadas, 0,85% do limite diário — bem abaixo do limiar de 70%
de `AMBIENTE.md` §2.

## Rollback / recuperação

Não aplicável — validação e deploy bem-sucedidos, sem erro de componente, sem falha de teste.
Nenhuma ação de rollback foi necessária.
