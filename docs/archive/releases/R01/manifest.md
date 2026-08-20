# R01 — Manifest

## Fonte

`sf project deploy quick --job-id 0Affj00000NeKUECA3 --target-org helix-dev` reaplica, sem nova
validação, exatamente o conteúdo já validado pelo Kernel com `sf project deploy validate
--source-dir force-app --test-level RunLocalTests`.

## Componentes implantados (27/27, 0 erros)

| Estado | Nome | Tipo | Caminho |
|---|---|---|---|
| Unchanged | HttpCalloutService | ApexClass | `force-app/main/default/classes/HttpCalloutService.cls` |
| Unchanged | HttpCalloutServiceTest | ApexClass | `force-app/main/default/classes/HttpCalloutServiceTest.cls` |
| Created | Account.Available_Credit__c | CustomField | `force-app/main/default/objects/Account/fields/Available_Credit__c.field-meta.xml` |
| Created | Account.Channel_Type__c | CustomField | `force-app/main/default/objects/Account/fields/Channel_Type__c.field-meta.xml` |
| Created | Account.Credit_Limit__c | CustomField | `force-app/main/default/objects/Account/fields/Credit_Limit__c.field-meta.xml` |
| Created | Account.Credit_Status__c | CustomField | `force-app/main/default/objects/Account/fields/Credit_Status__c.field-meta.xml` |
| Created | Account.Current_Exposure__c | CustomField | `force-app/main/default/objects/Account/fields/Current_Exposure__c.field-meta.xml` |
| Created | Account.Customer_Segment__c | CustomField | `force-app/main/default/objects/Account/fields/Customer_Segment__c.field-meta.xml` |
| Created | Account.Customer_Tier__c | CustomField | `force-app/main/default/objects/Account/fields/Customer_Tier__c.field-meta.xml` |
| Created | Account.ERP_Customer_Id__c | CustomField | `force-app/main/default/objects/Account/fields/ERP_Customer_Id__c.field-meta.xml` |
| Created | Account.Last_ERP_Sync__c | CustomField | `force-app/main/default/objects/Account/fields/Last_ERP_Sync__c.field-meta.xml` |
| Created | Account.Primary_Territory_Code__c | CustomField | `force-app/main/default/objects/Account/fields/Primary_Territory_Code__c.field-meta.xml` |
| Created | Account.Strategic_Account__c | CustomField | `force-app/main/default/objects/Account/fields/Strategic_Account__c.field-meta.xml` |
| Created | Opportunity.Competitor_Primary__c | CustomField | `force-app/main/default/objects/Opportunity/fields/Competitor_Primary__c.field-meta.xml` |
| Created | Opportunity.Credit_Check_Status__c | CustomField | `force-app/main/default/objects/Opportunity/fields/Credit_Check_Status__c.field-meta.xml` |
| Created | Opportunity.Deal_Desk_Status__c | CustomField | `force-app/main/default/objects/Opportunity/fields/Deal_Desk_Status__c.field-meta.xml` |
| Created | Opportunity.External_Order_Id__c | CustomField | `force-app/main/default/objects/Opportunity/fields/External_Order_Id__c.field-meta.xml` |
| Created | Opportunity.Gross_Margin_Amount__c | CustomField | `force-app/main/default/objects/Opportunity/fields/Gross_Margin_Amount__c.field-meta.xml` |
| Created | Opportunity.Gross_Margin_Percent__c | CustomField | `force-app/main/default/objects/Opportunity/fields/Gross_Margin_Percent__c.field-meta.xml` |
| Created | Opportunity.Inventory_Check_Status__c | CustomField | `force-app/main/default/objects/Opportunity/fields/Inventory_Check_Status__c.field-meta.xml` |
| Created | Opportunity.Loss_Reason__c | CustomField | `force-app/main/default/objects/Opportunity/fields/Loss_Reason__c.field-meta.xml` |
| Created | Opportunity.Next_Step_Date__c | CustomField | `force-app/main/default/objects/Opportunity/fields/Next_Step_Date__c.field-meta.xml` |
| Created | Opportunity.Partner_Sourced__c | CustomField | `force-app/main/default/objects/Opportunity/fields/Partner_Sourced__c.field-meta.xml` |
| Created | Opportunity.Pricing_Status__c | CustomField | `force-app/main/default/objects/Opportunity/fields/Pricing_Status__c.field-meta.xml` |
| Created | Opportunity.Quote_Version__c | CustomField | `force-app/main/default/objects/Opportunity/fields/Quote_Version__c.field-meta.xml` |
| Created | Opportunity.Total_Discount_Percent__c | CustomField | `force-app/main/default/objects/Opportunity/fields/Total_Discount_Percent__c.field-meta.xml` |
| Changed | Quote | QuoteSettings | `force-app/main/default/settings/Quote.settings-meta.xml` |

`numberComponentsDeployed: 27`, `numberComponentsTotal: 27`, `numberComponentErrors: 0` (job
`0Affj00000Negp1CAB`). Os pares `.cls`/`.cls-meta.xml` de `HttpCalloutService*` aparecem uma vez
por classe nesta tabela (o `sf project deploy quick` reporta por componente lógico, não por
arquivo).

## Confirmação independente via Tooling API

Como a validação/deploy só reporta o resultado da operação, e a query SOQL direta aos novos
campos falhou por FLS (ver `smoke-test.md`), a existência real dos 24 `CustomField` foi
confirmada por consulta separada à Tooling API (`SELECT Id, DeveloperName, TableEnumOrId FROM
CustomField WHERE TableEnumOrId = 'Account' | 'Opportunity'`), que não depende de FLS do objeto
alvo. Os 11 campos de `Account` e os 13 de `Opportunity` aparecem todos, com `DeveloperName`
batendo com o `fullName` de cada `field-meta.xml`.

## sourceApiVersion

Sem alteração nesta fatia — permanece `67.0` (D-003), confirmada em R00.
