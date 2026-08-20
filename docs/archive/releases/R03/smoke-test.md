# R03 — Smoke Test

## 1. Registros de Custom Metadata existem na org

```
sf data query --target-org helix-dev --query "SELECT COUNT() FROM Pricing_Rule__mdt"   → 8
sf data query --target-org helix-dev --query "SELECT COUNT() FROM Margin_Policy__mdt"   → 1
sf data query --target-org helix-dev --query "SELECT COUNT() FROM Freight_Rule__mdt"    → 2
```

8 + 1 + 2 = 11 registros, batendo exatamente com os 11 arquivos `.md-meta.xml` entregues em
`force-app/main/default/customMetadata/`.

## 2. `Discount_Request__c` existe e está vazio (esperado)

```
sf data query --target-org helix-dev --query "SELECT COUNT() FROM Discount_Request__c" → 0
```

Correto: é objeto operacional (não configuração), sem seed nesta fatia — seed data é escopo do
M2 (§33), fora desta tarefa.

## 3. `ObjectPermissions` de `Discount_Request__c` por persona

Comando:

```
sf data query --target-org helix-dev --query \
  "SELECT Parent.Name, PermissionsRead, PermissionsEdit, PermissionsCreate, PermissionsDelete, PermissionsViewAllRecords, PermissionsModifyAllRecords \
   FROM ObjectPermissions WHERE SobjectType='Discount_Request__c' ORDER BY Parent.Name"
```

Resultado real (9 registros — 7 permission sets `NDG_*` deste release + 2 concedidos
automaticamente pela plataforma na criação do `CustomObject`, ver item (d) abaixo):

| Parent | Read | Edit | Create | Delete | ViewAll | ModifyAll |
|---|---|---|---|---|---|---|
| `NDG_Deal_Desk` | true | true | false | false | **true** | false |
| `NDG_Executive_ReadOnly` | true | false | false | false | **true** | false |
| `NDG_Regional_Director` | true | false | false | false | **true** | false |
| `NDG_RevOps` | true | true | true | true | **true** | false |
| `NDG_Sales_Manager` | true | true | true | false | false | false |
| `NDG_Sales_Rep` | true | true | true | false | false | false |
| `NDG_Salesforce_Admin_Extended` | true | true | true | true | **true** | **true** |
| (perfil de sistema, não produzido por este deploy) | true | false | false | false | true | false |
| (perfil de sistema, não produzido por este deploy) | true | true | true | true | true | true |

As duas últimas linhas correspondem a `ObjectPermissions` ligadas a perfis (`X00e1a...`,
`X00ex...`), concedidas automaticamente pela plataforma quando um `CustomObject` é criado —
comportamento padrão do Salesforce, não uma linha do XML fonte deste release. Nenhum dos 7
arquivos de permission set entregues por esta fatia toca perfil.

Nenhum dos 7 permission sets concede a permissão de sistema `Modify All Data` / `View All Data`
(confirmado: nenhuma tag `<userPermissions>` em nenhum dos 7 arquivos-fonte). `viewAllRecords`/
`modifyAllRecords` acima são `ObjectPermissions` escopadas a `Discount_Request__c` — ver a tabela
completa de justificativa por persona em `release-summary.md`, seção de segurança.

## 4. `FieldPermissions` de `Discount_Request__c` — 12 campos, `Opportunity__c` fora por design

Comando:

```
sf data query --target-org helix-dev --query \
  "SELECT Parent.Name, Field, PermissionsRead, PermissionsEdit FROM FieldPermissions WHERE SobjectType='Discount_Request__c' ORDER BY Field, Parent.Name"
```

Resultado: 84 registros (12 campos × 7 permission sets), campos distintos:

```
Approval_Level__c, Current_Approver__c, Current_Margin_Percent__c, Decision_At__c,
Decision_Notes__c, Policy_Discount__c, Reason__c, Requested_By__c, Requested_Discount__c,
Requested_Margin_Percent__c, Status__c, Submitted_At__c
```

`Opportunity__c` (o campo 13, master-detail) **não aparece** — comportamento padrão da
plataforma: campos master-detail não recebem `FieldPermissions` porque não são opcionais nem
independentes do objeto pai; sempre visíveis/obrigatórios quando o objeto é acessível. Não é
omissão do deploy — confirmado que o `field-meta.xml` de `Opportunity__c` tem
`<type>MasterDetail</type>`.

## 5. Invariante de segurança — campos de negociação continuam somente leitura onde deveriam

```
Requested_Discount__c, Requested_Margin_Percent__c, Current_Margin_Percent__c, Policy_Discount__c
→ PermissionsEdit = false em TODOS os 7 permission sets, sem exceção — inclusive
  NDG_Salesforce_Admin_Extended e NDG_RevOps, os dois com maior superfície de escrita no objeto.
```

Consistente com a §30.4 (campos de margem/desconto precisam de acesso de edição restrito) e com
o mesmo padrão já verificado para `Opportunity.Gross_Margin_*`/`Total_Discount_Percent__c` em
R02: ninguém edita o número que está sendo julgado, nem o administrador estendido.

Campos editáveis variam por persona conforme a etapa do fluxo de aprovação que cada uma opera
(`Status__c`, `Decision_Notes__c`, `Decision_At__c`, `Current_Approver__c`,
`Approval_Level__c` para quem decide; `Reason__c`, `Requested_By__c` para quem solicita) — sem
sobreposição de escrita nos campos numéricos de julgamento.

## 6. Nenhum permission set concede permissão de sistema ampla

Verificado por leitura direta do XML antes do deploy (nenhuma tag `<userPermissions>` em nenhum
dos 7 arquivos alterados) e por `git diff --cached` completo antes do commit.

## 7. Varredura de segredos e dados pessoais (antes do commit)

```
git diff --cached | grep -niE '(password|secret|token|sfdx-auth-url|client_secret|private.?key)'  → vazio
git diff --cached | grep -noE '00D[0-9A-Za-z]{12,15}'                                              → vazio
git diff --cached | grep -noE '[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}'                      → vazio
git diff --cached | grep -noE '\d{3}\.\d{3}\.\d{3}-\d{2}'                                           → vazio (CPF)
git status --porcelain -uall | grep -E '\.sfdx/|\.sf/'                                              → vazio
```

## 8. Testes Apex

```
sf apex run test --target-org helix-dev --result-format human --code-coverage --wait 20
→ 3/3 Pass, 100% cobertura org-wide, Test Run Id 707fj00000u9XjR.
```

## Conclusão

Deploy real e confirmado na org por múltiplas vias independentes (contagem de registros de
Custom Metadata, `ObjectPermissions`, `FieldPermissions`, inspeção do XML fonte antes do
deploy). Os 3 Custom Metadata Types e seus 11 registros existem; `Discount_Request__c` existe
com sharing herdado da Opportunity e FLS explícita nos campos sensíveis mantida somente leitura
em todos os 7 permission sets. A única mudança de superfície de segurança real desde R02 é a
introdução de `viewAllRecords`/`modifyAllRecords` por objeto em 3 personas — documentada e
justificada em `release-summary.md`, não permissão de sistema, não descoberta tardiamente.
Testes Apex 3/3 com 100% de cobertura, sem regressão.
