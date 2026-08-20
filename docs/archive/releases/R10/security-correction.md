# R10 — Correção pós-revisão do Fable (M3.1, ESCALONAMENTO DE SEGURANÇA)

Esta correção **amenda** o release R10 (fatia M3.1). Não é uma nova fatia nem um novo release —
os dois achados abaixo vêm do parecer do Fable sobre a FLS que a M3.1 aplicou nos permission sets
`NDG_*`, e a decisão de acatá-los integralmente está em `docs/DECISIONS.md`, **D-025**.

## O que o Fable apontou

Veredito: **"aprovado com ressalva"**, acatado integralmente pelo Helix.

1. `NDG_Integration_Admin` recebeu FLS de campo em `Lead` na M3.1 (`Capture_Channel__c` e
   `Lead_Dedupe_Key__c` com `editable=true`), mas **nunca teve `objectPermissions` de `Lead`**. Sem
   o object permission, a FLS de campo é inerte — a persona de integração não conseguia criar nem
   ler `Lead`, o que quebraria a captura da fatia M3.2.
2. `NDG_Executive_ReadOnly` e `NDG_Deal_Desk` tinham `readable=true` em
   `Lead.Lead_Dedupe_Key__c`. A chave guarda e-mail normalizado — dado pessoal — e é filtrável por
   SOQL. `Executive_ReadOnly` consome funil agregado (não precisa da chave individual);
   `Deal_Desk` não trabalha `Lead` (não tem sequer `objectPermissions` de `Lead`, só a FLS de
   campo, também inerte). Nos dois casos, a leitura era superfície de exposição sem uso funcional.

O Fable confirmou que o restante da FLS da M3.1 está conforme o desenho e que nenhum
`viewAllRecords`/`modifyAllRecords` foi reintroduzido em nenhum permission set.

## O que foi corrigido

| Permission set | Mudança | Antes | Depois |
|---|---|---|---|
| `NDG_Integration_Admin` | `objectPermissions` de `Lead` adicionado | inexistente | `allowRead=true`, `allowCreate=true`, `allowEdit=true`, `allowDelete=false`, `viewAllRecords=false`, `modifyAllRecords=false` |
| `NDG_Executive_ReadOnly` | `fieldPermissions` de `Lead.Lead_Dedupe_Key__c` removido | `readable=true` | entrada removida do arquivo (sem `readable=false` órfão, seguindo o padrão do repo) |
| `NDG_Deal_Desk` | `fieldPermissions` de `Lead.Lead_Dedupe_Key__c` removido | `readable=true` | entrada removida do arquivo (sem `readable=false` órfão, seguindo o padrão do repo) |

Nada além disso mudou em permissão. Nenhum permission set novo criado, nenhuma outra FLS ou
object permission tocada.

## Deploy

```
sf project deploy start --source-dir <3 permissionsets> --dry-run --target-org helix-dev --test-level RunLocalTests
Status: Succeeded (dry-run) — 3/3 componentes, 0 erros — 3/3 testes, 0 falhas
```

```
sf project deploy start --source-dir <3 permissionsets> --target-org helix-dev --test-level RunLocalTests
Status: Succeeded — 3/3 componentes deployados, 0 erros — 3/3 testes, 0 falhas
```

Componentes: `NDG_Deal_Desk`, `NDG_Executive_ReadOnly`, `NDG_Integration_Admin` (todos
`PermissionSet`, `changed=true`).

## Verificação na org — direta, não só o status do deploy

**ObjectPermissions** (`SELECT Parent.Name, SobjectType, PermissionsRead, PermissionsCreate,
PermissionsEdit, PermissionsDelete, PermissionsViewAllRecords, PermissionsModifyAllRecords FROM
ObjectPermissions WHERE SobjectType = 'Lead' AND Parent.Name = 'NDG_Integration_Admin'`):

| Campo | Valor confirmado |
|---|---|
| PermissionsRead | `true` |
| PermissionsCreate | `true` |
| PermissionsEdit | `true` |
| PermissionsDelete | `false` |
| PermissionsViewAllRecords | `false` |
| PermissionsModifyAllRecords | `false` |

Exatamente o desenho pedido pelo Fable — sem View All, sem Modify All.

**FieldPermissions** (`SELECT Parent.Name, Field FROM FieldPermissions WHERE Field =
'Lead.Lead_Dedupe_Key__c' AND Parent.Name IN ('NDG_Executive_ReadOnly','NDG_Deal_Desk')`):
**0 registros** — o campo não aparece mais para nenhum dos dois permission sets.

## Segurança — auditoria de segredo

`git diff` revisado antes do `git add` — nenhum Org Id, token, auth url, senha ou dado de pessoa
real nos arquivos alterados.

## Impacto em dados/limites

Sem carga de dado. Consumo de API desta correção: 2 chamadas de Metadata API (dry-run + deploy)
mais 2 SOQL de verificação — volume desprezível frente ao teto diário de 15.000 chamadas.

## Go/no-go

Correção pontual de permissão, dentro do escopo já aprovado da fatia M3.1. Não altera o status do
marco M3 nem a métrica `3/13` de `README.md`/`docs/PROGRESSO.md` — M3.1 já estava marcada como
deployada; esta correção só fecha a ressalva de segurança antes da M3.2 começar a escrever Apex
sobre `Lead`.
