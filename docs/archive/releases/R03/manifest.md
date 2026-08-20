# R03 — Manifest

## Fonte

Metadata declarativa chegou pronta no working tree, produzida pelo Kernel sob o desvio D-010
(agente `schema` segue sem inicializar — P-15). O Probe validou e integrou:

```
sf project deploy validate --source-dir <6 diretórios> --test-level RunLocalTests --target-org helix-dev --json
```

Job de validação `0Affj00000NipBFCAZ` (checkOnly, 65/65 componentes, 0 erros, 3/3 testes),
seguido de deploy completo (não `quick`, `RunLocalTests` de novo):

```
sf project deploy start --source-dir <6 diretórios> --test-level RunLocalTests --target-org helix-dev --json
```

Job de deploy `0Affj00000NipPlCAJ`.

## Componentes implantados (65/65 de metadata, 0 erros)

### `Pricing_Rule__mdt` — objeto + 11 campos + 8 registros

| Estado | Nome | Tipo |
|---|---|---|
| Created | `Pricing_Rule__mdt` | CustomObject |
| Created | `Active__c`, `Customer_Segment__c`, `Customer_Tier__c`, `Discount_Percent__c`, `Effective_From__c`, `Effective_To__c`, `Max_Quantity__c`, `Min_Quantity__c`, `Priority__c`, `Product_Family__c`, `Stackable__c` | CustomField (11) |
| Created | `Tier_Bronze`, `Tier_Silver`, `Tier_Gold`, `Tier_Platinum`, `Volume_1_9`, `Volume_10_49`, `Volume_50_99`, `Volume_100_Plus` | CustomMetadata (8) |

### `Margin_Policy__mdt` — objeto + 9 campos + 1 registro

| Estado | Nome | Tipo |
|---|---|---|
| Created | `Margin_Policy__mdt` | CustomObject |
| Created | `Active__c`, `Customer_Segment__c`, `Deal_Desk_Threshold__c`, `Director_Approval_Threshold__c`, `Effective_From__c`, `Effective_To__c`, `Manager_Approval_Threshold__c`, `Min_Gross_Margin_Percent__c`, `Product_Family__c` | CustomField (9) |
| Created | `Default_Policy` | CustomMetadata (1) |

### `Freight_Rule__mdt` — objeto + 9 campos + 2 registros

| Estado | Nome | Tipo |
|---|---|---|
| Created | `Freight_Rule__mdt` | CustomObject |
| Created | `Active__c`, `Freight_Amount__c`, `Freight_Percent__c`, `Order_Value_From__c`, `Order_Value_To__c`, `Region__c`, `Warehouse_Code__c`, `Weight_Band_From_Kg__c`, `Weight_Band_To_Kg__c` | CustomField (9) |
| Created | `Nordeste_Heavy_PE01`, `Sudeste_Light_SP01` | CustomMetadata (2) |

### `Discount_Request__c` — objeto + 13 campos

| Estado | Nome | Tipo |
|---|---|---|
| Created | `Discount_Request__c` | CustomObject |
| Created | `Opportunity__c` (master-detail), `Approval_Level__c`, `Current_Approver__c`, `Current_Margin_Percent__c`, `Decision_At__c`, `Decision_Notes__c`, `Policy_Discount__c`, `Reason__c`, `Requested_By__c`, `Requested_Discount__c`, `Requested_Margin_Percent__c`, `Status__c`, `Submitted_At__c` | CustomField (13) |

### Permission sets (7 alterados + 1 reimplantado sem mudança)

| Estado | Nome | Tipo |
|---|---|---|
| Changed | `NDG_Deal_Desk`, `NDG_Executive_ReadOnly`, `NDG_Regional_Director`, `NDG_RevOps`, `NDG_Sales_Manager`, `NDG_Sales_Rep`, `NDG_Salesforce_Admin_Extended` | PermissionSet (7) |
| Changed (sem diff de conteúdo) | `NDG_Integration_Admin` | PermissionSet (1) — fazia parte do diretório `permissionsets/` passado ao `--source-dir`, reimplantado junto sem alteração |

`numberComponentsDeployed: 65`, `numberComponentErrors: 0` (job `0Affj00000NipPlCAJ`, validado
antes por `0Affj00000NipBFCAZ`).

## Confirmação independente na org

```
sf data query --target-org helix-dev --query "SELECT COUNT() FROM Pricing_Rule__mdt"     → 8
sf data query --target-org helix-dev --query "SELECT COUNT() FROM Margin_Policy__mdt"     → 1
sf data query --target-org helix-dev --query "SELECT COUNT() FROM Freight_Rule__mdt"      → 2
sf data query --target-org helix-dev --query "SELECT COUNT() FROM Discount_Request__c"    → 0 (esperado — objeto operacional, sem seed nesta fatia)

sf data query --target-org helix-dev --query \
  "SELECT Parent.Name, PermissionsRead, PermissionsEdit, PermissionsCreate, PermissionsDelete, PermissionsViewAllRecords, PermissionsModifyAllRecords \
   FROM ObjectPermissions WHERE SobjectType='Discount_Request__c' ORDER BY Parent.Name"
→ 9 registros: os 7 permission sets NDG_* + 2 concedidos automaticamente pela plataforma a
  perfis de sistema na criação do objeto custom (não produzidos por este deploy — comportamento
  padrão do Salesforce ao criar CustomObject; ver known-limitations.md item (d)).

sf data query --target-org helix-dev --query \
  "SELECT Parent.Name, Field, PermissionsRead, PermissionsEdit FROM FieldPermissions WHERE SobjectType='Discount_Request__c' ORDER BY Field, Parent.Name"
→ 84 registros de FieldPermissions, 12 campos distintos — os 12 campos de Discount_Request__c
  que aceitam FLS (todos exceto Opportunity__c, master-detail, que não recebe FieldPermissions
  por comportamento padrão da plataforma).
```

## Cobertura do escopo (§9.7, §9.8, §9.9, §9.16)

`Pricing_Rule__mdt` cobre os 11 campos conceituais da §9.7. `Margin_Policy__mdt` cobre os 8
campos conceituais da §9.8 (mais `Active__c`, adicionado pelo Kernel por simetria com os outros
dois mdt, não contradiz o escopo). `Freight_Rule__mdt` implementa a configuração de frete
descrita na §9.16 (região, faixa de peso, faixa de valor, depósito). `Discount_Request__c` bate
1:1 com os 13 campos literais da §9.9, incluindo os 9 valores do picklist `Status__c`.

## sourceApiVersion

Sem alteração nesta fatia — permanece `67.0` (D-003).
