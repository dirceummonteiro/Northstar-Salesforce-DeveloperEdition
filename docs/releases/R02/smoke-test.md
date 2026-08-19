# R02 — Smoke Test

## 1. Os 8 permission sets existem na org

Comando:

```
sf data query --target-org helix-dev --query "SELECT Id, Name, Label FROM PermissionSet WHERE Name LIKE 'NDG_%' ORDER BY Name"
```

Resultado real:

```
┌────────────────────┬───────────────────────────────┬─────────────────────────────────────────┐
│ ID                 │ NAME                          │ LABEL                                   │
├────────────────────┼───────────────────────────────┼─────────────────────────────────────────┤
│ 0PSfj00000MQOObGAP │ NDG_Deal_Desk                 │ NDG Deal Desk Analyst                   │
│ 0PSfj00000MQOOcGAP │ NDG_Executive_ReadOnly        │ NDG Executive (Read Only)               │
│ 0PSfj00000MQOOdGAP │ NDG_Integration_Admin         │ NDG Integration Administrator           │
│ 0PSfj00000MQOOeGAP │ NDG_Regional_Director         │ NDG Regional Director                   │
│ 0PSfj00000MQOOfGAP │ NDG_RevOps                    │ NDG RevOps Administrator                │
│ 0PSfj00000MQOOgGAP │ NDG_Sales_Manager             │ NDG Sales Manager                       │
│ 0PSfj00000MQOOhGAP │ NDG_Sales_Rep                 │ NDG Sales Representative                │
│ 0PSfj00000MQOOiGAP │ NDG_Salesforce_Admin_Extended │ NDG Salesforce Administrator (Extended) │
└────────────────────┴───────────────────────────────┴─────────────────────────────────────────┘

Total number of records retrieved: 8.
```

8 de 8 personas da §30.2 confirmadas na org, um a um por `Name`.

## 2. As permissões de campo apontam para campos que existem

Comando (`ParentId` com os 8 Ids acima):

```
sf data query --target-org helix-dev --query "SELECT Parent.Name, Field, PermissionsRead, PermissionsEdit FROM FieldPermissions WHERE ParentId IN (<8 Ids>)"
```

Resultado: 183 registros de `FieldPermissions`. Campos distintos referenciados: **exatamente os
24** campos comerciais entregues em R01 (11 de `Account`, 13 de `Opportunity`) — nenhum campo
fora desse conjunto, nenhum inexistente na org. Confirmado cruzando a lista distinta de `Field`
contra os arquivos em `force-app/main/default/objects/{Account,Opportunity}/fields/`.

Fecha a limitação (c) de `docs/releases/R01/known-limitations.md`: antes deste release, nenhum
permission set concedia FLS aos 24 campos e ninguém — nem o administrador — conseguia
consultá-los via SOQL. Depois deste release, cada um dos 24 campos tem FLS concedida por pelo
menos um dos 8 permission sets.

## 3. Invariante de segurança — margem e desconto continuam somente leitura

```
grep "Gross_Margin\|Total_Discount" <query acima>
→ 24 linhas (3 campos × 8 permission sets), PermissionsRead=true, PermissionsEdit=false em
  TODAS as 24 combinações.
```

Nenhum dos 8 permission sets concede edição a `Opportunity.Gross_Margin_Amount__c`,
`Opportunity.Gross_Margin_Percent__c` ou `Opportunity.Total_Discount_Percent__c` — inclusive
`NDG_Salesforce_Admin_Extended` e `NDG_RevOps`, os dois com maior superfície de escrita. Consiste
com a §30.4 (campos de crédito/margem podem precisar de acesso de edição restrito) e com a
descrição do próprio `NDG_Deal_Desk` ("não deve editar os números que está julgando").

## 4. Nenhum permission set concede `View All Data` / `Modify All Data`

Verificado por leitura direta do XML antes do deploy (nenhuma tag `<userPermissions>` em nenhum
dos 8 arquivos) e reafirmado pela descrição textual de `NDG_Salesforce_Admin_Extended`, que
declara explicitamente excluir essas duas permissões, Author Apex e Manage Users.

## 5. Testes Apex

```
sf apex run test --target-org helix-dev --result-format human --code-coverage --wait 20
→ 3/3 Pass, 100% cobertura org-wide, Test Run Id 707fj00000u7Vti.
```

## Conclusão

Deploy real e confirmado na org por três vias independentes (query de `PermissionSet`, query de
`FieldPermissions`, inspeção do XML fonte antes do deploy). Os 8 permission sets existem, cobrem
exatamente os 24 campos de R01, mantêm margem/desconto somente leitura em todos os casos, e
nenhum concede permissão de sistema ampla. Testes Apex 3/3 com 100% de cobertura, sem regressão.
