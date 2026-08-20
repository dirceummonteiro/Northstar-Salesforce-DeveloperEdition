# R06 — Manifest (consolidado do M1)

Nenhum componente novo nesta rodada. Esta tabela consolida o que as fatias 1, (a), (b), (c) e
(d) já implantaram, confirmado presente na org por esta rodada (`smoke-test.md`). Detalhe
componente a componente de cada fatia está em `docs/releases/R0{1,2,3,4}/manifest.md`.

## Objetos e campos em objetos padrão

| Objeto | Campos custom do projeto | Fatia | Commit |
|---|---|---|---|
| `Account` | 11 (`Available_Credit__c`, `Channel_Type__c`, `Credit_Limit__c`, `Credit_Status__c`, `Current_Exposure__c`, `Customer_Segment__c`, `Customer_Tier__c`, `ERP_Customer_Id__c`, `Last_ERP_Sync__c`, `Primary_Territory_Code__c`, `Strategic_Account__c`) | 1 | `b29e8e0` |
| `Opportunity` | 13 (`Competitor_Primary__c`, `Credit_Check_Status__c`, `Deal_Desk_Status__c`, `External_Order_Id__c`, `Gross_Margin_Amount__c`, `Gross_Margin_Percent__c`, `Inventory_Check_Status__c`, `Loss_Reason__c`, `Next_Step_Date__c`, `Partner_Sourced__c`, `Pricing_Status__c`, `Quote_Version__c`, `Total_Discount_Percent__c`) | 1 | `b29e8e0` |
| `Quote` | objeto padrão habilitado (D-009/ADR-008), sem campo custom | 1 | `b29e8e0` |

## Objetos e tipos custom

| API Name | Tipo | Campos custom | Registros | Fatia | Commit |
|---|---|---|---|---|---|
| `Pricing_Rule__mdt` | Custom Metadata Type | 11 | 8 | (b) | `db3391d` |
| `Margin_Policy__mdt` | Custom Metadata Type | 9 | 1 | (b) | `db3391d` |
| `Freight_Rule__mdt` | Custom Metadata Type | 9 | 2 | (b) | `db3391d` |
| `Discount_Request__c` | Custom Object (master-detail em `Opportunity`) | 13 | 0 (sem seed nesta rodada — seed é escopo do M2) | (c) | `897cfef` |
| `Integration_Log__b` | Big Object | 17 | 0 (sem seed nesta rodada) | (d) | `79981cd` |

## Permission Sets

| Nome | Fatia de criação | Ampliado em |
|---|---|---|
| `NDG_Sales_Rep` | (a) `a4185b9` | (c) `897cfef` |
| `NDG_Sales_Manager` | (a) `a4185b9` | (c) `897cfef` |
| `NDG_Regional_Director` | (a) `a4185b9` | (c) `897cfef` |
| `NDG_Deal_Desk` | (a) `a4185b9` | (c) `897cfef` (inclui `viewAllRecords`/`modifyAllRecords` em `Opportunity`, D-011) |
| `NDG_RevOps` | (a) `a4185b9` | (c) `897cfef`, (d) `79981cd` |
| `NDG_Integration_Admin` | (a) `a4185b9` | (c) `897cfef`, (d) `79981cd` |
| `NDG_Executive_ReadOnly` | (a) `a4185b9` | (c) `897cfef` |
| `NDG_Salesforce_Admin_Extended` | (a) `a4185b9` | (c) `897cfef`, (d) `79981cd` |

Nenhum permission set concede `View All Data` / `Modify All Data` (permissão de sistema).
`viewAllRecords`/`modifyAllRecords` por objeto existem só em `Discount_Request__c` (5 personas,
D-011 ratificada pelo Helix) e em `Opportunity` para `NDG_Deal_Desk` — ambos escalados como
ESCALONAMENTO DE SEGURANÇA em R03 e revisados pelo Helix. `Integration_Log__b` é
deliberadamente mais restrito: nenhum dos 3 permission sets que o tocam tem
`Edit`/`Delete`/`ViewAllRecords`/`ModifyAllRecords`, e `NDG_RevOps` não tem `Create`.
