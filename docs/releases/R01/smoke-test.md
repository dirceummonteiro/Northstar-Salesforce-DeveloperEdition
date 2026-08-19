# R01 — Smoke Test

## 1. Testes Apex pós-deploy

Comando:

```
sf apex run test --target-org helix-dev --result-format human --code-coverage --wait 20
```

Resultado real:

```
=== Test Results
TEST NAME                                         OUTCOME  MESSAGE  RUNTIME (MS)
────────────────────────────────────────────────  ───────  ───────  ────────────
HttpCalloutServiceTest.testGet                    Pass              29
HttpCalloutServiceTest.testPostJson               Pass              4
HttpCalloutServiceTest.testSendSemHeadersNemBody  Pass              4

=== Test Summary
NAME                 VALUE
───────────────────  ─────────────────────────────────────────────
Outcome              Passed
Tests Ran            3
Pass Rate            100%
Fail Rate            0%
Skip Rate            0%
Test Run Id          707fj00000u2Ll6
Org Wide Coverage    100%
```

## 2. Prova da D-009 — Quote padrão habilitado

Comando:

```
sf data query --target-org helix-dev --query "SELECT COUNT() FROM Quote"
```

Resultado real:

```
Querying Data... done

Total number of records retrieved: 0.
```

**Isto é a evidência que mais importa nesta fatia.** Antes deste release, a mesma consulta
retornava `sObject type 'Quote' is not supported` — o objeto não estava habilitado na org. Agora
responde sem erro (0 registros, esperado: nenhum Quote foi criado ainda, seed data é escopo do
M2). A D-009 está aplicada e confirmada na org, não só no repositório.

## 3. Consulta aos novos campos de Account — FALHOU, causa raiz identificada

Comando pedido pela tarefa:

```
sf data query --target-org helix-dev --query "SELECT Id, ERP_Customer_Id__c, Credit_Status__c, Available_Credit__c FROM Account LIMIT 1"
```

Resultado real:

```
Querying Data... done
Error (1):
SELECT Id, ERP_Customer_Id__c, Credit_Status__c
           ^
ERROR at Row:1:Column:12
No such column 'ERP_Customer_Id__c' on entity 'Account'. If you are attempting to use a custom
field, be sure to append the '__c' after the custom field name. Please reference your WSDL or
the describe call for the appropriate names.
```

Reportando isto como está, sem maquiar (§59 proíbe fabricar sucesso de teste/deploy). A consulta
falhou de fato. O que se segue é a investigação da causa, não uma tentativa de esconder o
resultado.

### Investigação

**Hipótese descartada — deploy não criou os campos.** Já refutada por `manifest.md`: o job de
deploy (`0Affj00000Negp1CAB`) reportou os 24 campos como `Created`, 0 erros. Confirmado de forma
independente via Tooling API, que não depende de FLS do objeto alvo:

```
sf sobject describe --sobject Account --target-org helix-dev --json
→ describe padrão: nenhum dos 11 campos novos aparece na lista de fields.

sf data query --target-org helix-dev --use-tooling-api \
  --query "SELECT Id, DeveloperName, TableEnumOrId FROM CustomField WHERE TableEnumOrId = 'Account'"
→ 18 registros, incluindo os 11 campos novos (Channel_Type, Credit_Limit, Credit_Status,
  Current_Exposure, Customer_Segment, Customer_Tier, ERP_Customer_Id, Last_ERP_Sync,
  Primary_Territory_Code, Strategic_Account, Available_Credit).

Mesma consulta para Opportunity → 18 registros, incluindo os 13 campos novos.
```

Os 24 campos **existem** na org. O `describe()` padrão (o que a SOQL usa para validar colunas)
não os lista porque não há Field-Level Security concedida a ninguém ainda.

**Causa raiz confirmada — FLS ausente, inclusive para o usuário administrador:**

```
sf data query --target-org helix-dev \
  --query "SELECT Id, Name, Profile.Name, Profile.PermissionsViewAllData, Profile.PermissionsModifyAllData FROM User WHERE Username = '<username redigido — ver alias helix-dev>'"
→ Profile.Name = "Administrador do sistema"
  Profile.PermissionsViewAllData = true
  Profile.PermissionsModifyAllData = true

sf data query --target-org helix-dev \
  --query "SELECT Id, Field, SobjectType, ParentId, PermissionsRead, PermissionsEdit FROM FieldPermissions WHERE Field = 'Account.ERP_Customer_Id__c'"
→ Total number of records retrieved: 0.
```

`View All Data` e `Modify All Data` são permissões de **registro** (contornam regra de
compartilhamento); elas não contornam Field-Level Security, que é controlada por
`FieldPermissions`, por perfil ou permission set, campo a campo. Como o deploy via Metadata API
não incluiu nenhum `<fieldPermissions>` associado a um perfil (nenhuma tarefa desta fatia criou
permission set — isso é escopo da próxima fatia do M1), **nenhum perfil ou permission set, nem
mesmo o do usuário administrador que fez este deploy, tem FLS para os 24 campos novos.** Não é
um bug: é o comportamento padrão e seguro do Salesforce quando um campo é criado via API sem
metadata de permissão explícita — o campo nasce invisível para todo mundo até alguém conceder
acesso.

### Correção em relação ao texto original da tarefa

A tarefa antecipava que "hoje só quem tem 'View All / Modify All' enxerga" os campos. A
investigação mostra que isso não é exato: **ninguém enxerga**, nem mesmo o usuário com essas
duas permissões — porque elas não têm relação com FLS. Registrando a correção aqui e em
`known-limitations.md` para a próxima fatia (permission sets) não repetir a suposição.

## Conclusão

Deploy real e confirmado na org (Tooling API), Quote habilitado e comprovado (D-009), testes
Apex 3/3 com 100% de cobertura. A consulta direta aos campos de negócio falha hoje por ausência
de FLS — comportamento esperado e seguro, não uma falha de deploy, documentado como limitação
conhecida a ser fechada quando os permission sets chegarem.
