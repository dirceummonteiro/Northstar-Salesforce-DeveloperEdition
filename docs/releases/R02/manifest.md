# R02 — Manifest

## Fonte

Validação própria do Probe (não houve job do Kernel para reaproveitar — esta fatia não passou
por outro agente antes de chegar ao repositório, já estava pronta no working tree):

```
sf project deploy validate --source-dir force-app/main/default/permissionsets --test-level RunLocalTests --target-org helix-dev
```

Job de validação `0Affj00000NhxUDCAZ` (checkOnly, 8/8 componentes, 0 erros, 3/3 testes), seguido
de:

```
sf project deploy quick --job-id 0Affj00000NhxUDCAZ --target-org helix-dev
```

## Componentes implantados (8/8, 0 erros)

| Estado  | Nome                           | Tipo           | Caminho                                                                                    |
|---|---|---|---|
| Created | NDG_Deal_Desk                  | PermissionSet  | `force-app/main/default/permissionsets/NDG_Deal_Desk.permissionset-meta.xml`                  |
| Created | NDG_Executive_ReadOnly         | PermissionSet  | `force-app/main/default/permissionsets/NDG_Executive_ReadOnly.permissionset-meta.xml`         |
| Created | NDG_Integration_Admin          | PermissionSet  | `force-app/main/default/permissionsets/NDG_Integration_Admin.permissionset-meta.xml`          |
| Created | NDG_Regional_Director          | PermissionSet  | `force-app/main/default/permissionsets/NDG_Regional_Director.permissionset-meta.xml`          |
| Created | NDG_RevOps                     | PermissionSet  | `force-app/main/default/permissionsets/NDG_RevOps.permissionset-meta.xml`                     |
| Created | NDG_Sales_Manager              | PermissionSet  | `force-app/main/default/permissionsets/NDG_Sales_Manager.permissionset-meta.xml`              |
| Created | NDG_Sales_Rep                  | PermissionSet  | `force-app/main/default/permissionsets/NDG_Sales_Rep.permissionset-meta.xml`                  |
| Created | NDG_Salesforce_Admin_Extended  | PermissionSet  | `force-app/main/default/permissionsets/NDG_Salesforce_Admin_Extended.permissionset-meta.xml`  |

`numberComponentsDeployed: 8`, `numberComponentsTotal: 8`, `numberComponentErrors: 0` (deploy
job `0Affj00000NhwRiCAJ`, quick sobre a validação `0Affj00000NhxUDCAZ`).

## Confirmação independente na org

```
sf data query --target-org helix-dev --query "SELECT Id, Name, Label FROM PermissionSet WHERE Name LIKE 'NDG_%' ORDER BY Name"
→ 8 registros, um por permission set, Name batendo com o fullName de cada arquivo.

sf data query --target-org helix-dev --query "SELECT Parent.Name, Field, PermissionsRead, PermissionsEdit FROM FieldPermissions WHERE ParentId IN (<8 Ids acima>)"
→ 183 registros de FieldPermissions, cobrindo exatamente os 24 campos entregues em R01
  (11 de Account, 13 de Opportunity) — nenhum campo fora desse conjunto, nenhum dos 24
  ausente em pelo menos um permission set.
```

## Cobertura do escopo (§30.2)

As 8 personas exigidas por esta fatia batem 1:1 com o que a §30.2 do `MASTER_SCOPE.md` lista.
`NDG_Portal_User` continua deliberadamente fora — adiada junto com o portal de cliente (§2.2),
como o próprio escopo instrui.

## sourceApiVersion

Sem alteração nesta fatia — permanece `67.0` (D-003).
