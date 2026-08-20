# R01 — Deployment Result

## Comando

```
sf project deploy quick --job-id 0Affj00000NeKUECA3 --target-org helix-dev
```

`deploy quick`, não `deploy.sh` (que roda `validate` + `start`): o job `0Affj00000NeKUECA3`, já
produzido e aprovado pelo Kernel com `--test-level RunLocalTests`, ainda estava dentro da janela
de reaproveitamento do Salesforce. Rodar uma validação nova consumiria orçamento de API sem
motivo — o conteúdo já tinha sido validado, com teste, minutos antes.

## Etapa única — Quick deploy (Deploy ID `0Affj00000Negp1CAB`)

Status: **Succeeded**. `checkOnly: false`, `runTestsEnabled: false` (testes reaproveitados da
validação `0Affj00000NeKUECA3`, que rodou `RunLocalTests` e passou 3/3).

```
Deployed Source
┌───────────┬───────────────────────────────────────┬───────────────┬────────────────────────────────────┐
│ State     │ Name                                  │ Type          │ Path                                │
├───────────┼───────────────────────────────────────┼───────────────┼────────────────────────────────────┤
│ Unchanged │ HttpCalloutService                    │ ApexClass     │ classes/HttpCalloutService.cls      │
│ Unchanged │ HttpCalloutServiceTest                │ ApexClass     │ classes/HttpCalloutServiceTest.cls  │
│ Created   │ Account.Available_Credit__c           │ CustomField   │ objects/Account.object              │
│ Created   │ Account.Channel_Type__c               │ CustomField   │ objects/Account.object              │
│ Created   │ Account.Credit_Limit__c               │ CustomField   │ objects/Account.object              │
│ Created   │ Account.Credit_Status__c              │ CustomField   │ objects/Account.object              │
│ Created   │ Account.Current_Exposure__c           │ CustomField   │ objects/Account.object              │
│ Created   │ Account.Customer_Segment__c           │ CustomField   │ objects/Account.object              │
│ Created   │ Account.Customer_Tier__c              │ CustomField   │ objects/Account.object              │
│ Created   │ Account.ERP_Customer_Id__c            │ CustomField   │ objects/Account.object              │
│ Created   │ Account.Last_ERP_Sync__c              │ CustomField   │ objects/Account.object              │
│ Created   │ Account.Primary_Territory_Code__c     │ CustomField   │ objects/Account.object              │
│ Created   │ Account.Strategic_Account__c          │ CustomField   │ objects/Account.object              │
│ Created   │ Opportunity.Competitor_Primary__c     │ CustomField   │ objects/Opportunity.object          │
│ Created   │ Opportunity.Credit_Check_Status__c    │ CustomField   │ objects/Opportunity.object          │
│ Created   │ Opportunity.Deal_Desk_Status__c       │ CustomField   │ objects/Opportunity.object          │
│ Created   │ Opportunity.External_Order_Id__c      │ CustomField   │ objects/Opportunity.object          │
│ Created   │ Opportunity.Gross_Margin_Amount__c    │ CustomField   │ objects/Opportunity.object          │
│ Created   │ Opportunity.Gross_Margin_Percent__c   │ CustomField   │ objects/Opportunity.object          │
│ Created   │ Opportunity.Inventory_Check_Status__c │ CustomField   │ objects/Opportunity.object          │
│ Created   │ Opportunity.Loss_Reason__c            │ CustomField   │ objects/Opportunity.object          │
│ Created   │ Opportunity.Next_Step_Date__c         │ CustomField   │ objects/Opportunity.object          │
│ Created   │ Opportunity.Partner_Sourced__c        │ CustomField   │ objects/Opportunity.object          │
│ Created   │ Opportunity.Pricing_Status__c         │ CustomField   │ objects/Opportunity.object          │
│ Created   │ Opportunity.Quote_Version__c          │ CustomField   │ objects/Opportunity.object          │
│ Created   │ Opportunity.Total_Discount_Percent__c │ CustomField   │ objects/Opportunity.object          │
│ Changed   │ Quote                                 │ QuoteSettings │ settings/Quote.settings             │
└───────────┴───────────────────────────────────────┴───────────────┴────────────────────────────────────┘
```

`numberComponentErrors: 0`, `numberComponentsDeployed: 27`, `numberComponentsTotal: 27`,
`status: Succeeded`, `success: true`.

## Medição de limites — antes vs. depois

Baseline de referência: `docs/AMBIENTE.md` §2 (medido em 2026-08-18, início do M0), único ponto
de medição anterior registrado no repositório.

| Recurso | Antes (`AMBIENTE.md` §2, início do M0) | Depois (`sf org list limits --target-org helix-dev`, pós-R01) | Variação |
|---|---|---|---|
| `DataStorageMB` | 0 MB em uso / 5 MB máx (0%) | 0 MB em uso / 5 MB máx (Remaining 5 / Max 5) | Nenhuma |
| `DailyApiRequests` | 239 em uso / 15.000 máx | 357 em uso / 15.000 máx (Remaining 14.643 / Max 15.000) | +118 chamadas |

`DataStorageMB` não se move: campos custom sem registro não consomem espaço (a org ainda não
tem seed data — isso é escopo do M2). A variação de `DailyApiRequests` (+118) cobre tanto a
validação do Kernel (job `0Affj00000NeKUECA3`) quanto o `deploy quick`, os dois `deploy report`,
o smoke test Apex, as consultas SOQL/Tooling API de verificação e o próprio `org list limits`.
2,4% de uso diário — bem abaixo do limiar de 70% de `AMBIENTE.md` §2. Nenhuma ação de contenção
necessária.

## Rollback / recuperação

Não aplicável — deploy bem-sucedido, sem erro de componente, sem falha de teste. Nenhuma ação de
rollback foi necessária.
